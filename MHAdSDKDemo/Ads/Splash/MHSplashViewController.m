//
//  MHSplashViewController.m
//  MHAdSDKDemo
//
//  Created by 郭建恒 on 2024/11/21.
//

#import "MHSplashViewController.h"
#import <WindMillSDK/WindMillSDK.h>

#import "NativeView.h"
#import "Masonry.h"
#import "MHCommonTableViewCell.h"
#import "UIView+toast.h"

@interface MHSplashViewController ()<UITableViewDelegate, UITableViewDataSource, MHCommonTableViewCellDelegate, WindMillSplashAdDelegate>

@property (nonatomic, strong) UITableView* splashTableView;

@property (nonatomic, strong) NSMutableArray * dataArray;

@property (nonatomic, copy) NSString * adID;

@property (nonatomic, strong) WindMillSplashAd *splashAd;

@property (nonatomic, strong) UIView *bottomView;

@end

@implementation MHSplashViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"开屏广告";
    self.view.backgroundColor = [UIColor colorWithRed:240/255.0 green:240/255.0 blue:240/255.0 alpha:1.0];
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"返回"
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(backButtonTapped)];
    backButton.accessibilityIdentifier = @"MHSplashViewController_BackButtonItem";
    self.navigationItem.leftBarButtonItem = backButton;
    // Do any additional setup after loading the view.
    // 添加点击手势来收回键盘
    [self addTapGestureToDismissKeyboard];
    
    [self getData];
    [self layoutAllSubviews];
    
    
}

- (BOOL)shouldAutorotate {
    return NO; // 禁止自动旋转
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait; // 只支持竖屏
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait; // 默认以竖屏方式呈现
}

- (void)backButtonTapped{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)layoutAllSubviews {
        
    [self.view addSubview:self.splashTableView];
    [self.splashTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.width.height.equalTo(self.view);
    }];
    
    [self.splashTableView reloadData];
    
}

// 添加点击手势
- (void)addTapGestureToDismissKeyboard {
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    // 设置cancelsTouchesInView为NO，确保不影响其他控件的触摸事件
    tapGesture.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapGesture];
}

// 处理点击事件
- (void)handleTap:(UITapGestureRecognizer *)gesture {
    // 收回键盘
    [self.view endEditing:YES];
    
    // 如果还有其他需要收回的第一响应者，可以在这里添加
    // [self.someTextField resignFirstResponder];
}

- (void)getData {
    
    self.dataArray = [NSMutableArray array];
    NSMutableArray * configArray = [NSMutableArray array];
    
    // ToBid 广告位id（需要在 ToBid 后台配置好 MHAdSDK 作为自定义 ADN）
    MHCommonCellModel * idModel = [[MHCommonCellModel alloc] init];
    idModel.cellType = MHCommonCellTypeTextField;
    idModel.title = @"广告位id";
    idModel.content = @"4157752645897624";
    self.adID = idModel.content;
    [configArray addObject:idModel];
    

    [self.dataArray addObject:configArray];
    
    MHCommonCellModel * requestModel = [[MHCommonCellModel alloc] init];
    requestModel.cellType = MHCommonCellTypeButton;
    requestModel.title = @"请求并展示开屏广告";
    NSArray * buttonArray = @[requestModel];
    [self.dataArray addObject:buttonArray];
    
}

// 懒加载mainTableView
- (UITableView *)splashTableView {
    if (!_splashTableView) {
        _splashTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        // 背景色
        _splashTableView.backgroundColor = [UIColor clearColor];
        _splashTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _splashTableView.sectionFooterHeight = 0;
        // 代理
        _splashTableView.delegate = self;
        _splashTableView.dataSource = self;
        
        // 注册cell
        [_splashTableView registerClass:[MHCommonTableViewCell class] forCellReuseIdentifier:@"MHCommonTableViewCell"];
    }
    return _splashTableView;
}

- (UIImage *)getAppIcon {
    // 获取 Info.plist 字典
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    
    // 获取 App Icons 的信息
    NSDictionary *iconsDictionary = infoDictionary[@"CFBundleIcons"];
    NSDictionary *primaryIconsDictionary = iconsDictionary[@"CFBundlePrimaryIcon"];
    NSArray *iconFiles = primaryIconsDictionary[@"CFBundleIconFiles"];
    
    // 获取最后一个图标文件（通常是最大的图标）
    NSString *iconName = [iconFiles lastObject];
    
    // 返回图标图片
    return [UIImage imageNamed:iconName];
}

- (UIView *)getBottomView {
    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 120)];
    bottomView.backgroundColor = [UIColor whiteColor];
    UIImageView *logoImageView = [[UIImageView alloc] initWithImage:[self getAppIcon]];
    logoImageView.frame = CGRectMake(0, 0, 80, 80);
    logoImageView.center = bottomView.center;
    [bottomView addSubview:logoImageView];
    return bottomView;
}

#pragma mark ----- UITableViewDelegate && UITableViewDataSource -----
- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"MHMainTableViewCell";
    MHCommonTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[MHCommonTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    cell.indexPath = indexPath;
    cell.delegate = self;
    
    MHCommonCellModel * model = self.dataArray[indexPath.section][indexPath.row];
    [cell setCell:model];
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.dataArray.count;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray * sectionArray = self.dataArray[section];
    return sectionArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 4) {
        return 60;
    }
    return 42;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return @"选项";
    } else {
        return @" ";
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark - MHCommonTableViewCellDelegate
- (void)mhCommonTableViewCellButtonDidClick:(NSIndexPath * _Nullable)indexPath {
    // 构建 bottomView
    self.bottomView = [self getBottomView];
    CGSize logoSize = self.bottomView.bounds.size;

    // 计算广告区域尺寸（屏幕 - bottomView）
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    CGSize adSize = CGSizeMake(screenSize.width, screenSize.height - logoSize.height);

    // 构建 extra 参数
    NSMutableDictionary *extra = [NSMutableDictionary dictionary];
    [extra setValue:[NSValue valueWithCGSize:adSize] forKey:WindMillConstant.AdSize];
    [extra setValue:self.bottomView forKey:WindMillConstant.BottomView];
    [extra setValue:[NSValue valueWithCGSize:logoSize] forKey:WindMillConstant.BottomViewSize];
    
    
    // 构建 request
    WindMillAdRequest *request = [WindMillAdRequest request];
    request.placementId = self.adID;

    // 创建 ToBid 开屏广告实例
    self.splashAd = [[WindMillSplashAd alloc] initWithRequest:request extra:extra];
    self.splashAd.rootViewController = self;
    self.splashAd.delegate = self;

    // 先加载，加载成功后在 onSplashAdDidLoad: 中展示
    [self.splashAd loadAd];
}

- (void)mhCommonTableViewCellCheckBoxDidClick:(NSIndexPath * _Nullable)indexPath isSelect:(BOOL)isSelect {
    
}

- (void)mhCommonTableViewCellSwitchDidClick:(NSIndexPath * _Nullable)indexPath isOpen:(BOOL)isOpen {
    
}

- (void)mhCommonTableViewCellTextFieldValueChanged:(NSIndexPath *_Nullable)indexPath text:(NSString *)text {
    self.adID = text;
}

#pragma mark - WindMillSplashAdDelegate

- (void)onSplashAdDidLoad:(WindMillSplashAd *)splashAd {
    NSLog(@"SplashViewController 开屏广告加载成功，开始展示");
    UIWindow *window = self.view.window;
    if (!window) {
        window = [UIApplication sharedApplication].windows.firstObject;
    }
    [splashAd showAdInWindow:window withBottomView:self.bottomView];
}

- (void)onSplashAdLoadFail:(WindMillSplashAd *)splashAd error:(NSError *)error {
    NSLog(@"SplashViewController 开屏广告加载失败: %@", error);
    NSString *errorMsg = [NSString stringWithFormat:@"code: %ld - %@", (long)error.code, error.localizedDescription];
    [self.view makeToast:errorMsg duration:2.0F position:CSToastPositionCenter];
}

- (void)onSplashAdSuccessPresentScreen:(WindMillSplashAd *)splashAd {
    NSLog(@"SplashViewController 开屏广告已展示");
    // 展示 ecpm 信息
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        WindMillAdInfo *adInfo = splashAd.adInfo;
        uint32_t ecpm = adInfo.eCPM;
        NSLog(@"SplashViewController 开屏广告已展示 ecpm: %ld", ecpm);
        NSString *ecpmString = [NSString stringWithFormat:@"当前广告的Ecpm: %u", ecpm];
        [[UIApplication sharedApplication].keyWindow makeToast:ecpmString duration:2.0F position:CSToastPositionCenter];
    });
}

- (void)onSplashAdFailToPresent:(WindMillSplashAd *)splashAd withError:(NSError *)error {
    NSLog(@"SplashViewController 开屏广告展示失败: %@", error);
}

- (void)onSplashAdClicked:(WindMillSplashAd *)splashAd {
    NSLog(@"SplashViewController 开屏广告点击");
}

- (void)onSplashAdSkiped:(WindMillSplashAd *)splashAd {
    NSLog(@"SplashViewController 开屏广告跳过");
}

- (void)onSplashAdWillClosed:(WindMillSplashAd *)splashAd {
    NSLog(@"SplashViewController 开屏广告即将关闭");
}

- (void)onSplashAdClosed:(WindMillSplashAd *)splashAd {
    NSLog(@"SplashViewController 开屏广告已关闭");
}

@end
