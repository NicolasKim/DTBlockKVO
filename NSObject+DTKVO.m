//
//  NSObject+DTKVO.m
//  DTKVO
//
//  Created by 金秋成 on 2019/7/18.
//  Copyright © 2019 金秋成. All rights reserved.
//

#import "NSObject+DTKVO.h"
#import <objc/runtime.h>
#import <objc/message.h>


static NSString * const __DTKVOObjectPrefix__ = @"$_DTKVOObject_$";

static NSString * const __DTKVOObjectObserverKey__;


@interface DTKVOObserver : NSObject

@property (nonatomic,copy,readonly)DTKVOHandle  handle;

@property (nonatomic,copy,readonly)NSString *  key;

@property (nonatomic,assign,readonly)NSKeyValueObservingOptions options;

@property (nonatomic,copy,readonly)NSString *  token;

@end

SEL setterForKey(NSString *keyPath) {
    
    NSString * keyString = [keyPath capitalizedString];
    
    
    NSString * selName = [NSString stringWithFormat:@"set%@:",keyString];
    
    
    return NSSelectorFromString(selName);
    
}

SEL getterForKey(NSString *keyPath) {
    return NSSelectorFromString(keyPath);
}

NSString * keyForSetter(SEL setter) {
    
    NSString * setterName = NSStringFromSelector(setter);
    
    if ([setterName hasPrefix:@"set"] && [setterName hasSuffix:@":"]) {
        NSString * keyPath = [[setterName substringFromIndex:3] lowercaseString];
        
        keyPath = [keyPath substringToIndex:keyPath.length-1];

        return keyPath;
    }
    return nil;
    
}


static void dt_kvo_setter (id self , SEL _cmd , id newVal) {
    
    struct objc_super superClass = {
        .receiver = self,
        .super_class = class_getSuperclass(object_getClass(self))
    };
    
    NSMutableDictionary * observers = objc_getAssociatedObject(self, &__DTKVOObjectObserverKey__);
    
    NSMutableDictionary * change = [NSMutableDictionary new];
    
    for (DTKVOObserver * observer in observers.allValues) {
        if ([observer.key isEqualToString:keyForSetter(_cmd)]) {
            
            if (observer.options & NSKeyValueObservingOptionOld) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                id returnVal = [self performSelector:getterForKey(observer.key)];
#pragma clang diagnostic pop
                if (returnVal) {
                    [change setObject:returnVal forKey:NSKeyValueChangeOldKey];
                }
            }
            
            if (observer.options & NSKeyValueObservingOptionNew) {
                [change setObject:newVal forKey:NSKeyValueChangeNewKey];
            }
        }
    }
    
    
    //调用父类
    void (*objc_msgSendSuperCasted)(void *, SEL, id) = (void *)objc_msgSendSuper;
    
    objc_msgSendSuperCasted(&superClass,_cmd,newVal);
    
    
    for (DTKVOObserver * observer in observers.allValues) {
        if ([observer.key isEqualToString:keyForSetter(_cmd)]) {
            observer.handle(self, change);
        }
    }
    
}

static Class dt_kvo_class (id self, SEL _cmd) {
    Class cls = object_getClass(self);
    
    NSString * className = [NSString stringWithUTF8String:class_getName(cls)];
    
    if ([className hasPrefix:__DTKVOObjectPrefix__]) {
        return class_getSuperclass(cls);
    }
    return cls;
}




@implementation DTKVOObserver

-(instancetype)initWithKey:(NSString *)key options:(NSKeyValueObservingOptions)options  handle:(DTKVOHandle)handle {
    self = [super init];
    if (self) {
        _handle = [handle copy];
        _key = [key copy];
        _options = options;
    }
    return self;
}

-(NSString *)token{
    return [NSString stringWithFormat:@"%@%p",_key,_handle];
}

@end

@implementation NSObject (DTKVO)

-(NSString *)dt_observeForKey:(NSString *)key
                    options:(NSKeyValueObservingOptions)options
                     handle:(DTKVOHandle)handle{
    return [self _createClassPairWithKey:key object:self options:options handle:handle];
}

-(void)dt_removeObserverWithToken:(NSString *)token{
    NSMutableDictionary * observers = objc_getAssociatedObject(self, &__DTKVOObjectObserverKey__);
    if (observers == nil || observers.count == 0) {
        return;
    }
    
    [observers removeObjectForKey:token];
    
    if (observers.count == 0) {
        //恢复isa指针
        object_setClass(self, [self class]);
    }
}

-(NSString * )_createClassPairWithKey:(NSString *)key object:(id)obj options:(NSKeyValueObservingOptions)options handle:(DTKVOHandle)handle{
    if (!obj) { return nil; }
    SEL selector = setterForKey(key);
    if (!selector || !handle) { return nil;}
    
    
    Class aClass = object_getClass(obj);
    
    NSString * className = [NSString stringWithUTF8String:class_getName(aClass)];
    
    if ([className hasPrefix:__DTKVOObjectPrefix__]) {//已经是监听对象
        
    } else {//不是监听对象
        Method setterMethod = class_getInstanceMethod(aClass, selector);
        
        NSString * newClassName = [NSString stringWithFormat:@"%@%s",__DTKVOObjectPrefix__,class_getName(aClass)];
        
        Class newClass = objc_allocateClassPair(aClass, newClassName.UTF8String, 0);
        
        if (class_addMethod(newClass, selector, (IMP)dt_kvo_setter, method_getTypeEncoding(setterMethod))) {
            
        }
        
        if (class_addMethod(newClass, @selector(class), (IMP)dt_kvo_class, "v@:")) {
            
        }
        objc_registerClassPair(newClass);
        object_setClass(obj, newClass);
    }
    
    
    NSMutableDictionary * observers = objc_getAssociatedObject(obj, &__DTKVOObjectObserverKey__);
    if (!observers) {
        observers = [NSMutableDictionary new];
        objc_setAssociatedObject(obj, &__DTKVOObjectObserverKey__, observers, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    DTKVOObserver * observer = [[DTKVOObserver alloc] initWithKey:key options:options handle:handle];
    NSString * token = observer.token;
    [observers setObject:observer forKey:token];
    return token;
}


@end
