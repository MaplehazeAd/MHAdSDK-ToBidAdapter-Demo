//
//  AWM4MHNativeAdAdapter.m
//  MHAdSDKDemo
//
//  Created by 郭建恒 on 2026/7/21.
//

#import "AWM4MHNativeAdAdapter.h"
#import "AWM4MHNativeAdListener.h"
#import <MHAdSDK/MHNativeAd.h>
#import <MHAdSDK/MHNativeAdModel.h>

static __weak AWM4MHNativeAdAdapter *_sharedInstance = nil;

@interface AWM4MHNativeAdAdapter ()

@property (nonatomic, weak) id<AWMCustomNativeAdapterBridge> bridge;
@property (nonatomic, strong) AWM4MHNativeAdListener *listener;
@property (nonatomic, strong) MHNativeAd *nativeAd;
@property (nonatomic, strong) AWMParameter *parameter;

@end

@implementation AWM4MHNativeAdAdapter

+ (nullable instancetype)sharedInstance {
    return _sharedInstance;
}

- (instancetype)initWithBridge:(id<AWMCustomNativeAdapterBridge>)bridge {
    self = [super init];
    if (self) {
        _bridge = bridge;
        _listener = [[AWM4MHNativeAdListener alloc] initWithBridge:bridge adapter:self];
        _sharedInstance = self;
    }
    return self;
}

- (void)dealloc {
    NSLog(@"[WM4MH] %s", __func__);
}

#pragma mark - AWMCustomNativeAdapter

- (void)loadAdWithPlacementId:(NSString *)placementId adSize:(CGSize)adSize parameter:(AWMParameter *)parameter {
    self.parameter = parameter;
    self.listener.parameter = parameter;

    self.nativeAd = [[MHNativeAd alloc] initWithPlacementID:placementId];
    // 优先从 bridge.adRequest.options 读取静音，其次 parameter.extra
    NSDictionary *requestOptions = [self.bridge adRequest].options;
    NSString *muteStr = requestOptions[@"MHIsMuted"];
    NSNumber *extraMuted = [parameter.extra objectForKey:@"MHIsMuted"];
    if (muteStr) {
        self.nativeAd.isMuted = [muteStr boolValue];
    } else if (extraMuted) {
        self.nativeAd.isMuted = [extraMuted boolValue];
    }
//    self.nativeAd.isMuted = NO;
    self.nativeAd.delegate = self.listener;

    // 优先从 bridge.adRequest.options 读取自动播放，其次 parameter.extra
    NSString *autoPlayStr = requestOptions[@"MHAutoPlayMobileNetwork"];
    NSNumber *extraAutoPlay = [parameter.extra objectForKey:@"MHAutoPlayMobileNetwork"];
    if (autoPlayStr) {
        [self.nativeAd updateAutoPlay:[autoPlayStr boolValue]];
    } else if (extraAutoPlay) {
        [self.nativeAd updateAutoPlay:[extraAutoPlay boolValue]];
    }

    NSNumber *loadCount = [parameter.extra objectForKey:WindMillConstant.LoadAdCount];
    NSInteger count = loadCount ? [loadCount integerValue] : 1;
    if (count > 1) {
        [self.nativeAd loadAdWithCount:MIN(count, 3)];
    } else {
        [self.nativeAd loadAd];
    }
}

#pragma mark - AWMCustomAdapter

- (BOOL)mediatedAdStatus {
    return self.listener.isReady;
}

- (void)didReceiveBidResult:(AWMMediaBidResult *)result {
    for (MHNativeAdModel *model in self.biddingModels) {
        if (result.win) {
            [model sendWinNotification:(NSInteger)result.winnerPrice];
        } else {
            [model sendLossNotification:0];
        }
    }
}

- (NSDictionary *)getMediaExt {
    return @{};
}

- (void)destory {
    self.nativeAd = nil;
    self.listener = nil;
    self.lastLoadedNativeAd = nil;
    self.lastLoadedModels = nil;
    self.biddingModels = nil;
}

@end
