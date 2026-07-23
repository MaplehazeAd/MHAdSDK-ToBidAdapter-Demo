//
//  MHNativeListNormalCell.h
//  MHAdSDKDemo
//
//  Created by 郭建恒 on 2025/5/20.
//

#import <UIKit/UIKit.h>
#import "NativeModel.h"
#import <MHAdSDK/MHAdSDK.h>

NS_ASSUME_NONNULL_BEGIN

@interface MHNativeListAdCell : UITableViewCell

@property (nonatomic, strong) MHNativeAd *nativeAd;

- (void)setCell:(MHNativeAdModel *)nativeAdModel;


@end

NS_ASSUME_NONNULL_END
