//
//  Foo+Ext_1.m
//  method-swizzle-demo
//
//  Created by kingcos on 2020/8/19.
//

#import "Foo+Ext_1.h"
#import <objc/runtime.h>

@implementation Foo (Ext_1)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // 1⃣️ 交换 foo_1 & foo_ext1_1（foo_1 来自本类，foo_ext1_1 来自本类的分类，均已实现）
//        {
//            Method foo_1 = class_getInstanceMethod([self class], @selector(foo_1));
//            Method foo_ext1_1 = class_getInstanceMethod([self class], @selector(foo_ext1_1));
//
//            // 直接交换
//            method_exchangeImplementations(foo_1, foo_ext1_1);
//        }
        
        
    });
}

- (void)foo_ext1_1 {
    NSLog(@"Foo+Ext_1 - foo_ext1_1");
    
    [self foo_ext1_1];
}

@end
