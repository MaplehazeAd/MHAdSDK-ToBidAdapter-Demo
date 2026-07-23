//
//  AWM4MHRewardedVideoAdListener.h
//  MHAdSDKDemo
//
//  Created by 郭建恒 on 2026/7/21.
//

#import <Foundation/Foundation.h>
#import <MHAdSDK/MHRewardedVideoAd.h>
#import <WindMillSDK/WindMillSDK.h>

NS_ASSUME_NONNULL_BEGIN

@interface AWM4MHRewardedVideoAdListener : NSObject <MHRewardedVideoAdDelegete>

@property (nonatomic, weak) id<AWMCustomRewardedVideoAdapterBridge> bridge;
@property (nonatomic, weak) id<AWMCustomAdapter> adapter;
@property (nonatomic, weak) AWMParameter *parameter;
@property (nonatomic, assign) BOOL isReady;

- (instancetype)initWithBridge:(id<AWMCustomRewardedVideoAdapterBridge>)bridge
                       adapter:(id<AWMCustomAdapter>)adapter;

@end

NS_ASSUME_NONNULL_END
