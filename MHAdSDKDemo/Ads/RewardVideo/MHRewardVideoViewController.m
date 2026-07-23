//
//  MHRewardVideoViewController.m
//  MHAdSDKDemo
//
//  Created by guojianheng on 2024/11/12.
//

#import "MHRewardVideoViewController.h"
#import <WindMillSDK/WindMillSDK.h>
#import <AVFoundation/AVFoundation.h>

#import "MHCommonTableViewCell.h"
#import "Masonry.h"
#import "MHCommonCellModel.h"
#import "UIView+toast.h"

@interface MHRewardVideoViewController ()<UITableViewDelegate, UITableViewDataSource, MHCommonTableViewCellDelegate, WindMillRewardVideoAdDelegate>

// 首页的表视图
@property (nonatomic, strong) UITableView * rewardTableView;

@property (nonatomic, strong) NSMutableArray * dataArray;

// 记录 ToBid 广告位ID
@property (nonatomic, copy) NSString * adID;

@property (nonatomic, strong) WindMillRewardVideoAd *rewardVideoAd;

@property (nonatomic, assign) BOOL isMuted;

@end

@implementation MHRewardVideoViewController

// 懒加载mainTableView
- (UITableView *)rewardTableView {
    if (!_rewardTableView) {
        _rewardTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        // 背景色
        _rewardTableView.backgroundColor = [UIColor clearColor];
        _rewardTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _rewardTableView.sectionFooterHeight = 0;
        // 代理
        _rewardTableView.delegate = self;
        _rewardTableView.dataSource = self;
        
        // 注册cell
        [_rewardTableView registerClass:[MHCommonTableViewCell class] forCellReuseIdentifier:@"MHCommonTableViewCell"];
    }
    return _rewardTableView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.isMuted = YES; // 默认静音
    self.title = @"激励视频广告";
    self.view.backgroundColor = [UIColor whiteColor];
    // 自定义返回按钮
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"返回"
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(backButtonTapped)];
    backButton.accessibilityIdentifier = @"MHRewardVideoViewController_BackButtonItem";
    self.navigationItem.leftBarButtonItem = backButton;
    // 添加点击手势来收回键盘
    [self addTapGestureToDismissKeyboard];
    [self getData];
    
    
    [self layoutAllSubviews];
}

- (void)dealloc
{
    NSLog(@"MHRewardVideoViewController 被释放");
}

- (void)backButtonTapped{
    [self.navigationController popViewControllerAnimated:YES];
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
}

- (void)getData {
    
    self.dataArray = [NSMutableArray array];
    NSMutableArray * configArray = [NSMutableArray array];
    
    // ToBid 广告位id（需要在 ToBid 后台配置好 MHAdSDK 作为自定义 ADN）
    MHCommonCellModel * idModel = [[MHCommonCellModel alloc] init];
    idModel.cellType = MHCommonCellTypeTextField;
    idModel.title = @"广告位id";
    idModel.content = @"7684531864193152";
    self.adID = idModel.content;
    [configArray addObject:idModel];

    // 静音
    MHCommonCellModel * muteConfigModel = [[MHCommonCellModel alloc] init];
    muteConfigModel.cellType = MHCommonCellTypeSwitch;
    muteConfigModel.title = @"静音";
    muteConfigModel.isSelect = self.isMuted;
    [configArray addObject:muteConfigModel];

    [self.dataArray addObject:configArray];
    
    MHCommonCellModel * requestModel = [[MHCommonCellModel alloc] init];
    requestModel.cellType = MHCommonCellTypeButton;
    requestModel.title = @"请求激励视频广告";

    NSArray * buttonArray = @[requestModel];
    [self.dataArray addObject:buttonArray];
    
}

- (void)layoutAllSubviews {
    [self.view addSubview:self.rewardTableView];
    [self.rewardTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.width.bottom.equalTo(self.view);
    }];
    
    [self.rewardTableView reloadData];
    
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

#pragma mark ----- MHCommonTableViewCellDelegate -----
- (void)mhCommonTableViewCellButtonDidClick:(NSIndexPath *_Nullable)indexPath {

    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayback error:nil];
    [session setActive:YES error:nil];

    // 构建 request
    WindMillAdRequest *request = [WindMillAdRequest request];
    request.placementId = self.adID;
    // 这里可以自定义SDK需要的传参,同时在Adapter 通过以下方式获取
    // NSDictionary *requestOptions = [self.bridge adRequest].options;
    // NSString *muteStr = requestOptions[@"MHIsMuted"];
    // NSNumber *extraMuted = [parameter.extra objectForKey:@"MHIsMuted"];
    request.options = @{@"MHIsMuted": self.isMuted ? @"1" : @"0"};
    
    // 需要设置什么参数请手动修改VC 和 Adapter 对应内容

    // 创建 ToBid 激励视频广告实例
    self.rewardVideoAd = [[WindMillRewardVideoAd alloc] initWithRequest:request];
    self.rewardVideoAd.delegate = self;

    // 先加载，加载成功后在 rewardVideoAdDidLoad: 中展示
    [self.rewardVideoAd loadAdData];
}

- (void)mhCommonTableViewCellCheckBoxDidClick:(NSIndexPath *_Nullable)indexPath isSelect:(BOOL)isSelect {
    
}

- (void)mhCommonTableViewCellSwitchDidClick:(NSIndexPath *_Nullable)indexPath isOpen:(BOOL)isOpen {
    MHCommonCellModel * model = self.dataArray[indexPath.section][indexPath.row];
    NSString * title = model.title;
    if ([title isEqualToString:@"静音"]) {
        self.isMuted = isOpen;
    }
}

- (void)mhCommonTableViewCellTextFieldValueChanged:(NSIndexPath *_Nullable)indexPath text:(NSString *)text {
    self.adID = text;
}

#pragma mark ----- WindMillRewardVideoAdDelegate -----

/// 激励视频加载成功，开始展示
- (void)rewardVideoAdDidLoad:(WindMillRewardVideoAd *)rewardVideoAd {
    NSLog(@"RewardVideoViewController 激励视频加载成功，开始展示");
    [rewardVideoAd showAdFromRootViewController:self options:nil];
}

/// 激励视频加载失败
- (void)rewardVideoAdDidLoad:(WindMillRewardVideoAd *)rewardVideoAd didFailWithError:(NSError *)error {
    NSLog(@"RewardVideoViewController 激励视频加载失败: %@", error);
    NSString *errorMsg = [NSString stringWithFormat:@"code: %ld - %@", (long)error.code, error.localizedDescription];
    [self.view makeToast:errorMsg duration:2.0F position:CSToastPositionCenter];
}

/// 激励视频已经展示
- (void)rewardVideoAdDidVisible:(WindMillRewardVideoAd *)rewardVideoAd {
    NSLog(@"RewardVideoViewController 激励视频已经展示");
    [self.view makeToast:@"激励视频已经展示!" duration:2.0F position:CSToastPositionTop];

    // 展示 ecpm 信息
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        WindMillAdInfo *adInfo = rewardVideoAd.adInfo;
        uint32_t ecpm = adInfo.eCPM;
        NSString *ecpmString = [NSString stringWithFormat:@"当前广告的Ecpm: %u", ecpm];
        [[UIApplication sharedApplication].keyWindow makeToast:ecpmString duration:2.0F position:CSToastPositionCenter];
    });
}

/// 激励视频展示失败
- (void)rewardVideoAdDidShowFailed:(WindMillRewardVideoAd *)rewardVideoAd error:(NSError *)error {
    NSLog(@"RewardVideoViewController 激励视频展示失败: %@", error);
    [self.view makeToast:[NSString stringWithFormat:@"展示失败: %@", error.localizedDescription]
                duration:2.0F
                position:CSToastPositionCenter];
}

/// 激励视频已经点击
- (void)rewardVideoAdDidClick:(WindMillRewardVideoAd *)rewardVideoAd {
    NSLog(@"RewardVideoViewController 激励视频已经点击");
    [[UIApplication sharedApplication].keyWindow makeToast:@"激励视频已经点击!" duration:2.0F position:CSToastPositionCenter];
}

/// 激励视频已经返回激励结果（必须实现）
- (void)rewardVideoAd:(WindMillRewardVideoAd *)rewardVideoAd reward:(WindMillRewardInfo *)reward {
    NSLog(@"RewardVideoViewController 激励视频返回激励结果: %d", reward.isCompeltedView);
    [self.view makeToast:@"激励视频已经返回激励结果!" duration:2.0F position:CSToastPositionTop];
}

/// 激励视频播放结束
- (void)rewardVideoAdDidPlayFinish:(WindMillRewardVideoAd *)rewardVideoAd didFailWithError:(NSError *)error {
    NSLog(@"RewardVideoViewController 激励视频播放结束");
    [[UIApplication sharedApplication].keyWindow makeToast:@"激励视频已经结束!" duration:2.0F position:CSToastPositionTop];
}

/// 激励视频已经关闭
- (void)rewardVideoAdDidClose:(WindMillRewardVideoAd *)rewardVideoAd {
    NSLog(@"RewardVideoViewController 激励视频已经关闭");
    [self.view makeToast:@"激励视频已经关闭!" duration:2.0F position:CSToastPositionTop];
}

@end
