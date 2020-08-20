//
//  A+Ext.m
//  method-swizzle-demo
//
//  Created by kingcos on 2020/8/20.
//

#import "A+Ext.h"
#import <objc/runtime.h>

@implementation A (Ext)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // 1⃣️ 交换 a & ae（a 来自本类，ae 来自本类的分类，均已实现）
        {
            Method a = class_getInstanceMethod([self class], @selector(a));
            Method ae = class_getInstanceMethod([self class], @selector(ae));

            // 直接交换
            method_exchangeImplementations(a, ae);
        }
        
        
    });
}

- (void)ae {
    NSLog(@"ae");
    
    [self ae];
}

@end
