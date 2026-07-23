//
//  NativeCouponView.m
//  MHAdSDKDemo
//
//  Created by 郭建恒 on 2026/2/27.
//

#import "NativeCouponView.h"
#import "Masonry.h"


@interface NativeCouponView ()

@property (nonatomic, strong) UIView *bottomBackgroundView;      // 底部渐变背景
@property (nonatomic, strong) UIButton *closeButton;           // 关闭按钮
@property (nonatomic, strong) UIView *adContentView;           // 内容渐变背景
@property (nonatomic, strong) CAGradientLayer *adContentGradientLayer;  // 保存引用，方便更新frame

@property (nonatomic, strong) UILabel *valueLabel;      // 优惠卷金额

@property (nonatomic, strong) UIView *lineView;      // 分割线

@property (nonatomic, strong) UILabel *thresholdLabel;      // 满多少元可用label
@property (nonatomic, strong) UILabel *timeLabel;      // 有效期
      // 有效期
@property (nonatomic, strong) MHNativeAdCouponModel *coupon;      // 有效期

@end

@implementation NativeCouponView

#pragma mark - Life Cycle

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    self.backgroundColor = [UIColor clearColor];
    
    // 1. 底部渐变背景
    [self addSubview:self.bottomBackgroundView];
    [self.bottomBackgroundView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self);
        make.height.mas_equalTo(66);
    }];
    
    // 2. 关闭按钮（右上角）
    [self addSubview:self.closeButton];
    [self.closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).mas_offset(0);
        make.right.equalTo(self).mas_offset(0);
        make.width.height.mas_equalTo(12);
    }];
    // ✅ 添加点击事件
    [self.closeButton addTarget:self
                         action:@selector(closeButtonTapped:)
               forControlEvents:UIControlEventTouchUpInside];
    
    // 3. 内容渐变背景（在 bottomBackgroundView 内部）
    [self addSubview:self.adContentView];
    [self.adContentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.bottomBackgroundView).insets(UIEdgeInsetsMake(6, 6, 6, 6));
    }];
    
    
    
    // 5. 虚线分割线
    [self.adContentView addSubview:self.lineView];
    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.adContentView);
        make.leading.equalTo(self.adContentView.mas_leading).mas_offset(100);
        make.height.mas_equalTo(40);  // 虚线高度
        make.width.mas_equalTo(2);    // 虚线宽度
    }];
    
    
    [self.adContentView addSubview:self.getButton];
    [self.getButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.adContentView);
        make.trailing.equalTo(self.adContentView.mas_trailing).mas_offset(-8);
        make.height.mas_equalTo(32);  // 虚线高度
        make.width.mas_equalTo(76);    // 虚线宽度
    }];
    
    self.valueLabel = [[UILabel alloc] init];
    self.valueLabel.textAlignment = NSTextAlignmentCenter;
    self.valueLabel.text = [NSString stringWithFormat:@"%ld 元", (long)self.coupon.couponValue];
    self.valueLabel.textColor = [self colorWithHexString:@"#FF0100"];
    self.valueLabel.font = [UIFont systemFontOfSize:22 weight:UIFontWeightBold]; // 加粗
    [self.adContentView addSubview:self.valueLabel];
    [self.valueLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.adContentView).mas_offset(10);
        make.centerY.equalTo(self.adContentView).mas_offset(0);
        make.leading.equalTo(self.adContentView.mas_leading).mas_offset(8);
        make.trailing.mas_equalTo(self.lineView.mas_leading).offset(-8);
    }];
    
    
    self.thresholdLabel = [[UILabel alloc] init];
    self.thresholdLabel.textAlignment = NSTextAlignmentLeft;
    
    self.thresholdLabel.textColor = [self colorWithHexString:@"#801108"];
    self.thresholdLabel.font = [UIFont systemFontOfSize:18 weight:UIFontWeightBold]; // 加粗
    [self.adContentView addSubview:self.thresholdLabel];
    [self.thresholdLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.adContentView).mas_offset(6);
        make.height.mas_equalTo(22);
        make.leading.equalTo(self.lineView.mas_trailing).mas_offset(13);
        make.trailing.mas_equalTo(self.getButton.mas_leading).offset(-8);
    }];

    self.timeLabel = [[UILabel alloc] init];
    self.timeLabel.textAlignment = NSTextAlignmentLeft;
    self.timeLabel.textColor = [self colorWithHexString:@"#801108"];
    self.timeLabel.font = [UIFont systemFontOfSize:14 ]; // 加粗
    [self.adContentView addSubview:self.timeLabel];
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.thresholdLabel.mas_bottom).mas_offset(1);
        make.height.mas_equalTo(17);
        make.leading.trailing.equalTo(self.thresholdLabel);
    }];
    
}

- (void)updateUIWithCouponModel:(MHNativeAdCouponModel *)coupon
{
    self.coupon = coupon;
    // gengxin UI
    NSString * yuanString = [self convertFenToYuanString:self.coupon.couponValue shouldFormat:NO];
    self.valueLabel.text = [NSString stringWithFormat:@"%@ 元", yuanString];
    
    NSString * thresholdString = [self convertFenToYuanString:self.coupon.couponThreshold shouldFormat:NO];
    self.thresholdLabel.text = [NSString stringWithFormat:@"满%@元可用", thresholdString];
    
    self.timeLabel.text = [NSString stringWithFormat:@"%ld分钟内有效", self.coupon.couponTime];
}

#pragma mark - Layout

- (void)layoutSubviews {
    [super layoutSubviews];
    
    // 更新底部背景渐变层
    CAGradientLayer *bgGradient = (CAGradientLayer *)self.bottomBackgroundView.layer.sublayers.firstObject;
    bgGradient.frame = self.bottomBackgroundView.bounds;
    
    // ✅ 修复：使用保存的引用更新 adContentView 的渐变层
    self.adContentGradientLayer.frame = self.adContentView.bounds;
}

#pragma mark - Actions

/// 关闭按钮点击
- (void)closeButtonTapped:(UIButton *)sender {
    // 回调代理
    if ([self.delegate respondsToSelector:@selector(nativeCouponViewDidClickClose:)]) {
        [self.delegate nativeCouponViewDidClickClose:self];
    }
}

#pragma mark - Getters

- (UIView *)bottomBackgroundView {
    if (!_bottomBackgroundView) {
        _bottomBackgroundView = [[UIView alloc] init];
        _bottomBackgroundView.layer.cornerRadius = 13;
        _bottomBackgroundView.layer.masksToBounds = YES;
        
        // 左上角 -> 右下角渐变 #FE5876 -> #F45B54
        CAGradientLayer *gradientLayer = [CAGradientLayer layer];
        gradientLayer.colors = @[
            (__bridge id)[self colorWithHexString:@"#FE5876"].CGColor,
            (__bridge id)[self colorWithHexString:@"#F45B54"].CGColor
        ];
        gradientLayer.startPoint = CGPointMake(0, 0);
        gradientLayer.endPoint = CGPointMake(1, 1);
        [_bottomBackgroundView.layer addSublayer:gradientLayer];
    }
    return _bottomBackgroundView;
}

- (UIButton *)closeButton {
    if (!_closeButton) {
        _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _closeButton.layer.cornerRadius = 6;
        [_closeButton setBackgroundImage:[UIImage imageNamed:@"coupon_close"] forState:UIControlStateNormal];
        _closeButton.layer.masksToBounds = YES;
        _closeButton.backgroundColor = [UIColor lightGrayColor];
    }
    return _closeButton;
}

- (UIView *)lineView {
    if (!_lineView) {
        _lineView = [[UIView alloc] init];
        
        // 创建虚线层
        CAShapeLayer *dashLayer = [CAShapeLayer layer];
        dashLayer.strokeColor = [[self colorWithHexString:@"#B36F63"] colorWithAlphaComponent:0.5].CGColor;
        dashLayer.lineWidth = 2;
        dashLayer.lineDashPattern = @[@2, @1.8]; // 4pt 实线，4pt 空白（可调整）
        dashLayer.fillColor = [UIColor clearColor].CGColor;
        
        // 设置路径（竖线）
        UIBezierPath *path = [UIBezierPath bezierPath];
        [path moveToPoint:CGPointMake(1, 0)];    // 顶部居中（width=2，所以x=1）
        [path addLineToPoint:CGPointMake(1, 40)]; // 底部
        
        dashLayer.path = path.CGPath;
        [_lineView.layer addSublayer:dashLayer];
        
    }
    return _lineView;
}

- (UIButton *)getButton {
    if (!_getButton) {
        _getButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _getButton.layer.cornerRadius = 6;
        _getButton.layer.masksToBounds = YES;
        _getButton.backgroundColor = [self colorWithHexString:@"#FFC24D"];
        [_getButton setTitle:@"立即领取" forState:UIControlStateNormal];
        [_getButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _getButton.titleLabel.font = [UIFont systemFontOfSize:16];
    }
    return _getButton;
}

- (UIView *)adContentView {
    if (!_adContentView) {
        _adContentView = [[UIView alloc] init];
        _adContentView.layer.cornerRadius = 13;
        // ✅ 关键：先添加渐变层，最后再设置 masksToBounds
        // 或者给渐变层一个默认的 frame
        
        CAGradientLayer *gradientLayer = [CAGradientLayer layer];
        gradientLayer.colors = @[
            (__bridge id)[self colorWithHexString:@"#FDE79F"].CGColor,
            (__bridge id)[self colorWithHexString:@"#FFFFFF"].CGColor
        ];
        gradientLayer.startPoint = CGPointMake(0, 0.5);
        gradientLayer.endPoint = CGPointMake(1, 0.5);
        
        // ✅ 关键：先设置一个默认 frame，避免被 masksToBounds 裁掉
        gradientLayer.frame = CGRectMake(0, 0, 1000, 100); // 足够大的默认值
        
        [_adContentView.layer addSublayer:gradientLayer];
        self.adContentGradientLayer = gradientLayer;
        
        // ✅ 最后设置 masksToBounds
        _adContentView.layer.masksToBounds = YES;
    }
    return _adContentView;
}

- (UIColor *)colorWithHexString:(NSString *)hexString {
    NSString *cleanString = [hexString stringByReplacingOccurrencesOfString:@"#" withString:@""];
    unsigned int hexValue;
    [[NSScanner scannerWithString:cleanString] scanHexInt:&hexValue];
    
    return [UIColor colorWithRed:((hexValue & 0xFF0000) >> 16) / 255.0
                           green:((hexValue & 0x00FF00) >> 8) / 255.0
                            blue:(hexValue & 0x0000FF) / 255.0
                           alpha:1.0];
}

- (NSString *)convertFenToYuanString:(NSInteger)fen shouldFormat:(BOOL)shouldFormat {
    // 转换为 NSDecimalNumber
    NSDecimalNumber *fenNumber = [NSDecimalNumber decimalNumberWithDecimal:@(fen).decimalValue];
    NSDecimalNumber *divisor = [NSDecimalNumber decimalNumberWithDecimal:@(100).decimalValue];
    NSDecimalNumber *yuanNumber = [fenNumber decimalNumberByDividingBy:divisor];
    
    if (shouldFormat) {
        // 格式化：总是显示两位小数
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        formatter.numberStyle = NSNumberFormatterDecimalStyle;
        formatter.minimumFractionDigits = 2;
        formatter.maximumFractionDigits = 2;
        formatter.alwaysShowsDecimalSeparator = YES;
        formatter.usesGroupingSeparator = NO;
        
        return [formatter stringFromNumber:yuanNumber];
    } else {
        // 非格式化：去掉末尾的零
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        formatter.numberStyle = NSNumberFormatterDecimalStyle;
        formatter.minimumFractionDigits = 0;  // 最少0位小数
        formatter.maximumFractionDigits = 2;  // 最多2位小数
        formatter.usesGroupingSeparator = NO;
        
        // 只有当有小数部分时才显示小数点
        if (fen % 100 == 0) {
            formatter.alwaysShowsDecimalSeparator = NO;
        } else {
            formatter.alwaysShowsDecimalSeparator = YES;
        }
        
        return [formatter stringFromNumber:yuanNumber];
    }
}


@end
