//
//  AWM4MHRewardedVideoAdListener.m
//  MHAdSDKDemo
//
//  Created by 郭建恒 on 2026/7/21.
//

#import "AWM4MHRewardedVideoAdListener.h"

@implementation AWM4MHRewardedVideoAdListener

- (instancetype)initWithBridge:(id<AWMCustomRewardedVideoAdapterBridge>)bridge
                       adapter:(id<AWMCustomAdapter>)adapter {
    self = [super init];
    if (self) {
        _bridge = bridge;
        _adapter = adapter;
    }
    return self;
}

#pragma mark - MHRewardedVideoAdDelegete

/// 激励视频已经加载
- (void)rewardedVideoAdVideoDidLoad:(MHRewardedVideoAd *)rewardedVideoAd
                        placementID:(NSString *)placementID {
    NSLog(@"[WM4MH] %@", NSStringFromSelector(_cmd));

    // 上报 eCPM
    NSInteger ecpm = [rewardedVideoAd ecpm];
    [self.bridge rewardedVideoAd:self.adapter didAdServerResponseWithExt:@{
        WindMillConstant.ECPM: [NSString stringWithFormat:@"%ld", (long)ecpm]
    }];

    // 通知 ToBid 广告已加载完成（可以展示）
    self.isReady = YES;
    [self.bridge rewardedVideoAdDidLoad:self.adapter];
}

/// 激励视频获取失败
- (void)rewardedVideoAdVideoLoadFailed:(MHRewardedVideoAd *)rewardedVideoAd
                           placementID:(NSString *)placementID
                             errorCode:(NSInteger)errorCode
                          errorMessage:(NSString *)errorMessage {
    NSLog(@"[WM4MH] %@ errorCode=%ld message=%@", NSStringFromSelector(_cmd), (long)errorCode, errorMessage);
    self.isReady = NO;
    NSError *error = [NSError errorWithDomain:@"MHRewardedVideoAd"
                                         code:errorCode
                                     userInfo:@{NSLocalizedDescriptionKey: errorMessage ?: @"unknown"}];
    [self.bridge rewardedVideoAd:self.adapter didLoadFailWithError:error ext:@{}];
}

/// 激励视频将要展示
- (void)rewardedVideoAdWillAppear:(MHRewardedVideoAd *)rewardedVideoAd
                      placementID:(NSString *)placementID {
    NSLog(@"[WM4MH] %@", NSStringFromSelector(_cmd));
}

/// 激励视频已经展示
- (void)rewardedVideoAdDidAppear:(MHRewardedVideoAd *)rewardedVideoAd
                     placementID:(NSString *)placementID {
    NSLog(@"[WM4MH] %@", NSStringFromSelector(_cmd));
    [self.bridge rewardedVideoAdDidVisible:self.adapter];
}

/// 激励视频已经消失（关闭后触发）
- (void)rewardedVideoAdDidDisappear:(MHRewardedVideoAd *)rewardedVideoAd
                        placementID:(NSString *)placementID {
    NSLog(@"[WM4MH] %@", NSStringFromSelector(_cmd));
    [self.bridge rewardedVideoAdDidClose:self.adapter];
}

/// 激励视频已经点击
- (void)rewardedVideoAdDidClicked:(MHRewardedVideoAd *)rewardedVideoAd
                      placementID:(NSString *)placementID {
    NSLog(@"[WM4MH] %@", NSStringFromSelector(_cmd));
    [self.bridge rewardedVideoAdDidClick:self.adapter];
}

/// 激励视频已经返回激励结果
- (void)rewardedVideoAdVideoDidRewarded:(MHRewardedVideoAd *)rewardedVideoAd
                                 result:(BOOL)success
                            placementID:(NSString *)placementID {
    NSLog(@"[WM4MH] %@ success=%d", NSStringFromSelector(_cmd), success);
    if (success) {
        WindMillRewardInfo *info = [[WindMillRewardInfo alloc] initWithIsCompeltedView:YES];
        [self.bridge rewardedVideoAd:self.adapter didRewardSuccessWithInfo:info];
    }
}

/// 激励视频已经结束
- (void)rewardedVideoAdVideoDidFinished:(MHRewardedVideoAd *)rewardedVideoAd
                            placementID:(NSString *)placementID {
    NSLog(@"[WM4MH] %@", NSStringFromSelector(_cmd));
    [self.bridge rewardedVideoAd:self.adapter didPlayFinishWithError:nil];
}

@end
