//
//  CGameRankController.m
//  XiaoHuiBang
//
//  Created by mac on 2017/1/12.
//  Copyright © 2017年 消汇邦. All rights reserved.
//

#import "CGameRankController.h"
#import "CNetTool.h"
#import "CGameRankModel.h"
#import "CGameRankCell.h"
#import <UIImageView+WebCache.h>
#import "CRankCell.h"

#define kScreenHeight [UIScreen mainScreen].bounds.size.height                          // 屏高
#define kScreenWidth [UIScreen mainScreen].bounds.size.width                            // 屏宽


@interface CGameRankController () <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) NSMutableArray *rankArray;
@property (strong, nonatomic) UITableView *rankTableView;
@property (strong, nonatomic) UIActivityIndicatorView *activityView;

@end

@implementation CGameRankController


- (instancetype)init {

    if (self = [super init]) {
        // 请求排行榜数据
        NSDictionary *params = @{@"type" : @1};
        [CNetTool loadBestRankWithParameters:params
                                     success:^(id response) {
                                         [self.activityView stopAnimating];
                                         if ([response[@"msg"] isEqual:@1]) {
                                             NSArray *data = response[@"data"];
                                             for (NSDictionary *dic in data) {
                                                 CGameRankModel *model = [[CGameRankModel alloc] init];
                                                 model.user_id = dic[@"id"];
                                                 model.nickname = dic[@"nickname"];
                                                 model.thumb = dic[@"thumb"];
                                                 model.score = dic[@"score"];
                                                 model.max_score = dic[@"max_score"];
                                                 [self.rankArray addObject:model];
                                             }
                                             self.rankTableView.frame = CGRectMake(30, 60, kScreenWidth - 60, kScreenHeight - 150);
                                         } else {
                                             [SVProgressHUD dismiss];
                                             [SVProgressHUD showErrorWithStatus:@"暂时没有数据"];
                                         }
                                     } failure:^(NSError *err) {
                                         [SVProgressHUD dismiss];
                                         [SVProgressHUD showErrorWithStatus:@"获取排行榜失败"];
                                         [self.navigationController popViewControllerAnimated:YES];
                                     }];
    }
    return self;

}

- (void)viewDidLoad {

    self.view.backgroundColor = [UIColor colorWithRed:254/255.0 green:127/255.0 blue:47/255.0 alpha:1];
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
    backgroundImageView.image = [UIImage imageNamed:@"icon_gameRank_background"];
    [self.view addSubview:backgroundImageView];
    
    UIImageView *fontImageView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 20, kScreenWidth - 40, kScreenHeight - 40)];
    fontImageView.image = [UIImage imageNamed:@"icon_gameRank_font"];
    [self.view addSubview:fontImageView];
    
    [self.activityView startAnimating];
}



#pragma mark - 懒加载
- (NSMutableArray *)rankArray {

    if (_rankArray == nil) {
        _rankArray = [NSMutableArray array];
    }
    return _rankArray;

}

- (UITableView *)rankTableView {

    if (_rankTableView == nil) {
        _rankTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        [_rankTableView registerClass:[CRankCell class] forCellReuseIdentifier:@"CRankCellID"];
        _rankTableView.backgroundColor = [UIColor clearColor];
        _rankTableView.delegate = self;
        _rankTableView.dataSource = self;
        [self.view addSubview:_rankTableView];
        
        UIImageView *bannerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 20, kScreenWidth - 40, kScreenHeight - 40)];
        bannerImageView.image = [UIImage imageNamed:@"icon_gameRank_banner"];
        [self.view addSubview:bannerImageView];
    }
    return _rankTableView;

}

- (UIActivityIndicatorView *)activityView {

    if (_activityView == nil) {
        _activityView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake((kScreenWidth - 50)/2.0, (kScreenHeight - 50 - 64)/2.0, 50, 50)];
        _activityView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
        _activityView.hidesWhenStopped = YES;
        [self.view addSubview:_activityView];
    }
    return _activityView;

}


#pragma mark - 表视图代理方法
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return _rankArray.count;

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    return 80;

}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    CRankCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CRankCellID"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    CGameRankModel *model = _rankArray[indexPath.row];
    model.rankNum = indexPath.row+1;
    cell.rankModel = model;
    return cell;
    

}



































@end
