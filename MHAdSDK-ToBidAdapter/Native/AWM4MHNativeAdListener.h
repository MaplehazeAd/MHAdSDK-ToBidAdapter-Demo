//
//  AWM4MHNativeAdListener.h
//  MHAdSDKDemo
//
//  Created by 郭建恒 on 2026/7/21.
//

#import <Foundation/Foundation.h>
#import <MHAdSDK/MHNativeAd.h>
#import <WindMillSDK/WindMillSDK.h>

NS_ASSUME_NONNULL_BEGIN

@interface AWM4MHNativeAdListener : NSObject <MHNativeAdDelegete>

@property (nonatomic, weak) id<AWMCustomNativeAdapterBridge> bridge;
@property (nonatomic, weak) id<AWMCustomNativeAdapter> adapter;
@property (nonatomic, weak) AWMParameter *parameter;
@property (nonatomic, assign) BOOL isReady;
/// MHNativeAdModel → AWMMediatedNativeAd 映射
@property (nonatomic, strong) NSMapTable<MHNativeAdModel *, AWMMediatedNativeAd *> *modelToMediatedAd;

- (instancetype)initWithBridge:(id<AWMCustomNativeAdapterBridge>)bridge
                       adapter:(id<AWMCustomNativeAdapter>)adapter;

@end

NS_ASSUME_NONNULL_END
