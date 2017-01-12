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

#define kScreenHeight [UIScreen mainScreen].bounds.size.height                          // 屏高
#define kScreenWidth [UIScreen mainScreen].bounds.size.width                            // 屏宽


@interface CGameRankController () <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) NSMutableArray *rankArray;
@property (strong, nonatomic) UITableView *rankTableView;

@end

@implementation CGameRankController


- (instancetype)init {

    if (self = [super init]) {
        // 请求排行榜数据
        NSDictionary *params = @{@"type" : @1};
        [CNetTool loadBestRankWithParameters:params
                                     success:^(id response) {
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
                                             self.rankTableView.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight - 64);
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
        [_rankTableView registerNib:[UINib nibWithNibName:@"CGameRankCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"CGameRankCellID"];
        _rankTableView.backgroundColor = [UIColor colorWithRed:254/255.0 green:127/255.0 blue:47/255.0 alpha:1];
        _rankTableView.delegate = self;
        _rankTableView.dataSource = self;
        [self.view addSubview:_rankTableView];
    }
    return _rankTableView;

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

    CGameRankCell *cell = [[[NSBundle mainBundle]loadNibNamed:@"CGameRankCell" owner:self options:nil] firstObject];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    CGameRankModel *model = _rankArray[indexPath.row];
    cell.rankNum.text = [NSString stringWithFormat:@"%ld", indexPath.row+1];
    cell.nickName.text = model.nickname;
    [cell.headImageView sd_setImageWithURL:[NSURL URLWithString:model.thumb]];
    cell.score.text = model.score;
    return cell;
    

}


































@end
