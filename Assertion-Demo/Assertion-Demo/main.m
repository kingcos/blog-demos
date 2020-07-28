//
//  main.m
//  Assertion-Demo
//
//  Created by kingcos on 2020/7/28.
//  Copyright © 2020 kingcos. All rights reserved.
//

#import <Foundation/Foundation.h>

void cFunc(int a) {
    // ERROR: Use of undeclared identifier '_cmd'
    // NSAssert(a > 0, @"a should be greater than 0.");
    
    // Thread 1: signal SIGABRT
//    assert(a > 0);
    
    // Thread 1: Exception: "a should be greater than 0."
//    NSCAssert(a > 0, @"a should be greater than 0.");
    
    // Thread 1: Exception: "Error: Error Domain=NSCocoaErrorDomain Code=404 \"(null)\""
    NSError *err = [NSError errorWithDomain:NSCocoaErrorDomain code:404 userInfo:nil];
    NSCAssert1(a > 0, @"Error: %@", err);
    
    NSCAssert(a > 0, @"Error: %@", err);
    
    // Thread 1: Exception: "Invalid parameter not satisfying: a > 0"
    NSCParameterAssert(a > 0);
    
    
}

@interface Foo : NSObject
- (void)barWithBaz:(NSInteger)baz;
@end

@implementation Foo

- (void)barWithBaz:(NSInteger)baz {
    // Thread 1: Exception: "Invalid parameter not satisfying: baz > 0"
//    NSParameterAssert(baz > 0);
    
    // Thread 1: Exception: "baz should be greater than 0."
//    NSAssert(baz > 0, @"baz should be greater than 0.");
    
    NSError *err = [NSError errorWithDomain:NSCocoaErrorDomain code:404 userInfo:nil];
    // Thread 1: Exception: "Error: Error Domain=NSCocoaErrorDomain Code=404 \"(null)\""
//    NSAssert1(baz > 0, @"Error: %@", err);
    
    // Thread 1: Exception: "Error: Error Domain=NSCocoaErrorDomain Code=404 \"(null)\""
    NSAssert(baz > 0, @"Error: %@", err);
}

@end

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // insert code here...
//        cFunc(0);
        
        [[Foo new] barWithBaz:0];
        
        [[[NSThread alloc] initWithBlock:^{
            NSInteger a = 0;
            
            // ERROR: Use of undeclared identifier '_cmd'
            // NSAssert(a > 0, @"a should be greater than 0.");
            
            // Thread 3: signal SIGABRT
            assert(a > 0);
            
            // Thread 3: Exception: "a should be greater than 0."
            NSCAssert(a > 0, @"a should be greater than 0.");
        }] start];
        
        
        for (int i = 0; i < 100000; i ++) {
            
        }
        
        NSLog(@"Hello, World!");
    }
    return 0;
}
