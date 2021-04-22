//
//  ViewController.m
//  NSNotification-Demo
//
//  Created by kingcos on 2021/4/20.
//

#import "ViewController.h"
#import "NSNotificationTester.h"

@interface ViewController ()

@property (nonatomic, strong) NSNotificationTester *tester;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
//    [self.tester testObserveAllNotifications];
    [self.tester testObserveMultipleTimes];
//    [self.tester testRemoveMultipleTimes];
}

- (IBAction)addObserver:(id)sender {
    
}

- (IBAction)removeObserver:(id)sender {
    [self.tester testRemoveMultipleTimes];
}

- (NSNotificationTester *)tester {
    if (!_tester) {
        _tester = [[NSNotificationTester alloc] init];
    }
    
    return _tester;
}

@end
