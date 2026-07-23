//
//  AWM4MHNativeAdListener.m
//  MHAdSDKDemo
//
//  Created by 郭建恒 on 2026/7/21.
//

#import "AWM4MHNativeAdListener.h"
#import "AWM4MHNativeAdAdapter.h"
#import <MHAdSDK/MHNativeAd.h>
#import <MHAdSDK/MHNativeAdModel.h>
#import <MHAdSDK/MHNativeAdView.h>

@interface AWM4MHNativeAdData : NSObject <AWMMediatedNativeAdData>

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *desc;
@property (nonatomic, copy) NSString *iconUrl;
@property (nonatomic, copy) NSString *callToAction;
@property (nonatomic) CGFloat rating;
@property (nonatomic, copy) NSArray<NSString *> *imageUrlList;
@property (nonatomic) AWMMediatedNativeAdMode adMode;
@property (nonatomic) AWMNativeAdSlotAdType adType;
@property (nonatomic) AWMNativeAdInteractionType interactionType;
@property (nonatomic) WindMillAdn networkId;
@property (nonatomic, strong) AWMADImage *videoCoverImage;
@property (nonatomic, copy) NSString *videoUrl;
@property (nonatomic, copy) NSArray<AWMADImage *> *imageModelList;
@property (nonatomic, copy) NSDictionary<NSString *, NSString *> *saasChannelInfo;

- (instancetype)initWithNativeAdModel:(MHNativeAdModel *)model;

@end

@implementation AWM4MHNativeAdData

- (instancetype)initWithNativeAdModel:(MHNativeAdModel *)model {
    self = [super init];
    if (self) {
        _title = model.title.length > 0 ? model.title : model.actionText;
        _desc = model.description;
        _iconUrl = model.iconURL;
        _callToAction = model.actionText.length > 0 ? model.actionText : @"查看详情";
        _rating = 0;
        _imageUrlList = model.imageURL.length > 0 ? @[model.imageURL] : @[];
        _adMode = model.isVideoAd ? AWMMediatedNativeAdModeVideoLandSpace : AWMMediatedNativeAdModeLargeImage;
        _adType = AWMNativeAdSlotAdTypeFeed;
        _interactionType = AWMNativeAdInteractionTypeCustorm;
        _networkId = WindMillAdnNone;
    }
    return self;
}

@end

@interface AWM4MHNativeAdViewCreator : NSObject <AWMMediatedNativeAdViewCreator>

@property (nonatomic, strong) MHNativeAd *nativeAd;
@property (nonatomic, strong) MHNativeAdModel *nativeAdModel;
@property (nonatomic, strong) MHNativeAdView *registeredAdView;
@property (nonatomic, strong) UIImageView *mainImageView;
@property (nonatomic, strong) UIImageView *adLogoImageView;
@property (nonatomic, strong) UIButton *innerDislikeBtn;

- (instancetype)initWithNativeAd:(MHNativeAd *)nativeAd nativeAdModel:(MHNativeAdModel *)nativeAdModel;

@end

@implementation AWM4MHNativeAdViewCreator

- (instancetype)initWithNativeAd:(MHNativeAd *)nativeAd nativeAdModel:(MHNativeAdModel *)nativeAdModel {
    self = [super init];
    if (self) {
        _nativeAd = nativeAd;
        _nativeAdModel = nativeAdModel;
        _mainImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _mainImageView.contentMode = UIViewContentModeScaleAspectFill;
        _mainImageView.clipsToBounds = YES;
        _adLogoImageView = [[UIImageView alloc] initWithImage:[nativeAdModel getAdLogoDrawableRes]];
        _innerDislikeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    }
    return self;
}

- (UIView *)mediaView {
    return self.registeredAdView;
}

- (UIView *)adLogoView {
    return self.adLogoImageView;
}

- (UIButton *)dislikeBtn {
    return self.innerDislikeBtn;
}

- (UIImageView *)imageView {
    return self.mainImageView;
}

- (NSArray<UIImageView *> *)imageViewArray {
    return self.mainImageView ? @[self.mainImageView] : @[];
}

- (void)refreshData {
    self.registeredAdView.nativeAdModel = self.nativeAdModel;
}

- (void)setRootViewController:(UIViewController *)viewController {
    self.nativeAd.rootController = viewController;
}

- (void)registerContainer:(UIView *)containerView withClickableViews:(NSArray<UIView *> *)clickableViews configuration:(WindMillAdViewActionConfiguration *)configuration {
    [self registerContainer:containerView withClickableViews:clickableViews];
}

- (void)registerContainer:(UIView *)containerView withClickableViews:(NSArray<UIView *> *)clickableViews {
    if (!containerView) {
        return;
    }

    MHNativeAdView *adView = nil;
    if ([containerView isKindOfClass:[MHNativeAdView class]]) {
        adView = (MHNativeAdView *)containerView;
    } else {
        if (!self.registeredAdView) {
            self.registeredAdView = [[MHNativeAdView alloc] initWithFrame:containerView.bounds];
            self.registeredAdView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        }
        if (self.registeredAdView.superview != containerView) {
            [self.registeredAdView removeFromSuperview];
            self.registeredAdView.frame = containerView.bounds;
            [containerView insertSubview:self.registeredAdView atIndex:0];
        }
        adView = self.registeredAdView;
    }

    adView.nativeAdModel = self.nativeAdModel;
    NSArray<UIView *> *validClickableViews = clickableViews.count > 0 ? clickableViews : @[containerView];
    BOOL success = [self.nativeAd showInViews:@[adView] withClickableViewsArray:@[validClickableViews]];
    if (!success) {
        NSLog(@"[WM4MH] native registerContainer failed model=%p", self.nativeAdModel);
    }
}

- (void)unregisterDataObject {
    [self.nativeAd unregisterView];
    [self.registeredAdView removeFromSuperview];
    self.registeredAdView = nil;
}

- (void)setPlaceholderImage:(UIImage *)placeholderImage {
    self.mainImageView.image = placeholderImage;
}

@end

@implementation AWM4MHNativeAdListener

- (instancetype)initWithBridge:(id<AWMCustomNativeAdapterBridge>)bridge
                       adapter:(id<AWMCustomNativeAdapter>)adapter {
    self = [super init];
    if (self) {
        _bridge = bridge;
        _adapter = adapter;
        _modelToMediatedAd = [NSMapTable weakToStrongObjectsMapTable];
    }
    return self;
}

#pragma mark - MHNativeAdDelegete

// 广告已经收到
- (void)nativeAdDidLoad:(MHNativeAd *)nativeAd
            placementID:(NSString *)placementID
         nativeAdModels:(NSArray<MHNativeAdModel *> *)nativeAdModels {
    NSLog(@"[WM4MH] %@ count=%lu", NSStringFromSelector(_cmd), (unsigned long)nativeAdModels.count);

    
    
    if (nativeAdModels.count == 0) {
        self.isReady = NO;
        NSError *error = [NSError errorWithDomain:@"MHNativeAd"
                                             code:-2
                                         userInfo:@{NSLocalizedDescriptionKey: @"No fill"}];
        [self.bridge nativeAd:self.adapter didLoadFailWithError:error];
        return;
    }

    NSInteger ecpm = nativeAdModels.firstObject.ecpm;
    NSLog(@"[WM4MH] native ad ecpm: %ld", ecpm);
    [self.bridge nativeAd:self.adapter didAdServerResponseWithExt:@{
        WindMillConstant.ECPM: [NSString stringWithFormat:@"%ld", (long)ecpm]
    }];

    AWM4MHNativeAdAdapter *adapter = (AWM4MHNativeAdAdapter *)self.adapter;
    adapter.lastLoadedNativeAd = nativeAd;
    adapter.lastLoadedModels = nativeAdModels;
    adapter.biddingModels = nativeAdModels;

    NSMutableArray<AWMMediatedNativeAd *> *mediatedAds = [NSMutableArray arrayWithCapacity:nativeAdModels.count];
    [self.modelToMediatedAd removeAllObjects];
    for (MHNativeAdModel *model in nativeAdModels) {
        AWM4MHNativeAdData *data = [[AWM4MHNativeAdData alloc] initWithNativeAdModel:model];
        AWM4MHNativeAdViewCreator *viewCreator = [[AWM4MHNativeAdViewCreator alloc] initWithNativeAd:nativeAd nativeAdModel:model];
        AWMMediatedNativeAd *mediatedAd = [[AWMMediatedNativeAd alloc] initWithData:data
                                                                       viewCreator:viewCreator
                                                                           originAd:model];
        NSLog(@"================ LOAD ================");
        NSLog(@"model          : %p", model);
        NSLog(@"mediatedAd     : %p", mediatedAd);
        NSLog(@"origin         : %p", mediatedAd.originMediatedNativeAd);
        NSLog(@"viewCreator    : %p", viewCreator);
        NSLog(@"nativeAd       : %p", nativeAd);
        NSLog(@"======================================");
        [self.modelToMediatedAd setObject:mediatedAd forKey:model];
        [mediatedAds addObject:mediatedAd];
    }

    self.isReady = YES;
    [self.bridge nativeAd:self.adapter didLoadWithNativeAds:mediatedAds];
    
    NSLog(@"============= LOAD =============");
    NSLog(@"bridge  : %p", self.bridge);
    NSLog(@"adapter : %p", self.adapter);
    NSLog(@"================================");
}

// 广告获取出现错误
- (void)nativeAdLoadFailed:(MHNativeAd *)nativeAd
               placementID:(NSString *)placementID
                 errorCode:(NSInteger)errorCode
              errorMessage:(NSString *)errorMessage {
    NSLog(@"[WM4MH] %@ errorCode=%ld message=%@", NSStringFromSelector(_cmd), (long)errorCode, errorMessage);
    self.isReady = NO;
    NSError *error = [NSError errorWithDomain:@"MHNativeAd"
                                         code:errorCode
                                     userInfo:@{NSLocalizedDescriptionKey: errorMessage ?: @"unknown"}];
    [self.bridge nativeAd:self.adapter didLoadFailWithError:error];
}

/// 广告已经展示
- (void)nativeAdDidAppear:(MHNativeAd *)nativeAd
              placementID:(NSString *)placementID
                   adView:(MHNativeAdView *)adView
            nativeAdModel:(MHNativeAdModel *)nativeAdModel {
    NSLog(@"[WM4MH] %@ model=%p", NSStringFromSelector(_cmd), nativeAdModel);

    [self.bridge nativeAd:self.adapter
    didVisibleWithMediatedNativeAd:nativeAdModel];
    

}

/// 广告已经被点击
- (void)nativeAdDidClick:(MHNativeAd *)nativeAd
             placementID:(NSString *)placementID
                  adView:(MHNativeAdView *)adView
           nativeAdModel:(MHNativeAdModel *)nativeAdModel {
    NSLog(@"[WM4MH] %@ model=%p", NSStringFromSelector(_cmd), nativeAdModel);
    [self.bridge nativeAd:self.adapter didClickWithMediatedNativeAd:nativeAdModel];
}

/// 广告开始播放（视频类型）
- (void)nativeAdPlayStart:(MHNativeAd *)nativeAd
              placementID:(NSString *)placementID
                   adView:(MHNativeAdView *)adView
            nativeAdModel:(MHNativeAdModel *)nativeAdModel {
    NSLog(@"[WM4MH] %@", NSStringFromSelector(_cmd));
    [self.bridge nativeAd:self.adapter videoStateDidChangedWithState:WindMillMediaPlayerStatusStarted andNativeAd:nativeAdModel];
}

/// 广告播放结束（视频类型）
- (void)nativeAdPlayFinish:(MHNativeAd *)nativeAd
               placementID:(NSString *)placementID
                    adView:(MHNativeAdView *)adView
             nativeAdModel:(MHNativeAdModel *)nativeAdModel {
    NSLog(@"[WM4MH] %@", NSStringFromSelector(_cmd));
    [self.bridge nativeAd:self.adapter videoStateDidChangedWithState:WindMillMediaPlayerStatusFinished andNativeAd:nativeAdModel];
}

/// 广告详情页已展示
- (void)nativeAdDetailViewDidAppear:(MHNativeAd *)nativeAd
                        placementID:(NSString *)placementID
                             adView:(MHNativeAdView *)adView
                      nativeAdModel:(MHNativeAdModel *)nativeAdModel {
    NSLog(@"[WM4MH] %@", NSStringFromSelector(_cmd));
    [self.bridge nativeAd:self.adapter willPresentFullScreenModalWithMediatedNativeAd:nativeAdModel];
}

/// 广告详情页已关闭
- (void)nativeAdDetailViewDidClose:(MHNativeAd *)nativeAd
                       placementID:(NSString *)placementID
                            adView:(MHNativeAdView *)adView
                     nativeAdModel:(MHNativeAdModel *)nativeAdModel {
    NSLog(@"[WM4MH] %@", NSStringFromSelector(_cmd));
    [self.bridge nativeAd:self.adapter didDismissFullScreenModalWithMediatedNativeAd:nativeAdModel
                                                                      interactionType:WindMillInteractionTypePage];
}

@end
