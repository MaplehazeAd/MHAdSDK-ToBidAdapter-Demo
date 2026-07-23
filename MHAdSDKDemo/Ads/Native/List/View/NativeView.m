//
//  Ad2048View.m
//  MHAdSDKDemo
//
//  Created by 郭建恒 on 2025/1/9.
//

#import "NativeView.h"
#import "Masonry.h"


@implementation NativeView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.layer.cornerRadius = 8;
        [self layoutAllSubviews];
    }
    return self;
}

- (void)layoutAllSubviews
{
    
    self.iconImageView = [[UIImageView alloc]init];
    self.iconImageView.layer.cornerRadius = 8;
    self.iconImageView.layer.masksToBounds = YES;
    [self addSubview:self.iconImageView];
    [self.iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self).offset(8);
        make.top.equalTo(self).offset(8);
        make.width.height.mas_equalTo(40);
    }];
    
    self.adButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.adButton.backgroundColor = [UIColor whiteColor];
    self.adButton.layer.borderWidth = 1;
    self.adButton.layer.cornerRadius = 8;
    self.adButton.layer.borderColor = [UIColor blueColor].CGColor;
    [self.adButton setTitle:@"立即下载" forState:UIControlStateNormal];
    [self.adButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [self addSubview:self.adButton];
    [self.adButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self.mas_trailing).offset(-9);
        make.centerY.equalTo(self.iconImageView);
        make.width.mas_equalTo(80);
        make.height.mas_equalTo(32);
    }];

    self.titleLabel = [[UILabel alloc]init];
    self.titleLabel.text = @"title";
    self.titleLabel.font = [UIFont systemFontOfSize:15];
    [self addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.iconImageView.mas_trailing).offset(8);
        make.centerY.equalTo(self.iconImageView);
        make.height.mas_equalTo(32);
        make.width.mas_equalTo(200);
    }];
    
    CGFloat adWidth = [[UIScreen mainScreen] bounds].size.width - 32;
    CGFloat adHeight = adWidth / 16 * 9;
    
    self.adView = [[MHNativeAdView alloc]init];
    self.adView.tag = self.tag;
    
    [self addSubview:self.adView];
    [self.adView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.iconImageView.mas_bottom).offset(8);
        make.leading.equalTo(self.iconImageView);
        make.width.mas_equalTo(adWidth);
        make.height.mas_equalTo(adHeight);
    }];
    
    
    [self.adView layoutIfNeeded];

    self.descriptionLabel = [[UILabel alloc]init];
    self.descriptionLabel.text = @"des";
    self.descriptionLabel.font = [UIFont systemFontOfSize:13];
    [self addSubview:self.descriptionLabel];
    [self.descriptionLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.iconImageView);
        make.width.mas_equalTo(220);
        make.top.equalTo(self.adView.mas_bottom).offset(4);
        make.height.mas_equalTo(30);
    }];
    
    UIView * logoView = [[UIView alloc]init];
    logoView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    logoView.layer.cornerRadius = 4;
    [self addSubview:logoView];
    [logoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self.adButton);
        make.centerY.equalTo(self.descriptionLabel);
        make.width.mas_equalTo(64);
        make.height.mas_equalTo(24);
    }];
    
    self.logoImageView = [[UIImageView alloc]init];
    self.logoImageView.layer.cornerRadius = 8;
    self.logoImageView.layer.masksToBounds = YES;
    self.logoImageView.image = [UIImage imageNamed:@"maplehaze_logo.png"];
    [logoView addSubview:self.logoImageView];
    [self.logoImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(logoView.mas_leading).offset(4);
        make.centerY.equalTo(self.descriptionLabel);
        make.width.height.mas_equalTo(18);
    }];
    
    self.adLabel = [[UILabel alloc]init];
    self.adLabel.text = @"枫岚广告";
    self.adLabel.textColor = [UIColor colorWithRed:200/255.0 green:200/255.0 blue:200/255.0 alpha:1.0];
    self.adLabel.textAlignment = NSTextAlignmentCenter;
    self.adLabel.font = [UIFont systemFontOfSize:9];
    [self addSubview:self.adLabel];
    [self.adLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.descriptionLabel);
        make.height.mas_equalTo(24);
        make.width.mas_equalTo(40);
        make.trailing.equalTo(logoView.mas_trailing).offset(-4);
    }];
    
}


- (void)updateTag:(NSInteger )tag{
    self.adView.tag = tag;
    NSLog(@"设置的tag: %ld", (long)self.adView.tag);
}

@end
