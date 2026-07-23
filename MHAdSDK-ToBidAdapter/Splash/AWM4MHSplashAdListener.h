//
//  WM4MHSplashAdListener.h
//  MHAdSDKDemo
//
//  Created by 郭建恒 on 2026/7/20.
//

#import <Foundation/Foundation.h>
#import <MHAdSDK/MHSplashAd.h>
#import <WindMillSDK/WindMillSDK.h>

NS_ASSUME_NONNULL_BEGIN

@interface AWM4MHSplashAdListener : NSObject <MHSplashAdDelegete>

@property (nonatomic, weak) id<AWMCustomSplashAdapterBridge> bridge;
@property (nonatomic, weak) id<AWMCustomAdapter> adapter;
@property (nonatomic, weak) AWMParameter *parameter;
@property (nonatomic, assign) BOOL isReady;

- (instancetype)initWithBridge:(id<AWMCustomSplashAdapterBridge>)bridge
                       adapter:(id<AWMCustomAdapter>)adapter;

@end

NS_ASSUME_NONNULL_END
