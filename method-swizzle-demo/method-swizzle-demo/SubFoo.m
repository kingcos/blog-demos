//
//  SubFoo.m
//  method-swizzle-demo
//
//  Created by kingcos on 2020/8/19.
//

#import "SubFoo.h"
#import <objc/runtime.h>

@implementation SubFoo

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // 2⃣️ 交换 foo_1 & subFoo_1（foo_1 来自父类，子类未实现，subFoo_1 来自子类，已实现）
        // 此时，子类对象使用正常，但父类对象调用父类方法将出现异常
        {
//            Method foo_1 = class_getInstanceMethod([self class], @selector(foo_1));
//            Method subFoo_1 = class_getInstanceMethod([self class], @selector(subFoo_1));
//            
//            BOOL isAddedMethodToSubClass = class_addMethod([self class],
//                                                           @selector(foo_1),
//                                                           method_getImplementation(foo_1),
//                                                           method_getTypeEncoding(foo_1));
//            
//            if (isAddedMethodToSubClass) {
//                // 为子类添加默认父类的实现，只需要替换 subFoo_1 为 foo_1 的实现即可
//                class_replaceMethod([self class],
//                                    @selector(subFoo_1),
//                                    method_getImplementation(foo_1),
//                                    method_getTypeEncoding(subFoo_1));
//            } else {
//                // 子类已经实现，可以直接交换
//                method_exchangeImplementations(foo_1, subFoo_1);
//            }
        }
    });
}

- (void)subFoo_1 {
    NSLog(@"SubFoo - subFoo_1");
    
    // CRASH: '-[Foo subFoo_1]: unrecognized selector sent to instance 0x1005acf10'
    [self subFoo_1];
}

@end
