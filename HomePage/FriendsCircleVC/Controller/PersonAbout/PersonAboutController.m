//
//  PersonAboutController.m
//  XiaoHuiBang
//
//  Created by mac on 16/11/22.
//  Copyright © 2016年 消汇邦. All rights reserved.
//

// 显示个人动态列表



#import "PersonAboutController.h"
#import "PersonSeeTableView.h"
#import "CNetTool.h"
#import <SVProgressHUD.h>
#import "PersonSeeLayout.h"
#import "PersonSeeModel.h"
#import "AFHttpTool.h"
#import "CRefresh.h"

#define kScreenHeight [UIScreen mainScreen].bounds.size.height  // 屏高
#define kScreenWidth [UIScreen mainScreen].bounds.size.width    // 屏宽



@interface PersonAboutController ()

@property (strong, nonatomic) PersonSeeTableView *seeTableView;  // 个人动态表视图
@property (strong, nonatomic) NSMutableArray *seeModelList;      // 储存动态的数组
@property (assign, nonatomic) NSInteger dataTag;                 // 标志上拉加载下拉刷新
@property (assign, nonatomic) NSInteger dataPage;                // 记录加载页数

@end

@implementation PersonAboutController

// 1、先走这个方法
- (instancetype)initWithUserID:(NSString *)user_id{

    self = [super init];
    if (self != nil) {
        self.view.backgroundColor = [UIColor colorWithRed:238/255.0 green:238/255.0 blue:238/255.0 alpha:1];
        
        _dataPage = 1;
        
        // 根据id网络请求个人信息
        [AFHttpTool getUserInfo:user_id
                        success:^(id response) {
                            if ([response[@"msg"] isEqual:@1]) {
                                // 加载数据
                                [self loadData:response[@"data"]];
                            }
                        } failure:^(NSError *err) {
                            [SVProgressHUD dismiss];
                            [SVProgressHUD showSuccessWithStatus:@"请求失败"];
                        }];
        
    }
    return self;

}
// 2、再走这个方法
- (void)viewDidLoad {
    [super viewDidLoad];
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 40)];
    title.text = @"动态";
    title.textAlignment = NSTextAlignmentCenter;
    title.textColor = [UIColor whiteColor];
    self.navigationItem.titleView = title;
    
    [self.navigationItem.backBarButtonItem setTitle:@"邦友圈"];
    
    
    
    
    // 创建一个若引用的self在block中调用方法，防止循环引用
    __weak PersonAboutController *weakSelf = self;
    // 暂时不需要下拉刷新
//    [self.seeTableView addPullDownRefreshBlock:^{
//        @synchronized (weakSelf) {
//            // 下拉刷新
//            [weakSelf reloadData];
//        }
//        
//    }];
    
    [self.seeTableView addInfiniteScrollingWithActionHandler:^{
        @synchronized (weakSelf) {
            // 上拉加载
            [weakSelf downloadData];
        }
    }];

    
}

#pragma mark - 懒加载
- (PersonSeeTableView *)seeTableView {

    if (_seeTableView == nil) {
        _seeTableView = [[PersonSeeTableView alloc] initWithFrame:[UIScreen mainScreen].bounds style:UITableViewStyleGrouped];
        _seeTableView.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:_seeTableView];
    }
    return _seeTableView;

}
- (NSMutableArray *)seeModelList {
    
    if (_seeModelList == nil) {
        _seeModelList = [NSMutableArray array];
    }
    return _seeModelList;
    
}

#pragma mark - 加载个人信息，然后在加载动态数据
- (void)loadData:(NSDictionary *)data {

    // 解析用户信息
    self.user_id = data[@"id"];
    self.nickname = data[@"nickname"];
    self.headImageUrl = data[@"head_img"];
    
    // 获取动态
    NSDictionary *params = @{@"user_id" : _user_id,
                             @"page" : @"1"
                             };
    [CNetTool loadPersonAboutWithParameters:params
                                    success:^(id response) {
                                        
                                        if ([response[@"msg"] isEqual:@1]) {
                                             // 处理数据
                                             NSArray *data = (NSArray *)response[@"data"];
                                             [self dataProcess:data];
                                        } else {
                                            // 没有动态
                                            [SVProgressHUD dismiss];
                                            [SVProgressHUD showSuccessWithStatus:@"没有动态"];
                                            // [self.seeTableView.pullToRefreshView stopAnimating];
                                        }
                                        
                                    } failure:^(NSError *err) {
                                        [SVProgressHUD dismiss];
                                        [SVProgressHUD showSuccessWithStatus:@"加载失败"];
                                    }];
    
    
}
#pragma mark - 下拉刷新
- (void)reloadData {
    
    _dataPage = 1;
    _dataTag = 0;
    // 获取动态
    NSDictionary *params = @{@"user_id" : _user_id,
                             @"page" : [NSString stringWithFormat:@"%ld", _dataPage]
                             };
    [CNetTool loadPersonAboutWithParameters:params
                                    success:^(id response) {
                                        
                                        if ([response[@"msg"] isEqual:@1]) {
                                            // 处理数据
                                            NSArray *data = (NSArray *)response[@"data"];
                                            [self dataProcess:data];
                                        } else {
                                            // 没有动态
                                            [SVProgressHUD dismiss];
                                            [SVProgressHUD showSuccessWithStatus:@"没有更多动态"];
                                            // [self.seeTableView.pullToRefreshView stopAnimating];
                                        }
                                        
                                    } failure:^(NSError *err) {
                                        [SVProgressHUD dismiss];
                                        [SVProgressHUD showSuccessWithStatus:@"加载失败"];
                                    }];
    
}
#pragma mark - 上拉加载
- (void)downloadData {
    
    _dataPage += 1;
    _dataTag = 1;
    // 获取动态
    NSDictionary *params = @{@"user_id" : _user_id,
                             @"page" : [NSString stringWithFormat:@"%ld", _dataPage]
                             };
    
    [CNetTool loadPersonAboutWithParameters:params
                                    success:^(id response) {
                                        
                                        if ([response[@"msg"] isEqual:@1]) {
                                            // 处理数据
                                            NSArray *data = (NSArray *)response[@"data"];
                                            [self dataProcess:data];
                                        } else {
                                            // 没有动态
                                            [SVProgressHUD dismiss];
                                            [SVProgressHUD showSuccessWithStatus:@"没有更多动态"];
                                            [self.seeTableView.infiniteScrollingView stopAnimating];
                                        }
                                        
                                    } failure:^(NSError *err) {
                                        [SVProgressHUD dismiss];
                                        [SVProgressHUD showSuccessWithStatus:@"加载失败"];
                                    }];
    
    
}

#pragma mark - 处理数据
- (void)dataProcess:(NSArray *)array {
    
    if (_dataTag == 0) {
        [self.seeModelList removeAllObjects];
    }

    NSMutableArray *seeTempArr = [NSMutableArray array];
    for (NSDictionary *dic in array) {
        PersonSeeModel *model = [[PersonSeeModel alloc] init];
        model.about_id = dic[@"id"];
        model.user_id = dic[@"user_id"];
        model.content = dic[@"content"];
        model.about_img = dic[@"about_img"];
        model.create_time = dic[@"create_time"];
        model.thumb_img = dic[@"thumb_img"];
        
        PersonSeeLayout *layout = [[PersonSeeLayout alloc] init];
        layout.personSeeModel = model;
        
        [seeTempArr addObject:layout];
    }
    
    if (_dataTag == 0) {
        self.seeModelList = seeTempArr;
        [self.seeTableView.pullToRefreshView stopAnimating];
        self.seeTableView.seeLayoutList = self.seeModelList;
        self.seeTableView.headImageUrl = _headImageUrl;
        self.seeTableView.nickname = _nickname;
        [self.seeTableView reloadData];
    } else {
        [self.seeModelList addObjectsFromArray:seeTempArr];
        [self.seeTableView.infiniteScrollingView stopAnimating];
        self.seeTableView.seeLayoutList = self.seeModelList;
        self.seeTableView.headImageUrl = _headImageUrl;
        self.seeTableView.nickname = _nickname;
        [self.seeTableView reloadData];
    }
    
    
    
    
    
    
}


#pragma mark - 导航栏按钮响应




















- (void)dealloc {

    // self.seeTableView.showsPullToRefresh = NO;
    self.seeTableView.showsInfiniteScrolling = NO;

}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
