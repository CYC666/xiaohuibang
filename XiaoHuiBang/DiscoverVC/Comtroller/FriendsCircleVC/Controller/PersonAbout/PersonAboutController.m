//
//  PersonAboutController.m
//  XiaoHuiBang
//
//  Created by mac on 16/11/22.
//  Copyright © 2016年 消汇邦. All rights reserved.
//

// 显示个人动态列表



#import "PersonAboutController.h"
#import "CNetTool.h"
#import "CRefresh.h"
#import "AFHttpTool.h"
#import "PersonSeeModel.h"
#import "SearchTableView.h"
#import "PersonSeeLayout.h"
#import "PersonSeeTableView.h"
#import <SVProgressHUD.h>

#define kScreenHeight [UIScreen mainScreen].bounds.size.height  // 屏高
#define kScreenWidth [UIScreen mainScreen].bounds.size.width    // 屏宽

#define RemoveSearchBar @"RemoveSearchBar"                      // 移除输入框的通知
#define RemoveYearLabel @"RemoveYearLabel"                      // 移除年份标签





@interface PersonAboutController () <UITextFieldDelegate> {

    UITextField *_input;            // 搜索框
    UIImageView *_searchImage;      // 搜索框里面的搜索图标
    UILabel *_label;                // 搜索框里的显示文字
    UIButton *_virtualButton;       // 搜索框出现后创建的背景按钮，点击以取消搜索
    
    

}

@property (strong, nonatomic) PersonSeeTableView *seeTableView;             // 个人动态表视图
@property (strong, nonatomic) NSMutableArray *seeModelList;                 // 储存动态的数组
@property (assign, nonatomic) NSInteger dataTag;                            // 标志上拉加载下拉刷新
@property (assign, nonatomic) NSInteger dataPage;                           // 记录加载页数
@property (strong, nonatomic) UIView *searchBar;                            // 搜索条
@property (strong, nonatomic) UILabel *resultLabel;                         // 搜索结果数目提示框
@property (strong, nonatomic) SearchTableView *resultPersonSeeTableView;    // 搜索结果显示的内容

@end

@implementation PersonAboutController

// 1、先走这个方法
- (instancetype)initWithUserID:(NSString *)user_id{

    self = [super init];
    if (self != nil) {
        self.view.backgroundColor = [UIColor colorWithRed:238/255.0 green:238/255.0 blue:238/255.0 alpha:1];
        _user_id = user_id;
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
                            [SVProgressHUD showErrorWithStatus:@"请求失败"];
                        }];
        
    }
    return self;

}
// 2、再走这个方法
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 导航栏右边的按钮
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_search"]
                                                                  style:UIBarButtonItemStylePlain
                                                                 target:self
                                                                 action:@selector(searchButtonAction:)];
    [self.navigationItem setRightBarButtonItem:rightItem];
    
}
- (void)viewDidAppear:(BOOL)animated {

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
    
    // 监听移除输入框的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(searchCancelAction) name:RemoveSearchBar object:nil];

}

- (void)viewWillDisappear:(BOOL)animated {

    // 发送通知，隐藏显示年份的标签personSeeTableView
    [[NSNotificationCenter defaultCenter] postNotificationName:RemoveYearLabel object:nil];

}

#pragma mark - 懒加载
- (PersonSeeTableView *)seeTableView {

    if (_seeTableView == nil) {
        _seeTableView = [[PersonSeeTableView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight-64)
                                                            style:UITableViewStyleGrouped];
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
- (UILabel *)resultLabel {

    if (_resultLabel == nil) {
        _resultLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 64, kScreenWidth, 20)];
        _resultLabel.backgroundColor = [UIColor colorWithRed:238/255.0 green:238/255.0 blue:238/255.0 alpha:1];
        _resultLabel.textColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1];
        _resultLabel.font = [UIFont systemFontOfSize:12];
        _resultLabel.layer.borderWidth = .5;
        _resultLabel.alpha = 0;
        _resultLabel.layer.borderColor = [UIColor colorWithRed:229/255.0 green:229/255.0 blue:229/255.0 alpha:1].CGColor;
        [[UIApplication sharedApplication].keyWindow addSubview:_resultLabel];
    }
    return _resultLabel;

}
- (SearchTableView *)resultPersonSeeTableView {

    if (_resultPersonSeeTableView == nil) {
        _resultPersonSeeTableView = [[SearchTableView alloc] initWithFrame:CGRectMake(0, 64+20, kScreenWidth, kScreenHeight - 64 - 20)
                                                                     style:UITableViewStylePlain
                                                                controller:self];
        _resultPersonSeeTableView.backgroundColor = [UIColor whiteColor];
        _resultPersonSeeTableView.alpha = 0;
        _resultPersonSeeTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        [[UIApplication sharedApplication].keyWindow addSubview:_resultPersonSeeTableView];
    }
    return _resultPersonSeeTableView;

}


- (UIView *)searchBar {

    if (_searchBar == nil) {
        
        // 创建背景的点击按钮，点击隐藏搜索框
        _virtualButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _virtualButton.frame = CGRectZero;
        _virtualButton.backgroundColor = [UIColor colorWithRed:73/255.0 green:73/255.0 blue:73/255.0 alpha:1];
        _virtualButton.alpha = 0;
        [_virtualButton addTarget:self action:@selector(searchCancelAction) forControlEvents:UIControlEventTouchUpInside];
        [[UIApplication sharedApplication].keyWindow addSubview:_virtualButton];
        
        
        _searchBar = [[UIView alloc] initWithFrame:CGRectMake(0, -64, kScreenWidth, 64)];
        _searchBar.backgroundColor = [UIColor colorWithRed:217/255.0 green:222/255.0 blue:226/255.0 alpha:1];
        [[UIApplication sharedApplication].keyWindow addSubview:_searchBar];
        
        UIView *virtualView = [[UIView alloc] initWithFrame:CGRectMake(7.5, 27.5, kScreenWidth - 7.5 - 55.5, 29)];
        virtualView.backgroundColor = [UIColor whiteColor];
        virtualView.layer.cornerRadius = 5;
        virtualView.layer.borderWidth = .5;
        virtualView.layer.borderColor = [UIColor colorWithRed:229/255.0 green:229/255.0 blue:229/255.0 alpha:1].CGColor;
        [_searchBar addSubview:virtualView];
        
        // 搜索输入框
        _input = [[UITextField alloc] initWithFrame:CGRectMake(15, 27.5, kScreenWidth - 55.5 - 15, 29)];
        _input.borderStyle = UITextBorderStyleNone;
        _input.delegate = self;
        _input.clearButtonMode = UITextFieldViewModeWhileEditing;
        _input.returnKeyType = UIReturnKeySearch;
        [_searchBar addSubview:_input];
        
        // 取消按钮
        UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        cancelButton.frame = CGRectMake(kScreenWidth - 55.5, 27.5, 55.5, 29);
        [cancelButton setTitleColor:[UIColor colorWithRed:29/255.0 green:161/255.0 blue:243/255.0 alpha:1]
                           forState:UIControlStateNormal];
        [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
        [cancelButton addTarget:self action:@selector(searchCancelAction) forControlEvents:UIControlEventTouchUpInside];
        [_searchBar addSubview:cancelButton];
        
        // 放大镜搜索图片
        _searchImage = [[UIImageView alloc] initWithFrame:CGRectMake(23.5, 34, 17, 15.5)];
        _searchImage.image = [UIImage imageNamed:@"icon_search_image"];
        _searchImage.tag = 152;
        [_searchBar addSubview:_searchImage];
        // "搜索动态"
        _label = [[UILabel alloc] initWithFrame:CGRectMake(49, 35, 80, 14)];
        _label.text = @"搜索动态";
        _label.tag = 157;
        _label.font = [UIFont systemFontOfSize:14];
        _label.textColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1];
        [_searchBar addSubview:_label];
        
    }
    return _searchBar;

}

#pragma mark - 加载个人信息，然后在加载动态数据
- (void)loadData:(NSDictionary *)data {

    // 解析用户信息
    self.user_id = data[@"id"];
    self.nickname = data[@"nickname"];
    self.headImageUrl = data[@"head_img"];
    
    // 设置导航栏标题（在viewDidLoad中设置的话，会超前使用_nickname，导致没有显示内容）
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake((kScreenWidth - 100)/2.0, 2, 100, 40)];
    title.text = _nickname;
    title.font = [UIFont systemFontOfSize:17];
    title.textAlignment = NSTextAlignmentCenter;
    title.textColor = [UIColor whiteColor];
    self.navigationItem.titleView = title;
    
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
                                            [SVProgressHUD showErrorWithStatus:@"没有动态"];
                                            // [self.seeTableView.pullToRefreshView stopAnimating];
                                        }
                                        
                                    } failure:^(NSError *err) {
                                        [SVProgressHUD dismiss];
                                        [SVProgressHUD showErrorWithStatus:@"加载失败"];
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
                                            [SVProgressHUD showErrorWithStatus:@"没有更多动态"];
                                            // [self.seeTableView.pullToRefreshView stopAnimating];
                                        }
                                        
                                    } failure:^(NSError *err) {
                                        [SVProgressHUD dismiss];
                                        [SVProgressHUD showErrorWithStatus:@"加载失败"];
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
                                            [SVProgressHUD showErrorWithStatus:@"没有更多动态"];
                                            [self.seeTableView.infiniteScrollingView stopAnimating];
                                        }
                                        
                                    } failure:^(NSError *err) {
                                        [SVProgressHUD dismiss];
                                        [SVProgressHUD showErrorWithStatus:@"加载失败"];
                                    }];
    
    
}

#pragma mark - 处理数据
- (void)dataProcess:(NSArray *)array {
    
    if (_dataTag == 0) {
        [self.seeModelList removeAllObjects];
    }

    NSMutableArray *seeTempArr = [NSMutableArray array];
    NSString *dateStr = @"";
    for (NSDictionary *dic in array) {
        PersonSeeModel *model = [[PersonSeeModel alloc] init];
        model.about_id = dic[@"id"];
        model.user_id = dic[@"user_id"];
        model.content = dic[@"content"];
        model.about_img = dic[@"about_img"];
        model.place = dic[@"place"];
        model.create_time = dic[@"create_time"];
        model.thumb_img = dic[@"thumb_img"];
        
        PersonSeeLayout *layout = [[PersonSeeLayout alloc] init];
        
        // 判断时间，处理单元格要不要显示时间标签
        // 如果标志的字符串为空或者跟当前model的时间不一致，那么当前单元格就应该显示时间
        
        // 先将年月日提取出来，不然只靠时间戳，判断时间肯定都是不一样的
        // 时间戳转换时间
        NSDate *confromTimesp = [NSDate dateWithTimeIntervalSince1970:[dic[@"create_time"] integerValue]];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateStyle:NSDateFormatterMediumStyle];
        [formatter setTimeStyle:NSDateFormatterShortStyle];
        [formatter setDateFormat:@"YYYY-MM-dd"];
        NSString *confromTimespStr = [formatter stringFromDate:confromTimesp];
        
        if ([dateStr isEqualToString:confromTimespStr]) {
            layout.isFirst = NO;
        } else {
            layout.isFirst = YES;
            dateStr = confromTimespStr;
        }
        
        // 有了_isFirst标志，就可以在model中使判断了
        layout.personSeeModel = model;
        
        
        
        
        [seeTempArr addObject:layout];
    }
    
    if (_dataTag == 0) {
        self.seeModelList = seeTempArr;
        [self.seeTableView.pullToRefreshView stopAnimating];
        self.seeTableView.seeLayoutList = self.seeModelList;
        self.seeTableView.user_id = _user_id;
        self.seeTableView.headImageUrl = _headImageUrl;
        self.seeTableView.nickname = _nickname;
        [self.seeTableView reloadData];
    } else {
        [self.seeModelList addObjectsFromArray:seeTempArr];
        [self.seeTableView.infiniteScrollingView stopAnimating];
        self.seeTableView.seeLayoutList = self.seeModelList;
        self.seeTableView.user_id = _user_id;
        self.seeTableView.headImageUrl = _headImageUrl;
        self.seeTableView.nickname = _nickname;
        [self.seeTableView reloadData];
    }
    
    
    
    
    
    
}


#pragma mark - 导航栏按钮响应
- (void)searchButtonAction:(UIBarButtonItem *)item {

    [UIView animateWithDuration:.35
                     animations:^{
                         self.searchBar.transform = CGAffineTransformMakeTranslation(0, 64);
                     } completion:^(BOOL finished) {
                         _virtualButton.frame = [UIScreen mainScreen].bounds;
                         [UIView animateWithDuration:.35 animations:^{
                             _virtualButton.alpha = .3;
                         }];
                     }];

}

// 取消搜索，将视图移除
- (void)searchCancelAction{

    // 移除
    [UIView animateWithDuration:.35
                     animations:^{
                         _virtualButton.alpha = 0;
                         _resultLabel.alpha = 0;
                         _searchBar.transform = CGAffineTransformMakeTranslation(0, -64);
                         _resultPersonSeeTableView.alpha = 0;
                     } completion:^(BOOL finished) {
                         [_virtualButton removeFromSuperview];
                         _virtualButton = nil;
                         [_searchBar removeFromSuperview];
                         _searchBar = nil;
                         [_resultLabel removeFromSuperview];
                         _resultLabel = nil;
                         [_resultPersonSeeTableView removeFromSuperview];
                         _resultPersonSeeTableView = nil;
                     }];

}


#pragma mark - 搜索框的代理方法
- (void)textFieldDidBeginEditing:(UITextField *)textField {

    // 隐藏搜索框里面的提示
    [UIView animateWithDuration:.35
                     animations:^{
                         _searchImage.alpha = 0;
                         _label.alpha = 0;
                     }];

}

// 按下return按钮，那就开始搜索
- (BOOL)textFieldShouldReturn:(UITextField *)textField {

    NSDictionary *params = @{@"user_id":_user_id,
                             @"string":textField.text};
    [CNetTool searchAboutWithParameters:params
                                success:^(id response) {
                                    if ([response[@"msg"] isEqual:@1]) {
                                        // 处理数据
                                        NSArray *dataArr = response[@"data"];
                                        NSMutableArray *seeTempArr = [NSMutableArray array];
                                        for (NSDictionary *dic in dataArr) {
                                            PersonSeeModel *model = [[PersonSeeModel alloc] init];
                                            model.about_id = dic[@"id"];
                                            model.user_id = dic[@"user_id"];
                                            model.content = dic[@"content"];
                                            model.place = dic[@"place"];
                                            model.about_img = dic[@"about_img"];
                                            model.create_time = dic[@"create_time"];
                                            model.thumb_img = dic[@"thumb_img"];
                                            PersonSeeLayout *layout = [[PersonSeeLayout alloc] init];
                                            // 要将isFirst放在设置model之前，不然使用无法使用isFirst来确定是否创建时间标签
                                            layout.isFirst = YES;
                                            layout.personSeeModel = model;
                                            [seeTempArr addObject:layout];
                                        }
                                        // 搜索结果提示
                                        self.resultLabel.text = [NSString stringWithFormat:@"   %ld条搜索结果",seeTempArr.count];
                                        // 将结果显示到表视图
                                        self.resultPersonSeeTableView.seeLayoutList = seeTempArr;
                                        // 刷新表视视图
                                        [_resultPersonSeeTableView reloadData];
                                        // 做动画，将视图显示出来
                                        [UIView animateWithDuration:.35
                                                         animations:^{
                                                             _resultLabel.alpha = 1;
                                                             _resultPersonSeeTableView.alpha = 1;
                                                         }];
                                        // 隐藏键盘
                                        [_input endEditing:YES];
                                    } else {
                                        [SVProgressHUD dismiss];
                                        [SVProgressHUD showErrorWithStatus:@"毫无结果"];
                                    }
                                } failure:^(NSError *err) {
                                    [SVProgressHUD dismiss];
                                    [SVProgressHUD showErrorWithStatus:@"搜索失败"];
                                }];
    
    
    return YES;

}

// 按下清除按钮，隐藏搜索结果
- (BOOL)textFieldShouldClear:(UITextField *)textField {

    [UIView animateWithDuration:.35
                     animations:^{
                         _resultLabel.alpha = 0;
                         _resultPersonSeeTableView.alpha = 0;
                     } completion:^(BOOL finished) {
                         [_resultLabel removeFromSuperview];
                         _resultLabel = nil;
                         
                         [_resultPersonSeeTableView removeFromSuperview];
                         _resultPersonSeeTableView = nil;
                     }];
    
    return YES;

}











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
