//
//  UserJurisdictionSetController.m
//  XiaoHuiBang
//
//  Created by mac on 16/12/24.
//  Copyright © 2016年 消汇邦. All rights reserved.
//

#import "UserJurisdictionSetController.h"
#import "CNetTool.h"


#define kScreenHeight [UIScreen mainScreen].bounds.size.height                          // 屏高
#define kScreenWidth [UIScreen mainScreen].bounds.size.width                            // 屏宽



@interface UserJurisdictionSetController ()

@property (copy, nonatomic) NSString *userID;
@property (assign, nonatomic) BOOL seeIt;
@property (assign, nonatomic) BOOL letItSee;

@property (strong, nonatomic) UISwitch *seeItSwitch;
@property (strong, nonatomic) UISwitch *letItSeeSwitch;

@end

@implementation UserJurisdictionSetController

- (instancetype)initWithUserID:(NSString *)userID {

    if (self = [super init]) {
        _userID = userID;
        self.view.backgroundColor = [UIColor colorWithRed:238/255.0 green:238/255.0 blue:238/255.0 alpha:1];
        // 此处应该请求网络
        [self loadNetJurisdiction];
        
        [self _setNavigationBar];
        [self _creatSubviews];
    }
    return self;

}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
#pragma mark - 网络请求查看权限
- (void)loadNetJurisdiction {

    
    // 不看他动态
    NSDictionary *params = @{@"user_id" : [USER_D objectForKey:@"user_id"],
                             @"type" : @1};
    [CNetTool jurisdictionSeeWithParameters:params
                                    success:^(id response) {
                                        // 查询是否有此人
                                        if ([response[@"msg"] isEqual:@0]) {
                                            [_seeItSwitch setOn:NO];
                                            _seeIt = YES;
                                        } else if ([response[@"msg"] isEqual:@1]) {
                                            NSArray *array = response[@"data"];
                                            for (NSDictionary *dic in array) {
                                                if ([dic[@"user_id"] isEqualToString:_userID]) {
                                                    [_seeItSwitch setOn:YES];
                                                    _seeIt = NO;
                                                    break;
                                                }
                                            }
                                        }
                                    } failure:^(NSError *err) {
                                        
                                    }];

    // 不让他看我的动态
    NSDictionary *paramsB = @{@"user_id" : [USER_D objectForKey:@"user_id"],
                              @"type" : @2};
    [CNetTool jurisdictionSeeWithParameters:paramsB
                                    success:^(id response) {
                                        // 查询是否有此人
                                        if ([response[@"msg"] isEqual:@0]) {
                                            [_letItSeeSwitch setOn:NO];
                                            _letItSee = YES;
                                        } else if ([response[@"msg"] isEqual:@1]) {
                                            NSArray *array = response[@"data"];
                                            for (NSDictionary *dic in array) {
                                                if ([dic[@"user_id"] isEqualToString:_userID]) {
                                                    [_letItSeeSwitch setOn:YES];
                                                    _letItSee = NO;
                                                    break;
                                                }
                                            }
                                        }
                                    } failure:^(NSError *err) {
                                        
                                    }];

    
    
    
}

#pragma mark - 设置导航栏
- (void)_setNavigationBar {

    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 40)];
    title.text = @"设置邦友圈权限";
    title.textAlignment = NSTextAlignmentCenter;
    title.textColor = [UIColor whiteColor];
    title.font = [UIFont boldSystemFontOfSize:19];
    self.navigationItem.titleView = title;
    
    // 取消按钮
    UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] initWithTitle:@"关闭"
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(cancelButtonAction:)];
    [cancelItem setTintColor:[UIColor whiteColor]];
    [self.navigationItem setLeftBarButtonItem:cancelItem];
    
}

#pragma mark - 创建子视图
- (void)_creatSubviews {

    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
    scrollView.contentSize = CGSizeMake(kScreenWidth, kScreenHeight-64);
    scrollView.backgroundColor = [UIColor clearColor];
    scrollView.alwaysBounceVertical = YES;
    scrollView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:scrollView];
    
    // --------------------------------------------------不让他看朋友圈--------------------------------------------------------
    
    UIView *letItSeeView = [[UIView alloc] initWithFrame:CGRectMake(-0.5, 19.5, kScreenWidth + 1, 52)];
    letItSeeView.backgroundColor = [UIColor whiteColor];
    [scrollView addSubview:letItSeeView];
    
    UILabel *letItSeeLabelA = [[UILabel alloc] initWithFrame:CGRectMake(12, 19.5, 250, 16)];
    letItSeeLabelA.font = [UIFont boldSystemFontOfSize:16];
    letItSeeLabelA.text = @"不让他（她）看我的朋友圈";
    letItSeeLabelA.textAlignment = NSTextAlignmentLeft;
    [letItSeeView addSubview:letItSeeLabelA];
    
    _letItSeeSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(kScreenWidth - 51 - 13, (52 - 31)/2.0, 51, 31)];
    _letItSeeSwitch.onTintColor = [UIColor colorWithRed:0 green:162/255.0 blue:242/255.0 alpha:1];
    [_letItSeeSwitch setOn:NO];
    [_letItSeeSwitch addTarget:self action:@selector(letItSeeSwitchAction:) forControlEvents:UIControlEventValueChanged];
    [letItSeeView addSubview:_letItSeeSwitch];
    
    NSString *letItSeeText = @"打开后，你在邦友圈发的照片，他（她）将无法看到。";
    CGRect letItSeeTextRect = [letItSeeText boundingRectWithSize:CGSizeMake(kScreenWidth - 12 - 12, 99999)
                                                          options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin
                                                       attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:14]}
                                                          context:nil];
    UILabel *letItSeeLabelB = [[UILabel alloc] initWithFrame:CGRectMake(12, 83, (kScreenWidth - 12 - 12), letItSeeTextRect.size.height)];
    letItSeeLabelB.font = [UIFont boldSystemFontOfSize:14];
    letItSeeLabelB.text = letItSeeText;
    letItSeeLabelB.textAlignment = NSTextAlignmentLeft;
    letItSeeLabelB.numberOfLines = 0;
    letItSeeLabelB.textColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1];
    [scrollView addSubview:letItSeeLabelB];
    
    float letItSeeHeight = 83 + letItSeeTextRect.size.height;
    
    // ----------------------------------------------不看他朋友圈------------------------------------------------------------
    UIView *seeItView = [[UIView alloc] initWithFrame:CGRectMake(-0.5, letItSeeHeight + 19.5, kScreenWidth + 1, 52)];
    seeItView.backgroundColor = [UIColor whiteColor];
    [scrollView addSubview:seeItView];
    
    UILabel *seeItLabelA = [[UILabel alloc] initWithFrame:CGRectMake(12, 19.5, 250, 16)];
    seeItLabelA.font = [UIFont boldSystemFontOfSize:16];
    seeItLabelA.text = @"不看他（她）的朋友圈";
    seeItLabelA.textAlignment = NSTextAlignmentLeft;
    [seeItView addSubview:seeItLabelA];
    
    _seeItSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(kScreenWidth - 51 - 13, (52 - 31)/2.0, 51, 31)];
    _seeItSwitch.onTintColor = [UIColor colorWithRed:0 green:162/255.0 blue:242/255.0 alpha:1];
    [_seeItSwitch setOn:NO];
    [_seeItSwitch addTarget:self action:@selector(seeItSwitchAction:) forControlEvents:UIControlEventValueChanged];
    [seeItView addSubview:_seeItSwitch];
    
    NSString *seeItText = @"打开后，他（她）在邦友圈发的照片将不会出现在你的邦友圈里。";
    CGRect seeItTextRect = [seeItText boundingRectWithSize:CGSizeMake(kScreenWidth - 12 - 12, 99999)
                                                         options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin
                                                      attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:14]}
                                                         context:nil];
    UILabel *seeItLabelB = [[UILabel alloc] initWithFrame:CGRectMake(12, letItSeeHeight + 83, (kScreenWidth - 12 - 12), seeItTextRect.size.height)];
    seeItLabelB.font = [UIFont boldSystemFontOfSize:14];
    seeItLabelB.text = seeItText;
    seeItLabelB.textAlignment = NSTextAlignmentLeft;
    seeItLabelB.numberOfLines = 0;
    seeItLabelB.textColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1];
    [scrollView addSubview:seeItLabelB];
    
    
    

}

#pragma mark - 取消按钮
- (void)cancelButtonAction:(UIBarButtonItem *)item {

    [self dismissViewControllerAnimated:YES completion:nil];
    
}


#pragma mark - 不让他看我的动态开关响应
- (void)letItSeeSwitchAction:(UISwitch *)swt {


    if (swt.isOn) {
        NSDictionary *params = @{@"user_id" : [USER_D objectForKey:@"user_id"],
                                  @"friend_id" : _userID,
                                  @"type" : @2};
        [CNetTool jurisdictionAddWithParameters:params
                                        success:^(id response) {
                                            [SVProgressHUD dismiss];
                                            [SVProgressHUD showSuccessWithStatus:@"添加成功"];
                                            _letItSee = YES;
                                        } failure:^(NSError *err) {
                                            [SVProgressHUD dismiss];
                                            [SVProgressHUD showErrorWithStatus:@"添加失败"];
                                            [swt setOn:NO];
                                        }];
        
    } else {
        NSDictionary *params = @{@"user_id" : [USER_D objectForKey:@"user_id"],
                                 @"friend_id" : _userID,
                                 @"type" : @2};
        [CNetTool jurisdictionDeleteWithParameters:params
                                           success:^(id response) {
                                               [SVProgressHUD dismiss];
                                               [SVProgressHUD showSuccessWithStatus:@"成功移除"];
                                               _letItSee = NO;
                                           } failure:^(NSError *err) {
                                               [SVProgressHUD dismiss];
                                               [SVProgressHUD showErrorWithStatus:@"移除失败"];
                                               [swt setOn:YES];
                                           }];
        
    }

}


#pragma mark - 不看他的动态开关响应
- (void)seeItSwitchAction:(UISwitch *)swt {
    
    if (swt.isOn) {
        NSDictionary *params = @{@"user_id" : [USER_D objectForKey:@"user_id"],
                                 @"friend_id" : _userID,
                                 @"type" : @1};
        [CNetTool jurisdictionAddWithParameters:params
                                        success:^(id response) {
                                            [SVProgressHUD dismiss];
                                            [SVProgressHUD showSuccessWithStatus:@"添加成功"];
                                            _seeIt = YES;
                                        } failure:^(NSError *err) {
                                            [SVProgressHUD dismiss];
                                            [SVProgressHUD showErrorWithStatus:@"添加失败"];
                                            [swt setOn:NO];
                                        }];
        
    } else {
        NSDictionary *params = @{@"user_id" : [USER_D objectForKey:@"user_id"],
                                 @"friend_id" : _userID,
                                 @"type" : @1};
        [CNetTool jurisdictionDeleteWithParameters:params
                                           success:^(id response) {
                                               [SVProgressHUD dismiss];
                                               [SVProgressHUD showSuccessWithStatus:@"成功移除"];
                                               _seeIt = NO;
                                           } failure:^(NSError *err) {
                                               [SVProgressHUD dismiss];
                                               [SVProgressHUD showErrorWithStatus:@"移除失败"];
                                               [swt setOn:YES];
                                           }];
        
    }
    
}

































@end
