//
//  NSNotificationTester.m
//  NSNotification-Demo
//
//  Created by kingcos on 2021/4/22.
//

#import "NSNotificationTester.h"

@implementation NSNotificationTester

- (void)testObserveAllNotifications {
    // name 传递 nil 时，监听所有通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notified:) name:nil object:nil];
}

- (void)testObserveMultipleTimes {
    // 多次监听，多次回调
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notified:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notified_2:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notified_2:) name:UIApplicationDidEnterBackgroundNotification object:nil];
}

- (void)testRemoveMultipleTimes {
//    [[NSNotificationCenter defaultCenter] removeObserver:self];
//    [[NSNotificationCenter defaultCenter] removeObserver:self];
//    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
}

- (void)notified:(NSNotification *)notification {
    NSLog(@"%@ - %d", notification.name, [NSThread currentThread].isMainThread);
}

- (void)notified_2:(NSNotification *)notification {
    NSLog(@"2 - %@ - %d", notification.name, [NSThread currentThread].isMainThread);
}

- (void)notified_3:(NSNotification *)notification {
    NSLog(@"3 - %@ - %d", notification.name, [NSThread currentThread].isMainThread);
}

@end
