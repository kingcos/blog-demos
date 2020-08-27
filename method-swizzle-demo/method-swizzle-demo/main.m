//
//  main.m
//  method-swizzle-demo
//
//  Created by kingcos on 2020/8/19.
//

#import <Foundation/Foundation.h>

#import "A+Ext.h"
#import "SubB.h"
#import "SubC.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        {
            // 1⃣️
//            A *a = [[A alloc] init];
//            [a a];
            // ae
            // a
        }
        
        {
            // 2⃣️
//            B *b = [[B alloc] init];
//            [b b];
            // b
//            SubB *subB = [[SubB alloc] init];
//            [subB b];
            // subB
            // b
        }
        
        {
            SubC *subC = [[SubC alloc] init];
            [subC subC];
        }
        
        
        
        
    }
    return 0;
}
