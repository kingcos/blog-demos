//
//  main.m
//  method-swizzle-demo
//
//  Created by kingcos on 2020/8/19.
//

#import <Foundation/Foundation.h>
#import "Foo.h"
#import "Foo+Ext_1.h"

#import "SubFoo.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        Foo *foo = [[Foo alloc] init];
        SubFoo *subFoo = [[SubFoo alloc] init];
        
        {
            // 1⃣️
//            [foo foo_1];
            // Foo+Ext_1 - foo_ext1_1
            // Foo - foo_1
        }
        
        {
            // 2⃣️
//            [foo foo_1];
            //  Foo - foo_1
        }
        
        
        
        
    }
    return 0;
}
