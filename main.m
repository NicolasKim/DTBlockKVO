//
//  main.m
//  DTKVO
//
//  Created by 金秋成 on 2019/7/18.
//  Copyright © 2019 金秋成. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSObject+DTKVO.h"
#import <objc/runtime.h>


//static void printObjectMethodList(Class obj){
//    unsigned int count = 0;
//    Method * methods = class_copyMethodList(obj, &count);
//    for (int i = 0; i < count; i++) {
//        Method method = methods[i];
//        SEL methodName = method_getName(method);
//        NSLog(@"%s return type => %s",sel_getName(methodName),method_copyReturnType(method));
//    }
//    free(methods);
//}

//static void printObjectPropertyList(Class obj){
//    unsigned int count = 0;
//    objc_property_t * properties = class_copyPropertyList(obj, &count);
//    for (int i = 0; i < count; i++) {
//        objc_property_t property = properties[i];
//        unsigned int attrCount = 0;
//        const char * property_attr = property_getAttributes(property);
//        
//
//
//        //If the property is a type of Objective-C class, then substring the variable of `property_attr` in order to getting its real type
//        if (property_attr[1] == '@') {
//            char * occurs1 =  strchr(property_attr, '@');
//            char * occurs2 =  strrchr(occurs1, '"');
//            char dest_str[40]= {0};
//            strncpy(dest_str, occurs1, occurs2 - occurs1);
//            char * realType = (char *)malloc(sizeof(char) * 50);
//            int i = 0, j = 0, len = (int)strlen(dest_str);
//            for (; i < len; i++) {
//                if ((dest_str[i] >= 'a' && dest_str[i] <= 'z') || (dest_str[i] >= 'A' && dest_str[i] <= 'Z')) {
//                    realType[j++] = dest_str[i];
//                }
//            }
//            property_data_type = [NSString stringWithFormat:@"%s", realType];
//            free(realType);
//        } else {
//
//            //Otherwise, take the second subscript character for comparing to the @encode()
//            char * realType = [self getPropertyRealType:property_attr];
//            property_data_type = [NSString stringWithFormat:@"%s", realType];
//        }
//
//    }
//    free(properties);
//}








//@interface DogAttr : NSObject
//
//@property (nonatomic,strong)NSString * skill;
//
//@end
//
//@implementation DogAttr
//
//
//
//@end
//
//@interface Dog : NSObject
//
//@property (nonatomic,strong)NSString * name;
//
//@property (nonatomic,strong)DogAttr * attr;
//
//@end
//
//@implementation Dog
//
//
//
//@end

@interface Person : NSObject

@property (nonatomic,strong)NSString * name;

//@property (nonatomic,strong)Dog * dog;

@property (nonatomic,assign)int age;

@end

@implementation Person



@end

//@interface PersonObserver : NSObject
//
//@end
//
//@implementation PersonObserver
//
//-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
//
//}
//
//@end


int main(int argc, const char * argv[]) {
    @autoreleasepool {
        Person * person = [[Person alloc] init];
        
        
//        printObjectMethodList([person class]);
        
//        const char * cClassName = class_getName(object_getClass(person));
//        NSString * ocClassName = [person class];
//        
//        NSLog(@"%s %@",cClassName,ocClassName);
        
        person.name = @"asljdfla";
        
//        person.dog = [[Dog alloc] init];
//
//        person.dog.attr = [[DogAttr alloc] init];
        
        
        NSString * token = [person dt_observeForKey:@"name" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld  handle:^(NSObject *obj, NSDictionary<NSKeyValueChangeKey,id> *change) {
            NSLog(@"first observer %@",change);
        }];
        
        
        
        
        
        person.name = @"jinqiucheng";
        
        NSString * token2 = [person dt_observeForKey:@"name" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld  handle:^(NSObject *obj, NSDictionary<NSKeyValueChangeKey,id> *change) {
            NSLog(@"second observer %@",change);
        }];
        
        
        person.name = @"jinqiucheng1";
        
        
        
        [person dt_removeObserverWithToken:token];
        
        [person dt_removeObserverWithToken:token2];
        
        person.name = @"AlreadyRemoved";
        
        
//        Person * observer = [[PersonObserver alloc]init];
//
//
//        [person addObserver:observer forKeyPath:@"dog.attr.skill" options:NSKeyValueObservingOptionNew context:nil];
//
//        NSLog(@"==============");
//        printObjectPropertyList([person class]);
//        printObjectMethodList(object_getClass(person));
//        NSLog(@"==============");
//        printObjectMethodList(object_getClass(person.dog));
//        NSLog(@"==============");
//        printObjectMethodList(object_getClass(person.dog.attr));
//        NSLog(@"==============");
//        const char * cClassName1 = class_getName(object_getClass(person));
//        NSString * ocClassName1 = [person class];
//
//        NSLog(@"%s %@",cClassName1,ocClassName1);
//
//        const char * cClassName2 = class_getName(object_getClass(person.dog));
//        NSString * ocClassName2 = [person.dog class];
//
//        NSLog(@"%s %@",cClassName2,ocClassName2);
//
//
//        const char * cClassName3 = class_getName(object_getClass(person.dog.attr));
//        NSString * ocClassName3 = [person.dog.attr class];
//
//        NSLog(@"%s %@",cClassName3,ocClassName3);
//
//        person.dog = [[Dog alloc] init];
        
        
    }
    return 0;
}
