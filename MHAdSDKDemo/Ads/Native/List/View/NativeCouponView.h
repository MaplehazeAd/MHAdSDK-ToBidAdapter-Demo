//
//  NativeCouponView.h
//  MHAdSDKDemo
//
//  Created by 郭建恒 on 2026/2/27.
//

#import <UIKit/UIKit.h>
#import <MHAdSDK/MHAdSDK.h>

NS_ASSUME_NONNULL_BEGIN

@class NativeCouponView;

@protocol NativeCouponViewDelegate <NSObject>

@optional
/// 点击关闭按钮
- (void)nativeCouponViewDidClickClose:(NativeCouponView *)couponView;

@end

@interface NativeCouponView : UIView

@property (nonatomic, strong) UIButton *getButton;
@property (nonatomic, weak) id<NativeCouponViewDelegate> delegate;  // 代理

- (void)updateUIWithCouponModel:(MHNativeAdCouponModel *)coupon;

@end

NS_ASSUME_NONNULL_END
