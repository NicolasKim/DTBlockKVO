//
//  NSObject+DTKVO.h
//  DTKVO
//
//  Created by Dreamtracer on 2019/7/18.
//  Copyright © 2019 Dreamtracer. All rights reserved.
//

#import <AppKit/AppKit.h>


#import <Foundation/Foundation.h>

typedef void(^DTKVOHandle)(NSObject * obj,NSDictionary<NSKeyValueChangeKey,id> * change);

@interface NSObject (DTKVO)

/// 添加监听者
/// @param key key
/// @param options options
/// @param handle 回调函数
-(NSString *)dt_observeForKey:(NSString *)key
                      options:(NSKeyValueObservingOptions)options
                       handle:(DTKVOHandle)handle;

/// 销毁监听器
/// @param token 监听唯一标识
-(void)dt_removeObserverWithToken:(NSString *)token;

@end


