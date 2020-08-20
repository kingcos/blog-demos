//
//  SubC.m
//  method-swizzle-demo
//
//  Created by kingcos on 2020/8/20.
//

#import "SubC.h"
#import <objc/runtime.h>

@implementation SubC

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // 2⃣️ 交换 c & subC（c 来自父类，但父类子类均未实现，subC 来自子类，已实现）
        // 此时，若使用子类对象调用时会出现死循环
        {
            Method c = class_getInstanceMethod([self class], @selector(c));
            Method subC = class_getInstanceMethod([self class], @selector(subC));

            BOOL isAddedMethodToSubClass = class_addMethod([self class],
                                                           @selector(c),
                                                           method_getImplementation(c),
                                                           method_getTypeEncoding(c));
            
            if (!c) {
                // c 在父类子类均未实现，则添加
                method_setImplementation(subC, imp_implementationWithBlock(^(id self, SEL _cmd) {
                    NSLog(@"PLACEHOLDER");
                }));
            }
            
            if (isAddedMethodToSubClass && c) {
                // 
                class_replaceMethod([self class],
                                    @selector(subC),
                                    method_getImplementation(c),
                                    method_getTypeEncoding(c));
            } else {
                // 子类已经实现，可以直接交换
                method_exchangeImplementations(c, subC);
            }
        }
    });
}

- (void)subC {
    NSLog(@"subC");
    
    // subC
    // subC
    // subC
    [self subC];
}

@end
