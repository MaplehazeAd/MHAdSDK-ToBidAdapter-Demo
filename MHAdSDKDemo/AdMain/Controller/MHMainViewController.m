//
//  MHMainViewController.m
//  MHAdSDKDemo
//
//  Created by guojianheng on 2024/11/11.
//

#import "MHMainViewController.h"
#import "MHMainTableViewCell.h"
#import "Masonry.h"
#import "MHSplashViewController.h"
#import "MHRewardVideoViewController.h"
#import "MHNativeViewController.h"

#import "MHSettingViewController.h"

@interface MHMainViewController ()<UITableViewDelegate, UITableViewDataSource>

// 首页的表视图
@property (nonatomic, strong) UITableView * mainTableView;

@property (nonatomic, strong) NSArray * dataArray;

@end

@implementation MHMainViewController

// 懒加载mainTableView
- (UITableView *)mainTableView {
    if (!_mainTableView) {
        _mainTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        // 背景色
        _mainTableView.backgroundColor = [UIColor clearColor];
        // 代理
        _mainTableView.delegate = self;
        _mainTableView.dataSource = self;
        
        // 注册cell
        [_mainTableView registerClass:[MHMainTableViewCell class] forCellReuseIdentifier:@"MHMainTableViewCell"];
    }
    return _mainTableView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"枫岚广告SDK";
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIBarButtonItem *settingButton = [[UIBarButtonItem alloc] initWithTitle:@"设置"
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(settingButtonTapped)];
    settingButton.accessibilityIdentifier = @"MHNativeListViewController_SettingButtonItem";
    self.navigationItem.rightBarButtonItem = settingButton;
    
    [self getData];
    [self layoutAllSubviews];
}

- (void)settingButtonTapped {
    
    // 去设置页面
    MHSettingViewController * settingVC = [[MHSettingViewController alloc]init];
    [self.navigationController pushViewController:settingVC animated:YES];
    
}

- (void)getData {
    //self.dataArray = @[@"开屏广告", @"原生广告", @"激励广告"];
    self.dataArray = @[@"开屏广告", @"原生自渲染广告", @"激励视频广告"];
    
}

- (void)layoutAllSubviews {
    [self.view addSubview:self.mainTableView];
    self.mainTableView.accessibilityIdentifier = @"MHMainViewController_MainTableView";
    [self.mainTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.width.bottom.equalTo(self.view);
    }];
    
    [self.mainTableView reloadData];
    
}



#pragma mark ----- UITableViewDelegate && UITableViewDataSource -----
- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"MHMainTableViewCell";
    MHMainTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[MHMainTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        
    }
    
    NSString * content = self.dataArray[indexPath.row];
    [cell setCell:content];
    NSInteger row = indexPath.row;
    cell.accessibilityIdentifier = [NSString stringWithFormat:@"MHMainViewController_MainTableViewCell_%ld",row];
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 20;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    switch (row) {
        case 0:
        {
            // 开屏
            MHSplashViewController * splashVC = [[MHSplashViewController alloc] init];
            [self.navigationController pushViewController:splashVC animated:true];
            break;
        }
        case 1:
        {
            // 原生
            MHNativeViewController * nativeVC = [[MHNativeViewController alloc] init];
            [self.navigationController pushViewController:nativeVC animated:true];
            break;
        }
        case 2:
        {
            // 激励视频
            MHRewardVideoViewController * rewardedVC = [[MHRewardVideoViewController alloc] init];
            [self.navigationController pushViewController:rewardedVC animated:true];
            break;
        }

            
        default:
            break;
    }
    
}



@end
