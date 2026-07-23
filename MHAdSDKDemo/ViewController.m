//
//  ViewController.m
//  MHAdSDKDemo
//
//  Created by Abenx on 2021/9/8.
//

#import "ViewController.h"
#import <AppTrackingTransparency/AppTrackingTransparency.h>

@interface ViewController ()

@end

@implementation ViewController

#pragma mark - Life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];

    [ATTrackingManager requestTrackingAuthorizationWithCompletionHandler:^(ATTrackingManagerAuthorizationStatus status) {
        if (status == ATTrackingManagerAuthorizationStatusAuthorized) {
        } else {
            NSLog(@"MHAdManager error: 无法请求到IDFA, status: %ld", status);
        }
    }];
}

@end
