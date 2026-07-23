//
//  AppDelegate.m
//  MHAdSDKDemo
//
//  Created by 郭建恒 on 2025/1/13.
//

#import "AppDelegate.h"
#import <AppTrackingTransparency/AppTrackingTransparency.h>

#import "MHMainViewController.h"
#import "UIView+toast.h"
#include <objc/runtime.h>
#import <CoreLocation/CoreLocation.h>

#import <WindMillSDK/WindMillSDK.h>

@interface AppDelegate ()

@property (nonatomic, strong) CLLocationManager *locationManager;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    
    if (@available(iOS 13.0, *)) {
        UINavigationBarAppearance *appearance = [[UINavigationBarAppearance alloc] init];
        // 配置Nav背景（禁用半透明）
        [appearance configureWithOpaqueBackground];
        appearance.backgroundColor = [UIColor colorWithRed:226/255.0 green:142/255.0 blue:100/255.0 alpha:1];
        // 应用至所有外观模式
        [UINavigationBar appearance].standardAppearance = appearance;
        [UINavigationBar appearance].scrollEdgeAppearance = appearance;
        [UINavigationBar appearance].compactAppearance = appearance;
    } else {
        // Fallback on earlier versions
        // iOS 12 及以下兼容方案
        [[UINavigationBar appearance] setBarTintColor:[UIColor redColor]];
        [[UINavigationBar appearance] setTranslucent:NO];
        [[UINavigationBar appearance] setTitleTextAttributes:@{
            NSForegroundColorAttributeName: [UIColor whiteColor]
        }];
    }

    
    // 初始化 ToBid SDK（appId 79634 是 ToBid 后台分配的应用 ID）
    // MHAdSDK 的初始化会由 AWM4MHConfigAdapter 自动处理
    [WindMillAds setupSDKWithAppId:@"79634" completionHandler:nil];
    [WindMillAds setDebugEnable:YES];
    
    // 延迟请求 ATT 和定位权限
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
        [self.locationManager requestWhenInUseAuthorization];
        
        if (@available(iOS 14, *)) {
            [ATTrackingManager requestTrackingAuthorizationWithCompletionHandler:^(ATTrackingManagerAuthorizationStatus status) {
                if (status == ATTrackingManagerAuthorizationStatusAuthorized) {
                    NSLog(@"ATT: 用户已授权 IDFA");
                } else {
                    NSLog(@"ATT: 用户未授权 IDFA");
                }
            }];
        } else {
            NSLog(@"ATT: iOS 版本较低,无法请求 IDFA");
        }
    });
    
    [self showMianVC];
    
    return YES;
}

- (void)showMianVC {
    self.window = [[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor whiteColor];
    MHMainViewController * vc = [[MHMainViewController alloc]init];
    self.window.rootViewController = [[UINavigationController alloc]initWithRootViewController:vc];
    [self.window makeKeyAndVisible];
}




@end
