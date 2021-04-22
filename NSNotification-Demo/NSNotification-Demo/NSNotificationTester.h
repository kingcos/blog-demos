//
//  NSNotificationTester.h
//  NSNotification-Demo
//
//  Created by kingcos on 2021/4/22.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSNotificationTester : NSObject

- (void)testObserveAllNotifications;
- (void)testObserveMultipleTimes;
- (void)testRemoveMultipleTimes;

@end

NS_ASSUME_NONNULL_END
