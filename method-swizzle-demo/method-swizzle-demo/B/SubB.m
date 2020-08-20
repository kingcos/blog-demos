//
//  SubB.m
//  method-swizzle-demo
//
//  Created by kingcos on 2020/8/20.
//

#import "SubB.h"
#import <objc/runtime.h>

@implementation SubB

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // 2⃣️ 交换 b & subB（b 来自父类，子类未实现，subB 来自子类，已实现）
        // 此时，子类对象使用正常，但父类对象调用时，若在子类方法中调回了当前方法将出现异常
        {
            Method b = class_getInstanceMethod(self, @selector(b));
            Method subB = class_getInstanceMethod(self, @selector(subB));

            BOOL isAddedMethodToSubClass = class_addMethod(self,
                                                           @selector(b),
                                                           method_getImplementation(subB),
                                                           method_getTypeEncoding(subB));

            if (isAddedMethodToSubClass) {
                // 因此需要为子类添加父类的方法 b 为 subB 的实现，再替换 subB 为 b 的实现即可
                class_replaceMethod(self,
                                    @selector(subB),
                                    method_getImplementation(b),
                                    method_getTypeEncoding(b));
            } else {
                // 子类已经实现，可以直接交换
                method_exchangeImplementations(b, subB);
            }
        }
    });
}

- (void)subB {
    NSLog(@"SubB - subB");
    
    // Thread 1: "-[B subB]: unrecognized selector sent to instance 0x1038acd90"
    [self subB];
}

@end
