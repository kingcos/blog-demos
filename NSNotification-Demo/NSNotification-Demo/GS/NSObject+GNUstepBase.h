//
//  NSObject+GNUstepBase.h
//  NSNotification-Demo
//
//  Created by kingcos on 2021/4/23.
//

#import <Foundation/Foundation.h>

// https://github.com/gnustep/libs-base/blob/master/Source/Additions/NSObject+GNUstepBase.m

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (GNUstepBase)
/**
 * Message sent when an implementation wants to explicitly require a subclass
 * to implement a method (but cannot at compile time since there is no
 * <code>abstract</code> keyword in Objective-C).  Default implementation
 * raises an exception at runtime to alert developer that he/she forgot to
 * override a method.
 */
- (id) subclassResponsibility: (SEL)aSel;

@end

NS_ASSUME_NONNULL_END
