//
//  NSObject+GNUstepBase.m
//  NSNotification-Demo
//
//  Created by kingcos on 2021/4/23.
//

#import "NSObject+GNUstepBase.h"
#import <objc/runtime.h>

@implementation NSObject (GNUstepBase)

- (id) subclassResponsibility: (SEL)aSel
{
  char    c = (class_isMetaClass(object_getClass(self)) ? '+' : '-');

  [NSException raise: NSInvalidArgumentException
    format: @"[%@%c%@] should be overridden by subclass",
    NSStringFromClass([self class]), c,
    aSel ? (id)NSStringFromSelector(aSel) : (id)@"(null)"];
  while (1) ;   // Does not return
}

@end
