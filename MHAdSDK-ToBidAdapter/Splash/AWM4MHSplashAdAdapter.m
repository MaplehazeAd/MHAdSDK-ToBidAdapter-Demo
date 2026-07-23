//
//  WM4MHSplashAdAdapter.m
//  MHAdSDKDemo
//
//  Created by 郭建恒 on 2026/7/20.
//

#import "AWM4MHSplashAdAdapter.h"
#import "AWM4MHSplashAdListener.h"
#import <MHAdSDK/MHSplashAd.h>

@interface AWM4MHSplashAdAdapter ()

@property (nonatomic, weak) id<AWMCustomSplashAdapterBridge> bridge;
@property (nonatomic, strong) AWM4MHSplashAdListener *listener;
@property (nonatomic, strong) MHSplashAd *splashAd;
@property (nonatomic, strong) AWMParameter *parameter;

@end

@implementation AWM4MHSplashAdAdapter

- (instancetype)initWithBridge:(id<AWMCustomSplashAdapterBridge>)bridge {
    self = [super init];
    if (self) {
        _bridge = bridge;
        _listener = [[AWM4MHSplashAdListener alloc] initWithBridge:bridge adapter:self];
    }
    return self;
}

- (void)dealloc {
    NSLog(@"[WM4MH] %s", __func__);
}

#pragma mark - AWMCustomSplashAdapter

- (void)loadAdWithPlacementId:(NSString *)placementId parameter:(AWMParameter *)parameter {
    self.parameter = parameter;
    self.listener.parameter = parameter;

    self.splashAd = [[MHSplashAd alloc] initWithPlacementID:placementId];

    self.splashAd.delegate = self.listener;

    // 从 parameter.extra 取期望尺寸，没有则用屏幕尺寸
    NSValue *sizeValue = [parameter.extra objectForKey:WindMillConstant.AdSize];
    CGSize adSize = [sizeValue CGSizeValue];
    if (adSize.width * adSize.height == 0) {
        UIView *bottomView = [parameter.extra objectForKey:WindMillConstant.BottomView];
        CGFloat bottomH = bottomView ? CGRectGetHeight(bottomView.frame) : 0;
        CGRect screenBounds = [UIScreen mainScreen].bounds;
        adSize = CGSizeMake(screenBounds.size.width, screenBounds.size.height - bottomH);
    }
    self.splashAd.viewSize = adSize;

    // rootController 用于展示落地页等
    UIViewController *rootVC = [self.bridge viewControllerForPresentingModalView];
    self.splashAd.rootController = rootVC;

    [self.splashAd loadAd];
}

- (void)showSplashAdInWindow:(UIWindow *)window parameter:(AWMParameter *)parameter {
    UIView *bottomView = [parameter.extra objectForKey:WindMillConstant.BottomView];
    BOOL shown = [self.splashAd showInWindow:window withBottomView:bottomView skipView:nil];
    if (!shown) {
        NSError *error = [NSError errorWithDomain:@"MHSplashAd" code:-1 userInfo:nil];
        [self.bridge splashAdDidShowFailed:self error:error];
    }
}

#pragma mark - AWMCustomAdapter

- (BOOL)mediatedAdStatus {
    return self.listener.isReady;
}

- (void)didReceiveBidResult:(AWMMediaBidResult *)result {
    if (result.win) {
        [self.splashAd sendWinNotification:(NSInteger)result.winnerPrice];
    } else {
        [self.splashAd sendLossNotification:0];
    }
}

- (NSDictionary *)getMediaExt {
    NSMutableDictionary *ext = [NSMutableDictionary dictionary];
    MHAdExtraInfo *info = [self.splashAd getExtraInfo];
    if (info) {
        // 按需返回媒体侧信息
    }
    return ext;
}

- (void)destory {
    self.splashAd = nil;
    self.listener = nil;
}

@end
