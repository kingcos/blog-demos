//
//  main.m
//  array_in_ios-demo
//
//  Created by kingcos on 2020/5/30.
//  Copyright © 2020 kingcos. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MAMutableArray.h"
#import "MAMutableDictionary.h"

void nsarrayInheritanceTree(void);

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        nsarrayInheritanceTree();
        
        // xcrun clang -framework Foundation main.m MAMutableArray.m MAMutableDictionary.m
//        MAMutableArrayTest();
//        MAMutableDictionaryTest();
    }
    return 0;
}

void nsarrayInheritanceTree() {
    // ARC / MRC
    NSLog(@"%@", [[NSMutableArray alloc] class]);                                 // __NSPlaceholderArray
    NSLog(@"%@", [[NSArray alloc] class]);                                        // __NSPlaceholderArray
    NSLog(@"%@", [[[NSArray alloc] class] superclass]);                           // NSMutableArray
    NSLog(@"%@", [[[[NSArray alloc] class] superclass] superclass]);              // NSArray
    NSLog(@"%@", [[[[[NSArray alloc] class] superclass] superclass] superclass]); // NSObject

    NSLog(@"%@", [[NSArray array] class]);                                        // __NSArray0
    NSLog(@"%@", [[[NSArray alloc] init] class]);                                 // __NSArray0
    NSLog(@"%@", [[[[NSArray alloc] init] class] superclass]);                    // NSArray

    NSLog(@"%@", [[NSMutableArray array] class]);                                 // __NSArrayM
    NSLog(@"%@", [[[NSMutableArray array] class] superclass]);                    // NSMutableArray

    NSLog(@"%@", [@[@1] class]);                                                  // __NSSingleObjectArrayI
    NSLog(@"%@", [[@[@1] class] superclass]);                                     // NSArray

    NSLog(@"%@", [@[@1, @2] class]);                                              // __NSArrayI
    NSLog(@"%@", [[@[@1, @2] class] superclass]);                                 // NSArray

    NSMutableArray *arr = [NSMutableArray array];
    NSLog(@"%@", [arr class]);                                                    // __NSArrayM

    [arr addObject:@1];
    NSLog(@"%@", [arr class]);                                                    // __NSArrayM
}
