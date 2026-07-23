//
//  MHNewNativeViewController.m
//  MHAdSDKDemo
//
//  Created by 郭建恒 on 2024/11/21.
//

#import "MHNativeViewController.h"
#import <WindMillSDK/WindMillSDK.h>
#import <MHAdSDK/MHNativeAd.h>
#import "AWM4MHNativeAdAdapter.h"
#import "NativeView.h"
#import "Masonry.h"
#import "MHCommonTableViewCell.h"
#import "MHNativeListAdCell.h"
#import "UIView+toast.h"
#import "MHSoundChecker.h"

@interface MHNativeViewController ()<UITableViewDelegate, UITableViewDataSource, MHCommonTableViewCellDelegate, WindMillNativeAdsManagerDelegate>

//
@property (nonatomic, strong) UITableView* nativeTableView;

@property (nonatomic, strong) NSMutableArray * dataArray;
@property (nonatomic, strong) NSMutableArray * adArray;

@property (nonatomic, copy) NSString * adID;
@property (nonatomic, assign) NSInteger adCount; // 需要获取的广告数量

@property (nonatomic, assign) BOOL isMuted;
@property (nonatomic, assign) BOOL isAutoPlayMobileNetwork;

@property (nonatomic, strong) WindMillNativeAdsManager *nativeAdsManager;
@property (nonatomic, strong) MHNativeAd *nativeAd; // 从 adapter 获取，用于 showInViews: 曝光注册
@property (nonatomic, strong) NSArray<WindMillNativeAd *> *windMillNativeAds; // 强引用 ToBid 广告对象，防止 WeakArray 丢失

@property (nonatomic, assign) BOOL hasAdData;
@property (nonatomic, assign) BOOL isAdSectionVisible; // 控制是否显示广告 section

@end

@implementation MHNativeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.hasAdData = NO;
    self.isAdSectionVisible = YES; // 默认不显示广告区域
    self.title = @"原生信息流广告";
    
    self.view.backgroundColor = [UIColor colorWithRed:240/255.0 green:240/255.0 blue:240/255.0 alpha:1.0];
    // 自定义返回按钮
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"返回"
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(backButtonTapped)];
    backButton.accessibilityIdentifier = @"MHNativeViewController_BackButtonItem";
    self.navigationItem.leftBarButtonItem = backButton;
    
    // 添加右上角按钮：用于控制显示/隐藏广告区域
    UIBarButtonItem *showAdButton = [[UIBarButtonItem alloc] initWithTitle:@"隐藏广告"
                                                                     style:UIBarButtonItemStylePlain
                                                                    target:self
                                                                    action:@selector(showAdSectionButtonTapped)];
    self.navigationItem.rightBarButtonItem = showAdButton;
    
    // Do any additional setup after loading the view.
    
    self.isMuted = YES;
    self.isAutoPlayMobileNetwork = YES;
    self.adCount = 1;
    // 添加点击手势来收回键盘
    [self addTapGestureToDismissKeyboard];
    [self getData];
    
    [self layoutAllSubviews];
}

- (void)backButtonTapped{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)showAdSectionButtonTapped {
    self.isAdSectionVisible = !self.isAdSectionVisible;

    NSString *title = self.isAdSectionVisible ? @"隐藏广告" : @"显示广告";
    self.navigationItem.rightBarButtonItem.title = title;

    // 刷新表格，重新加载 section 数量
    [self.nativeTableView reloadData];
}

-(void)layoutAllSubviews {
    
    [self.view addSubview:self.nativeTableView];
    [self.nativeTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.width.height.equalTo(self.view);
    }];
    
    [self.nativeTableView reloadData];
    
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
    self.adArray = [NSMutableArray array];
    self.dataArray = [NSMutableArray array];
    
    // 广告位id (ToBid 聚合广告位 ID)
    MHCommonCellModel * idModel = [[MHCommonCellModel alloc] init];
    idModel.cellType = MHCommonCellTypeTextField;
    idModel.title = @"广告位id";
    idModel.content = @"5825187737326020";
    self.adID = idModel.content;
    [self.dataArray addObject:idModel];
    
    // 静音
    MHCommonCellModel * audioConfigModel = [[MHCommonCellModel alloc] init];
    audioConfigModel.cellType = MHCommonCellTypeSwitch;
    audioConfigModel.title = @"静音";
    audioConfigModel.isSelect = self.isMuted;
    [self.dataArray addObject:audioConfigModel];

    // 移动网络是否自动播放
    MHCommonCellModel * autoPlayConfigModel = [[MHCommonCellModel alloc] init];
    autoPlayConfigModel.cellType = MHCommonCellTypeSwitch;
    autoPlayConfigModel.title = @"移动网络是否自动播放";
    autoPlayConfigModel.isSelect = self.isAutoPlayMobileNetwork;
    [self.dataArray addObject:autoPlayConfigModel];
    
    
    MHCommonCellModel * requestModel = [[MHCommonCellModel alloc] init];
    requestModel.cellType = MHCommonCellTypeButton;
    requestModel.title = @"请求并展示原生广告";
    [self.dataArray addObject:requestModel];
    
    if (self.hasAdData) {
        [self addCloseAdData];
    }
    
}

- (void)addCloseAdData {
    BOOL hasMuteItem = NO;
    for (MHCommonCellModel *item in self.dataArray) {
        if ([item.title isEqualToString:@"关闭广告"]) {
            hasMuteItem = YES;
            break;
        }
    }
    
    if (!hasMuteItem) {
        MHCommonCellModel * closeModel = [[MHCommonCellModel alloc] init];
        closeModel.cellType = MHCommonCellTypeButton;
        closeModel.title = @"关闭广告";
        [self.dataArray addObject:closeModel];
    }
    
}

- (void)removeCloseAdData {
    [self.dataArray removeLastObject];
}


// 通过 ToBid 加载原生广告
- (void)loadNativeAdViaToBid {
    WindMillAdRequest *request = [[WindMillAdRequest alloc] init];
    request.placementId = self.adID;
    request.options = @{
        @"MHIsMuted": self.isMuted ? @"1" : @"0",
        @"MHAutoPlayMobileNetwork": self.isAutoPlayMobileNetwork ? @"1" : @"0"
    };

    self.nativeAdsManager = [[WindMillNativeAdsManager alloc] initWithRequest:request];
    self.nativeAdsManager.delegate = self;
    [self.nativeAdsManager loadAdDataWithCount:(uint32_t)self.adCount];
}

// 懒加载mainTableView
- (UITableView *)nativeTableView {
    if (!_nativeTableView) {
        _nativeTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        // 背景色
        _nativeTableView.backgroundColor = [UIColor clearColor];
        _nativeTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _nativeTableView.sectionFooterHeight = 0;
        // 代理
        _nativeTableView.delegate = self;
        _nativeTableView.dataSource = self;
        // 注册cell
        [_nativeTableView registerClass:[MHCommonTableViewCell class] forCellReuseIdentifier:@"MHCommonTableViewCell"];
        [_nativeTableView registerClass:[MHNativeListAdCell class] forCellReuseIdentifier:@"MHNativeListAdCell"];
    }
    return _nativeTableView;
}

- (void)dealloc {
    [self closeAd];
    self.nativeAd = nil;
    self.windMillNativeAds = nil;
    self.nativeAdsManager = nil;
    NSLog(@"原生广告页面 dealloc");
}

#pragma mark ----- UITableViewDelegate && UITableViewDataSource -----
- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    
    
    if (indexPath.section == 0) {
        static NSString *cellIdentifier = @"MHMainTableViewCell";
        MHCommonTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (!cell) {
            cell = [[MHCommonTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        
        cell.indexPath = indexPath;
        cell.delegate = self;
        
        MHCommonCellModel * model = self.dataArray[indexPath.row];
        [cell setCell:model];
        return cell;
    } else {
        static NSString *cellIdentifier = @"MHNativeListAdCell";
        MHNativeListAdCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (!cell) {
            cell = [[MHNativeListAdCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        cell.nativeAd = self.nativeAd;
        MHNativeAdModel * model = self.adArray[indexPath.row];
        [cell setCell:model];
        return cell;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return self.dataArray.count;
    } else if (section == 1) { // 确保只有在 isAdSectionVisible 为 YES 时，section 1 才存在
        if (self.isAdSectionVisible && self.hasAdData) {
            return self.adArray.count;
        } else {
            return 0; // 不会走到这里，因为 section 1 根本不显示
        }
    }
    return 0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.hasAdData) {
        if (self.isAdSectionVisible) {
            return 2; // 显示：选项 section(0) + 广告 section(1)
        } else {
            return 1; // 只显示：选项 section(0)，隐藏广告 section(1)
        }
    } else {
        return 1; // 只有选项
    }
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.section == 0) {
        return 60;
    } else {
        CGFloat width = self.view.bounds.size.width;
        CGFloat adViewWidth = width - 16;
        CGFloat adWidth = adViewWidth - 16;
        CGFloat adHeight = adWidth / 16 * 9 + 100;
        return adHeight + 10;
    }
    
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{

    
    if (section == 0) {
        return 50;
    }
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return @"选项";
    } else if (section == 1) {
        return @"广告区域";
    }
    return nil;
}
#pragma mark - MHCommonTableViewCellDelegate
- (void)mhCommonTableViewCellButtonDidClick:(NSIndexPath * _Nullable)indexPath {
    // 获取广告数据,完成后刷新 tableview即可
    MHCommonCellModel * model = self.dataArray[indexPath.row];
    NSString * title = model.title;
    if ([title isEqualToString:@"请求并展示原生广告"]) {
        MHSoundChecker *checker = [[MHSoundChecker alloc] init];
        [checker checkSilentModeWithCompletion:^(BOOL isMuted) {
            if (isMuted) {
                NSLog(@"设备处于静音模式");
                self.isMuted = YES;
            } else {
                NSLog(@"设备未静音");
            }
            [self loadNativeAdViaToBid];
        }];
        
        
    } else if ([title isEqualToString:@"关闭广告"]) {
        [self closeAd];
    }
   
}

- (void)closeAd {
    self.hasAdData = NO;
    [self.nativeAd unregisterView];
    self.nativeAd = nil;
    self.windMillNativeAds = nil;
    self.nativeAdsManager = nil;
    [self removeCloseAdData];
    [self.adArray removeAllObjects];
    [self.nativeTableView reloadData];
    
    self.isAdSectionVisible = YES;
    NSString *rightTitle = self.isAdSectionVisible ? @"隐藏广告" : @"显示广告";
    self.navigationItem.rightBarButtonItem.title = rightTitle;
}

- (void)mhCommonTableViewCellCheckBoxDidClick:(NSIndexPath * _Nullable)indexPath isSelect:(BOOL)isSelect {
    
}

- (void)mhCommonTableViewCellSwitchDidClick:(NSIndexPath * _Nullable)indexPath isOpen:(BOOL)isOpen {
    MHCommonCellModel * model = self.dataArray[indexPath.row];
    NSString * title = model.title;
    if ([title isEqualToString:@"静音"]) {
        self.isMuted = isOpen;
        // 更新数据源中的静音项
        for (MHCommonCellModel *item in self.dataArray) {
            if ([item.title isEqualToString:@"静音"]) {
                item.isSelect = isOpen;
                break;
            }
        }
        
    } else if ([title isEqualToString:@"移动网络是否自动播放"]) {
        self.isAutoPlayMobileNetwork = isOpen;
        for (MHCommonCellModel *item in self.dataArray) {
            if ([item.title isEqualToString:@"移动网络是否自动播放"]) {
                item.isSelect = isOpen;
                break;
            }
        }
    }
    if (self.hasAdData) {
        self.hasAdData = NO;
        self.windMillNativeAds = nil;
        [self removeCloseAdData];
        [self.adArray removeAllObjects];
    }
    
    // 刷新UI
    [self.nativeTableView reloadData];
}

- (void)mhCommonTableViewCellTextFieldValueChanged:(NSIndexPath *_Nullable)indexPath text:(NSString *)text {
    self.adID = text;
}

#pragma mark ----- WindMillNativeAdsManagerDelegate

/// ToBid 广告加载成功
- (void)nativeAdsManagerSuccessToLoad:(WindMillNativeAdsManager *)nativeAdsManager {
    NSLog(@"[ToBid] nativeAdsManagerSuccessToLoad");

    // 从 adapter 获取 MHNativeAd 和 models
    AWM4MHNativeAdAdapter *adapter = [AWM4MHNativeAdAdapter sharedInstance];
    if (!adapter) {
        [self.view makeToast:@"未找到 MHAdSDK adapter" duration:2.0F position:CSToastPositionCenter];
        return;
    }

    self.nativeAd = adapter.lastLoadedNativeAd;
    self.nativeAd.rootController = self;
    NSArray<MHNativeAdModel *> *models = adapter.lastLoadedModels;

    // 清空 adapter 的引用，避免生命周期问题
    adapter.lastLoadedNativeAd = nil;
    adapter.lastLoadedModels = nil;

    if (models.count == 0) {
        [self.view makeToast:@"nativeAd 无填充!" duration:2.0F position:CSToastPositionTop];
        self.hasAdData = NO;
        return;
    }

    self.hasAdData = YES;
    [self.adArray removeAllObjects];

    // 强引用 ToBid 的 WindMillNativeAd 对象，防止内部 WeakArray 丢失引用
    self.windMillNativeAds = [nativeAdsManager getAllNativeAds];
    NSLog(@"[ToBid] getAllNativeAds count=%lu", (unsigned long)self.windMillNativeAds.count);

    [self.view makeToast:@"nativeAd 广告已经获取" duration:2.0F position:CSToastPositionBottom];

    for (int i = 0; i < models.count; i++) {
        MHNativeAdModel *nativeModel = models[i];

        NSLog(@"nativeAdDidLoad nativeAdModel 地址[%d]: %p", i, nativeModel);

        NSInteger nativeEcpm = nativeModel.ecpm;
        NSLog(@"[ToBid] nativeAdsManagerSuccessToLoad ecpm: %ld", nativeEcpm);
        NSString *ecpmString = [NSString stringWithFormat:@"当前广告的Ecpm[%d]: %ld", i, (long)nativeEcpm];
        [self.view makeToast:ecpmString duration:2.0F position:CSToastPositionCenter];

        [self addCloseAdData];
        [self.adArray addObject:nativeModel];
    }

    [self.nativeTableView reloadData];
}

/// ToBid 广告加载失败
- (void)nativeAdsManager:(WindMillNativeAdsManager *)nativeAdsManager didFailWithError:(NSError *)error {
    self.hasAdData = NO;
    [self.adArray removeAllObjects];
    NSLog(@"[ToBid] nativeAdsManager 加载失败: %@", error.localizedDescription);
    NSString *toastMessage = [NSString stringWithFormat:@"nativeAd 广告错误: %@", error.localizedDescription];
    [self.view makeToast:toastMessage duration:2.0F position:CSToastPositionCenter];
}

@end
