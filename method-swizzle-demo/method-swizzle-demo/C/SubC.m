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
        // 3⃣️ 交换 c & subC（c 来自父类，但父类子类均未实现，subC 来自子类，已实现）
        // 此时，若使用子类对象调用子类方法时会出现无限循环调用
        {
            // --- BEFORE EXC ---
            // SEL       IMP
            // C.c       <NONE>
            // C.subC    <NONE>
            // SubC.c    <NONE>
            // SubC.subC SubC.subC
            Method c = class_getInstanceMethod(self, @selector(c));
            Method subC = class_getInstanceMethod(self, @selector(subC));

            // 为 self 添加方法 c，但实现为 subC，这一步骤是正确的
            BOOL isAddedMethodToSubClass = class_addMethod(self,
                                                           @selector(c),
                                                           method_getImplementation(subC),
                                                           method_getTypeEncoding(subC));
            // --- AFTER ADD ---
            // SEL       IMP
            // C.c       <NONE>
            // C.subC    <NONE>
            // SubC.c    SubC.subC ★
            // SubC.subC SubC.subC
            
            if (!c) {
                // 当 c 在父类子类均未实现时，为 subC 添加一个实现
                method_setImplementation(subC, imp_implementationWithBlock(^(id self, SEL _cmd) {
                    NSLog(@"PLACEHOLDER");
                }));
                
                // --- AFTER SET IMP ---
                // SEL       IMP
                // C.c       <NONE>
                // C.subC    <NONE>
                // SubC.c    SubC.subC
                // SubC.subC <CUSTOM>  ★
            }
            
            if (isAddedMethodToSubClass && c) {
                // 替换 subC 方法实现为 c 方法实现时，由于 c 子类父类均没有实现，将无法替换，因此导致无限循环
                class_replaceMethod(self,
                                    @selector(subC),
                                    method_getImplementation(c),
                                    method_getTypeEncoding(c));
            } else {
                // 子类已经实现，可以直接交换
                method_exchangeImplementations(c, subC);
                
                // --- AFTER EXC ---
                // SEL       IMP
                // C.c       <NONE>
                // C.subC    <NONE>
                // SubC.c    <CUSTOM>  ★
                // SubC.subC SubC.subC ★
            }
        }
    });
}

- (void)subC {
    NSLog(@"subC");
    
    // 无限循环调用：
    // subC
    // ...
    // subC
    
    [self subC];
}

@end
