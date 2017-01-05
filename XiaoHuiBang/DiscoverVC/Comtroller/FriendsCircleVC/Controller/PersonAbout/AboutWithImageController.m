//
//  AboutWithImageController.m
//  XiaoHuiBang
//
//  Created by mac on 16/11/29.
//  Copyright © 2016年 消汇邦. All rights reserved.
//

// 显示带有图片的动态



#import "AboutWithImageController.h"
#import "CNetTool.h"
#import "PraiseModel.h"
#import "AveluateModel.h"
#import "AboutDetialController.h"
#import <SVProgressHUD.h>
#import <UIImageView+WebCache.h>
#import "CScrollImage.h"
#import "NSString+CEmojChange.h"
#import "CWebPlayerLayer.h"




#define kScreenHeight [UIScreen mainScreen].bounds.size.height          // 屏高
#define kScreenWidth [UIScreen mainScreen].bounds.size.width            // 屏宽

#define NotigicationOfSelfTranslucent @"NotigicationOfSelfTranslucent"  // 修改导航栏不透明的通知


@interface AboutWithImageController () <UITextFieldDelegate, UICollectionViewDelegate> {

    UIView *_tabView;                                   // 底部收纳按钮的视图
    UITextField *_inputField;                           // 底部输入框
    UILabel *_proLabel;                                 // 点赞人数
    UILabel *_commentLabel;                             // 评论人数
}

@property (assign, nonatomic) BOOL isHideNav;           // 是否隐藏导航栏
@property (assign, nonatomic) BOOL isShowKeyBoard;      // 是否已经展示了键盘
@property (assign, nonatomic) NSInteger proCount;       // 点赞人数
@property (assign, nonatomic) NSInteger commentCount;   // 评论人数

@property (strong, nonatomic) CWebPlayerLayer *playerView;  // 播放器

@end

@implementation AboutWithImageController


- (instancetype)initWithUserID:(NSString *)userID
                       aboutID:(NSString *)aboutID {

    self = [super init];
    if (self != nil) {
        // 请求单条动态
        NSDictionary *params = @{@"user_id":userID,
                                 @"about_id":aboutID};
        [CNetTool loadOneAboutWithParameters:params
                                     success:^(id response) {
                                         if ([response[@"msg"] isEqual:@1]) {
                                             NSDictionary *dic = response[@"data"];
                                             self.seeModel.about_id = dic[@"id"];
                                             self.seeModel.user_id = dic[@"user_id"];
                                             self.seeModel.nickname = dic[@"nickname"];
                                             self.seeModel.head_img = dic[@"head_img"];
                                             self.seeModel.content = dic[@"content"];
                                             self.seeModel.type = dic[@"type"];
                                             if ([dic[@"type"] isEqualToString:@"2"]) {
                                                 self.seeModel.about_img = dic[@"about_img"];
                                                 self.seeModel.thumb_img = dic[@"thumb_img"];
                                             } else if ([dic[@"type"] isEqualToString:@"3"]) {
                                                 self.seeModel.movie = dic[@"video"];
                                                 self.seeModel.movieThumb = dic[@"jt"];
                                             }
                                             
                                             self.seeModel.create_time = dic[@"create_time"];
                                             NSMutableArray *praiseTempArr = [NSMutableArray array];
                                             for (NSDictionary *praiseDic in dic[@"praise"]) {
                                                 PraiseModel *praiseModel = [[PraiseModel alloc] init];
                                                 praiseModel.nickname = praiseDic[@"nickname"];
                                                 praiseModel.user_id = praiseDic[@"user_id"];
                                                 [praiseTempArr addObject:praiseModel];
                                             }
                                             self.seeModel.praise = praiseTempArr;
                                             NSMutableArray *aveluateTempArr = [NSMutableArray array];
                                             for (NSDictionary *aveluateDic in dic[@"aveluate"]) {
                                                 AveluateModel *aveluateModel = [[AveluateModel alloc] init];
                                                 aveluateModel.nickname = aveluateDic[@"nickname"];
                                                 aveluateModel.user_id = aveluateDic[@"user_id"];
                                                 aveluateModel.about_content = aveluateDic[@"about_content"];
                                                 aveluateModel.eva_id = aveluateDic[@"eva_id"];
                                                 [aveluateTempArr addObject:aveluateModel];
                                             }
                                             self.seeModel.aveluate = aveluateTempArr;
                                             
                                             // 接受到数据菜创建子视图
                                             [self _creatSubview];
                                             
                                         } 
                                     } failure:^(NSError *err) {
                                         [SVProgressHUD dismiss];
                                         [SVProgressHUD showErrorWithStatus:@"加载失败"];
                                     }];
    }
    return self;

}
#pragma mark - 懒加载
//- (UIImageView *)aboutImageView {
//
//    if (_aboutImageView == nil) {
//        _aboutImageView = [[UIImageView alloc] initWithFrame:[UIScreen mainScreen].bounds];
//        _aboutImageView.userInteractionEnabled = YES;
//        _aboutImageView.contentMode = UIViewContentModeScaleAspectFit;
//        [self.view addSubview:_aboutImageView];
//        //  添加手势，点击隐藏、显示导航栏、标签栏
//        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
//        [_aboutImageView addGestureRecognizer:tap];
//    }
//    return _aboutImageView;
//
//}



- (SeeModel *)seeModel {

    if (_seeModel == nil) {
        _seeModel = [[SeeModel alloc] init];
    }
    return _seeModel;

}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];
    
    // 导航栏右边的详情按钮
    UIBarButtonItem *detialItem = [[UIBarButtonItem alloc] initWithTitle:@"详情"
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self action:@selector(commentAction)];
    [self.navigationItem setRightBarButtonItem:detialItem];
    
    
    // 监听键盘弹出的通知
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyBoardShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    // 监听键盘收回
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(hideBoardShow:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

#pragma mark - 创建子视图
- (void)_creatSubview {
    
    // 时间戳转换时间
    NSDate *confromTimesp = [NSDate dateWithTimeIntervalSince1970:[_seeModel.create_time integerValue]];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"YYYY年MM月dd日 HH:mm:ss"];
    NSString *confromTimespStr = [formatter stringFromDate:confromTimesp];
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake((kScreenWidth - 100)/2.0, 0, 100, 40)];
    title.text = confromTimespStr;
    title.textAlignment = NSTextAlignmentCenter;
    title.textColor = [UIColor whiteColor];
    self.navigationItem.titleView = title;

    if ([_seeModel.type isEqualToString:@"2"]) {
        // 设置图片
        CScrollImage *cScrollView = [[CScrollImage alloc] initWithFrame:[UIScreen mainScreen].bounds
                                                             imageArray:_seeModel.about_img
                                                        thumbImageArray:_seeModel.thumb_img
                                                            currentPage:0];
        [self.view addSubview:cScrollView];
        //  添加手势，点击隐藏、显示导航栏、标签栏(但是打开之后，视图会有上下偏移)(导航栏是否透明，会导致bounds的大小，从而引起视图的大小偏移)
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
        [cScrollView addGestureRecognizer:tap];
    } else if ([_seeModel.type isEqualToString:@"3"]) {
    
        _playerView = [[CWebPlayerLayer alloc] initWithFrame:[UIScreen mainScreen].bounds
                                                                     withUrl:_seeModel.movie
                       movieThumb:_seeModel.movieThumb];
        // 设置循环播放
        _playerView.isCycle = YES;
        [self.view addSubview:_playerView];
        
    }
    
    
    // 创建底部的按钮栏
    _tabView = [[UIView alloc] initWithFrame:CGRectMake(0, kScreenHeight - 49, kScreenWidth, 49)];
    _tabView.backgroundColor = [UIColor colorWithRed:15/255.0 green:15/255.0 blue:15/255.0 alpha:1];
    [self.view addSubview:_tabView];
    
    // 点赞按钮
    UIButton *proButton = [UIButton buttonWithType:UIButtonTypeCustom];
    proButton.frame = CGRectMake(kScreenWidth-114.5-18, 16.5, 18, 16);
    [proButton setImage:[UIImage imageNamed:@"icon_pro_gray"] forState:UIControlStateNormal];
    // 判断我是否已经点赞
    for (int i = 0; i < _seeModel.praise.count; i++) {
        PraiseModel *praiseModel = _seeModel.praise[i];
        if ([praiseModel.user_id isEqualToString:[USER_D objectForKey:@"user_id"]]) {
            [proButton setImage:[UIImage imageNamed:@"icon_pro_red"] forState:UIControlStateNormal];
            break;
        }
    }
    // 点赞添加响应
    [proButton addTarget:self action:@selector(proAction:) forControlEvents:UIControlEventTouchUpInside];
    
    [_tabView addSubview:proButton];
    
    // 点赞人数
    _proLabel = [[UILabel alloc] initWithFrame:CGRectMake(kScreenWidth - 83.5 - 15, 19, 20, 11.5)];
    _proCount = _seeModel.praise.count;
    _proLabel.text = [NSString stringWithFormat:@"%ld", _proCount];
    _proLabel.font = [UIFont systemFontOfSize:16];
    _proLabel.textColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1];
    _proLabel.textAlignment = NSTextAlignmentRight;
    [_tabView addSubview:_proLabel];
    
    
    // 分割线
    UIImageView *line = [[UIImageView alloc] initWithFrame:CGRectMake(kScreenWidth - 72, 14.5, 1, 20)];
    line.backgroundColor = [UIColor colorWithRed:46/255.0 green:46/255.0 blue:46/255.0 alpha:.7];
    [_tabView addSubview:line];
    
    // 评论按钮
     UIButton *commentButton = [UIButton buttonWithType:UIButtonTypeCustom];
     commentButton.frame = CGRectMake(kScreenWidth-38.5-17.5, 16.5, 17.5, 16);
    [commentButton setImage:[UIImage imageNamed:@"icon_comment_gray"] forState:UIControlStateNormal];
    [commentButton addTarget:self action:@selector(commentAction) forControlEvents:UIControlEventTouchUpInside];
    [_tabView addSubview:commentButton];
    
    // 评论人数
    _commentLabel = [[UILabel alloc] initWithFrame:CGRectMake(kScreenWidth - 20 - 15, 19, 20, 11.5)];
    _commentCount = _seeModel.aveluate.count;
    _commentLabel.text = [NSString stringWithFormat:@"%ld", _commentCount];
    _commentLabel.font = [UIFont systemFontOfSize:16];
    _commentLabel.textColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1];
    _commentLabel.textAlignment = NSTextAlignmentRight;
    [_tabView addSubview:_commentLabel];
    
    // 评论输入框
    _inputField = [[UITextField alloc] initWithFrame:CGRectMake(12, 10, kScreenWidth-164.5-12, 29)];
    _inputField.textColor = [UIColor whiteColor];
    _inputField.returnKeyType = UIReturnKeySend;
    _inputField.borderStyle = UITextBorderStyleNone;
    _inputField.layer.borderWidth = .5;
    _inputField.layer.borderColor = [UIColor colorWithRed:46/255.0 green:46/255.0 blue:46/255.0 alpha:1].CGColor;
    _inputField.backgroundColor = [UIColor colorWithRed:33/255.0 green:33/255.0 blue:33/255.0 alpha:1];
    _inputField.delegate = self;
    [_tabView addSubview:_inputField];
  
}

#pragma mark - image的点击手势，显示/隐藏导航栏、标签栏
- (void)tapAction:(UITapGestureRecognizer *)tap {

    _isHideNav = !_isHideNav;
    if (_isHideNav == YES) {
        
        
        [UIView animateWithDuration:.35
                         animations:^{
                             // self.navigationController.navigationBar.transform = CGAffineTransformMakeTranslation(0, -64);
                             _tabView.transform = CGAffineTransformMakeTranslation(0, 49);
                             
                             // 当键盘已经显示,要收起键盘
                             if (_isShowKeyBoard == YES) {
                                 
                                 [_inputField endEditing:YES];
                                 
                             }
                             
                         }];
        
        
    } else {
        
        [UIView animateWithDuration:.35
                         animations:^{
                             // self.navigationController.navigationBar.transform = CGAffineTransformMakeTranslation(0, 0);
                             _tabView.transform = CGAffineTransformMakeTranslation(0, 0);
                         }];
    }

}

#pragma mark - 键盘弹出、收回
- (void)keyBoardShow:(NSNotification *)notification {

    _isShowKeyBoard = YES;
    
    CGRect rect = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    float height = rect.size.height;
    
    // 底部框上移
    [UIView animateWithDuration:.35
                     animations:^{
                         _tabView.transform = CGAffineTransformMakeTranslation(0, -height);
                     }];

}
- (void)hideBoardShow:(NSNotification *)notification {

    _isShowKeyBoard = NO;
    
    // 底部框下移
    [UIView animateWithDuration:.35
                     animations:^{
                         if (_isHideNav == YES) {
                             _tabView.transform = CGAffineTransformMakeTranslation(0, 49);
                         } else {
                             _tabView.transform = CGAffineTransformMakeTranslation(0, 0);
                         }
                     }];

}


#pragma mark - textfield的代理方法，点击return发送评论
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    NSString *comment = [textField.text changeToString];

    NSDictionary *params = @{@"user_id":[USER_D objectForKey:@"user_id"],
                             @"about_id":_seeModel.about_id,
                             @"about_content":comment};
    
    // 发送评论
    [CNetTool postCommentWithParameters:params
                                success:^(id response) {
                                    if ([response[@"msg"] isEqual:@1]) {
                                        [SVProgressHUD dismiss];
                                        [SVProgressHUD showSuccessWithStatus:@"评论成功"];
                                        _commentLabel.text = [NSString stringWithFormat:@"%ld", ++_commentCount];
                                        textField.text = nil;
                                        
                                    }
                                } failure:^(NSError *err) {
                                    [SVProgressHUD dismiss];
                                    [SVProgressHUD showErrorWithStatus:@"评论失败"];
                                }];

    // 不管成不成功，先收起键盘再说，要不然重复点击会多次请求。如果发送不成功的话，不会将输入框的内容清除
    [textField endEditing:YES];
    return YES;

}

#pragma mark - 点赞
- (void)proAction:(UIButton *)button {

    
    // 发送点赞请求
    NSDictionary *params = @{@"user_id":[USER_D objectForKey:@"user_id"],
                             @"about_id":_seeModel.about_id};
    

    [CNetTool postProWithParameters:params
                            success:^(id response) {
                                if ([response[@"data"] isEqualToString:@"ok"]) {
                                    _proLabel.text = [NSString stringWithFormat:@"%ld", ++_proCount];
                                    [button setImage:[UIImage imageNamed:@"icon_pro_red"] forState:UIControlStateNormal];
                                } else {
                                    [SVProgressHUD dismiss];
                                    [SVProgressHUD showSuccessWithStatus:@"取消点赞成功"];
                                    _proLabel.text = [NSString stringWithFormat:@"%ld", --_proCount];
                                    [button setImage:[UIImage imageNamed:@"icon_pro_gray"] forState:UIControlStateNormal];
                                }
                                
                            } failure:^(NSError *err) {
                                [SVProgressHUD dismiss];
                                [SVProgressHUD showErrorWithStatus:@"请求失败"];
                            }];

    
    
}

#pragma mark - 点击评论按钮，跳转到单条动态界面
- (void)commentAction {

    // 收起键盘
    [_inputField endEditing:YES];
    
    AboutDetialController *detialController = [[AboutDetialController alloc] initWithUserID:_seeModel.user_id aboutID:_seeModel.about_id];
    [self.navigationController pushViewController:detialController animated:YES];

}



















// 当控制器出现了，将导航栏设置为透明的
- (void)viewWillAppear:(BOOL)animated {

    self.navigationController.navigationBar.translucent = YES;
    if (_playerView != nil) {
        [_playerView.player play];
    }

}

// 当视图即将消失时，将导航栏归原样
// 如果存在播放器，那就暂停
- (void)viewWillDisappear:(BOOL)animated {

//    [UIView animateWithDuration:.35
//                     animations:^{
//                         self.navigationController.navigationBar.transform = CGAffineTransformIdentity;
//                     }];
    
    if (_playerView != nil) {
        [_playerView.player pause];
    }

}

// 控制器销毁之前，将导航栏设置回不透明，不然会影响其他导航栏
- (void)dealloc {

    [[NSNotificationCenter defaultCenter] postNotificationName:NotigicationOfSelfTranslucent object:nil];

}


@end
