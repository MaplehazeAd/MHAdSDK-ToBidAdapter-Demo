//
//  AWM4MHConfigAdapter.m
//  MHAdSDKDemo
//
//  Created by 郭建恒 on 2026/7/20.
//

#import "AWM4MHConfigAdapter.h"
#import <MHAdSDK/MHAdSDK.h>

@interface AWM4MHConfigAdapter ()

@property (nonatomic, weak) id<AWMCustomConfigAdapterBridge> bridge;

@end

@implementation AWM4MHConfigAdapter

- (instancetype)initWithBridge:(id<AWMCustomConfigAdapterBridge>)bridge {
    self = [super init];
    if (self) {
        _bridge = bridge;
    }
    return self;
}

#pragma mark - AWMCustomConfigAdapter

- (void)initializeAdapterWithConfiguration:(AWMSdkInitConfig *)configuration {
    // 从 extra 取 MHAdSDK 的 appID（ToBid 后台配置自定义 ADN 时填写）
    NSString *appID = [configuration.extra objectForKey:@"appID"];
    if (!appID.length) {
        appID = configuration.appID;
    }

    // 配置 MHAdConfiguration
    MHAdConfiguration *config = [MHAdConfiguration sharedConfig];
    config.appID = appID;

    // 通知 ToBid 即将开始初始化
    [self.bridge initializeAdapterBefore:self config:config];

    // 执行 MHAdSDK 注册
    BOOL success = [[MHAdManager sharedManager] registerApp];
    if (success) {
        [self.bridge initializeAdapterSuccess:self];
    } else {
        NSError *error = [NSError errorWithDomain:@"MHAdSDK"
                                             code:-1
                                         userInfo:@{NSLocalizedDescriptionKey: @"MHAdSDK registerApp failed"}];
        [self.bridge initializeAdapterFailed:self error:error];
    }
}

- (void)didRequestAdPrivacyConfigUpdate:(NSDictionary<NSString *,id> *)config {
    // 隐私配置更新，按需处理
}

- (NSString *)adapterVersion {
    return @"1.0.0";
}

- (NSString *)networkSdkVersion {
    return [[MHAdManager sharedManager] version];
}

- (AWMCustomAdapterVersion *)basedOnCustomAdapterVersion {
    return AWMCustomAdapterVersion.V2_0;
}

@end
