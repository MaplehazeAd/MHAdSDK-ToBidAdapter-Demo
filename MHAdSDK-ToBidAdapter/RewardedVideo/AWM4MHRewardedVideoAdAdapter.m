//
//  AWM4MHRewardedVideoAdAdapter.m
//  MHAdSDKDemo
//
//  Created by 郭建恒 on 2026/7/21.
//

#import "AWM4MHRewardedVideoAdAdapter.h"
#import "AWM4MHRewardedVideoAdListener.h"
#import <MHAdSDK/MHRewardedVideoAd.h>

@interface AWM4MHRewardedVideoAdAdapter ()

@property (nonatomic, weak) id<AWMCustomRewardedVideoAdapterBridge> bridge;
@property (nonatomic, strong) AWM4MHRewardedVideoAdListener *listener;
@property (nonatomic, strong) MHRewardedVideoAd *rewardedVideoAd;
@property (nonatomic, strong) AWMParameter *parameter;

@end

@implementation AWM4MHRewardedVideoAdAdapter

- (instancetype)initWithBridge:(id<AWMCustomRewardedVideoAdapterBridge>)bridge {
    self = [super init];
    if (self) {
        _bridge = bridge;
        _listener = [[AWM4MHRewardedVideoAdListener alloc] initWithBridge:bridge adapter:self];
    }
    return self;
}

- (void)dealloc {
    NSLog(@"[WM4MH] %s", __func__);
}

#pragma mark - AWMCustomRewardedVideoAdapter

- (void)loadAdWithPlacementId:(NSString *)placementId parameter:(AWMParameter *)parameter {
    self.parameter = parameter;
    self.listener.parameter = parameter;

    self.rewardedVideoAd = [[MHRewardedVideoAd alloc] initWithPlacementID:placementId];
    self.rewardedVideoAd.delegate = self.listener;

    // 优先从 bridge.adRequest.options 读取静音，其次 parameter.extra
    NSDictionary *requestOptions = [self.bridge adRequest].options;
    NSString *muteStr = requestOptions[@"MHIsMuted"];
    NSNumber *extraMuted = [parameter.extra objectForKey:@"MHIsMuted"];
    if (muteStr) {
        self.rewardedVideoAd.isMuted = [muteStr boolValue];
    } else if (extraMuted) {
        self.rewardedVideoAd.isMuted = [extraMuted boolValue];
    }

    [self.rewardedVideoAd loadAd];
}

- (void)showAdFromRootViewController:(UIViewController *)viewController parameter:(AWMParameter *)parameter {
    BOOL shown = [self.rewardedVideoAd showAdFromRootViewController:viewController];
    if (!shown) {
        NSError *error = [NSError errorWithDomain:@"MHRewardedVideoAd"
                                             code:-1
                                         userInfo:@{NSLocalizedDescriptionKey: @"Show failed"}];
        [self.bridge rewardedVideoAdDidShowFailed:self error:error];
    }
}

#pragma mark - AWMCustomAdapter

- (BOOL)mediatedAdStatus {
    return self.listener.isReady;
}

- (void)didReceiveBidResult:(AWMMediaBidResult *)result {
    if (result.win) {
        [self.rewardedVideoAd sendWinNotification:(NSInteger)result.winnerPrice];
    } else {
        [self.rewardedVideoAd sendLossNotification:0];
    }
}

- (NSDictionary *)getMediaExt {
    return @{};
}

- (void)destory {
    self.rewardedVideoAd = nil;
    self.listener = nil;
}

@end
