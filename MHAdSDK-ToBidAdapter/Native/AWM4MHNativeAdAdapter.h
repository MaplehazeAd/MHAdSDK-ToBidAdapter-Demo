//
//  AWM4MHNativeAdAdapter.h
//  MHAdSDKDemo
//
//  Created by 郭建恒 on 2026/7/21.
//

#import <UIKit/UIKit.h>
#import <WindMillSDK/WindMillSDK.h>
#import <MHAdSDK/MHNativeAd.h>

NS_ASSUME_NONNULL_BEGIN

@interface AWM4MHNativeAdAdapter : NSObject <AWMCustomNativeAdapter>

/// 获取当前活跃的 adapter 实例（ToBid 创建时自动设置）
+ (nullable instancetype)sharedInstance;

/// 最近一次加载成功的 MHNativeAd 对象，VC 在 nativeAdsManagerSuccessToLoad: 回调中读取后应置 nil
@property (nonatomic, strong, nullable) MHNativeAd *lastLoadedNativeAd;

/// 最近一次加载成功的广告模型数组，VC 在 nativeAdsManagerSuccessToLoad: 回调中读取后应置 nil
@property (nonatomic, strong, nullable) NSArray<MHNativeAdModel *> *lastLoadedModels;

/// 内部保留 models 用于竞价上报，业务侧不需要操作
@property (nonatomic, strong, nullable) NSArray<MHNativeAdModel *> *biddingModels;

@end

NS_ASSUME_NONNULL_END
