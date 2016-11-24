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

#define kScreenHeight [UIScreen mainScreen].bounds.size.height  // 屏高
#define kScreenWidth [UIScreen mainScreen].bounds.size.width    // 屏宽



@interface PersonAboutController ()

@property (strong, nonatomic) PersonSeeTableView *seeTableView;  // 个人动态表视图
@property (strong, nonatomic) NSMutableArray *seeModelList;      // 储存动态的数组

@end

@implementation PersonAboutController

// 1、先走这个方法
- (instancetype)initWithUserID:(NSString *)user_id{

    self = [super init];
    if (self != nil) {
        self.view.backgroundColor = [UIColor colorWithRed:238/255.0 green:238/255.0 blue:238/255.0 alpha:1];
        
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
    
    
    
}

#pragma mark - 懒加载
- (PersonSeeTableView *)seeTableView {

    if (_seeTableView == nil) {
        _seeTableView = [[PersonSeeTableView alloc] initWithFrame:[UIScreen mainScreen].bounds style:UITableViewStyleGrouped];
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

#pragma mark - 加载数据
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
                                        }
                                        
                                    } failure:^(NSError *err) {
                                        [SVProgressHUD dismiss];
                                        [SVProgressHUD showSuccessWithStatus:@"加载失败"];
                                    }];
    
    
}

#pragma mark - 处理数据
- (void)dataProcess:(NSArray *)array {

    NSMutableArray *seeTempArr = [NSMutableArray array];
    for (NSDictionary *dic in array) {
        PersonSeeModel *model = [[PersonSeeModel alloc] init];
        model.about_id = dic[@"id"];
        model.user_id = dic[@"user_id"];
        model.content = dic[@"content"];
        model.about_img = dic[@"about_img"];
        model.create_time = dic[@"create_time"];
        
        PersonSeeLayout *layout = [[PersonSeeLayout alloc] init];
        layout.personSeeModel = model;
        
        [seeTempArr addObject:layout];
    }
    
    // 保存一下
    self.seeModelList = seeTempArr;
    self.seeTableView.seeLayoutList = seeTempArr;
    self.seeTableView.headImageUrl = _headImageUrl;
    self.seeTableView.nickname = _nickname;
    
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
