//
//  KVNotification.m
//  NSNotification-Demo
//
//  Created by kingcos on 2021/4/22.
//

#import "KVNotification.h"
#import "KVStructure.h"
#import "NSObject+GNUstepBase.h"

@interface _KVNotification : NSObject
@end

@implementation KVNotification

static Class    abstractClass = 0;
static Class    concreteClass = 0;

+ (void) initialize
{
  if (concreteClass == 0)
    {
      abstractClass = [KVNotification class];
      concreteClass = [_KVNotification class];
    }
}

/**
 * Create a new autoreleased notification.
 */
+ (NSNotification*) notificationWithName: (NSString*)name
                  object: (id)object
                    userInfo: (NSDictionary*)info
{
  return [concreteClass notificationWithName: name
                      object: object
                    userInfo: info];
}

/**
 * Create a new autoreleased notification by calling
 * +notificationWithName:object:userInfo: with a nil user info argument.
 */
+ (NSNotification*) notificationWithName: (NSString*)name
                  object: (id)object
{
  return [concreteClass notificationWithName: name
                      object: object
                    userInfo: nil];
}

/**
 * Return a description of the parts of the notification.
 */
- (NSString*) description
{
  return [[super description] stringByAppendingFormat:
    @" Name: %@ Object: %@ Info: %@",
    [self name], [self object], [self userInfo]];
}

- (NSUInteger) hash
{
  return [[self name] hash] ^ [[self object] hash];
}

- (BOOL) isEqual: (id)other
{
  NSNotification    *o;
  NSObject        *v1;
  NSObject        *v2;

  if (NO == [(o = other) isKindOfClass: [NSNotification class]]
    || ((v1 = [self name]) != (v2 = [o name]) && ![v1 isEqual: v2])
    || ((v1 = [self object]) != (v2 = [o object]) && ![v1 isEqual: v2])
    || ((v1 = [self userInfo]) != (v2 = [o userInfo]) && ![v1 isEqual: v2]))
    {
      return NO;
    }
  return YES;
}

/**
 *  Returns the notification name.
 */
- (NSString*) name
{
  [self subclassResponsibility: _cmd];
  return nil;
}

/**
 *  Returns the notification object.
 */
- (id) object
{
  [self subclassResponsibility: _cmd];
  return nil;
}

/**
 * Returns the notification user information.
 */
- (NSDictionary*) userInfo
{
  [self subclassResponsibility: _cmd];
  return nil;
}

@end
