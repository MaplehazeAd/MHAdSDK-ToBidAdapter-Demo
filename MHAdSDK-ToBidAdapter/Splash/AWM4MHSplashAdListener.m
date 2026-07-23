//
//  WM4MHSplashAdListener.m
//  MHAdSDKDemo
//
//  Created by 郭建恒 on 2026/7/20.
//

#import "AWM4MHSplashAdListener.h"

@implementation AWM4MHSplashAdListener

- (instancetype)initWithBridge:(id<AWMCustomSplashAdapterBridge>)bridge
                       adapter:(id<AWMCustomAdapter>)adapter {
    self = [super init];
    if (self) {
        _bridge = bridge;
        _adapter = adapter;
    }
    return self;
}

#pragma mark - MHSplashAdDelegete

- (void)splashAdDidLoad:(MHSplashAd *)splashAd placementID:(NSString *)placementID {
    NSLog(@"[WM4MH] %@", NSStringFromSelector(_cmd));
    // MHAdSDK loadAd 成功即渲染完成，直接上报 ecpm 并通知 ToBid 加载完成
    NSInteger ecpm = [splashAd ecpm];
    NSLog(@"[WM4MH] splash ad ecpm: %ld", ecpm);
    [self.bridge splashAd:self.adapter didAdServerResponseWithExt:@{
        WindMillConstant.ECPM: [NSString stringWithFormat:@"%ld", (long)ecpm]
    }];
    self.isReady = YES;
    [self.bridge splashAdDidLoad:self.adapter];
}

- (void)splashAdLoadFailed:(MHSplashAd *)splashAd
                 errorCode:(NSInteger)errorCode
              errorMessage:(NSString *)errorMessage {
    NSLog(@"[WM4MH] %@ errorCode=%ld message=%@", NSStringFromSelector(_cmd), (long)errorCode, errorMessage);
    self.isReady = NO;
    NSError *error = [NSError errorWithDomain:@"MHSplashAd"
                                         code:errorCode
                                     userInfo:@{NSLocalizedDescriptionKey: errorMessage ?: @"unknown"}];
    [self.bridge splashAd:self.adapter didLoadFailWithError:error ext:@{}];
}

- (void)splashAdDidAppear:(MHSplashAd *)splashAd placementID:(NSString *)placementID {
    NSLog(@"[WM4MH] %@", NSStringFromSelector(_cmd));
    self.isReady = NO;
    [self.bridge splashAdWillVisible:self.adapter];
}

- (void)splashAdDidClicked:(MHSplashAd *)splashAd placementID:(NSString *)placementID {
    NSLog(@"[WM4MH] %@ rootController=%@ presented=%@",
          NSStringFromSelector(_cmd),
          splashAd.rootController,
          splashAd.rootController.presentedViewController);
    [self.bridge splashAdDidClick:self.adapter];
}

- (void)splashAdDidDisappear:(MHSplashAd *)splashAd placementID:(NSString *)placementID {
    NSLog(@"[WM4MH] %@", NSStringFromSelector(_cmd));
    [self.bridge splashAdDidClose:self.adapter];
}

- (void)splashAdDidPresentFullScreen:(MHSplashAd *)splashAd placementID:(NSString *)placementID {
    NSLog(@"[WM4MH] %@", NSStringFromSelector(_cmd));
    [self.bridge splashAdWillPresentFullScreenModal:self.adapter];
}

- (void)splashAdDidDismissFullScreen:(MHSplashAd *)splashAd placementID:(NSString *)placementID {
    NSLog(@"[WM4MH] %@", NSStringFromSelector(_cmd));
    [self.bridge splashAdViewControllerDidClose:self.adapter];
}

// 未声明在头文件中的跳过回调，MHAdSDK 实际会触发
- (void)splashAdDidSkipped:(MHSplashAd *)splashAd placementID:(NSString *)placementID {
    NSLog(@"[WM4MH] %@", NSStringFromSelector(_cmd));
    [self.bridge splashAdDidClickSkip:self.adapter];
}

@end
