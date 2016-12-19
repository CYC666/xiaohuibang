//
//  AboutDetialController.m
//  XiaoHuiBang
//
//  Created by mac on 16/11/30.
//  Copyright © 2016年 消汇邦. All rights reserved.
//


// 单条动态详情


#import "AboutDetialController.h"
#import "CLabel.h"
#import "CNetTool.h"
#import "SeeModel.h"
#import "CImageView.h"
#import "PraiseModel.h"
#import "AveluateModel.h"
#import "PersonAboutController.h"
#import <SVProgressHUD.h>
#import <UIImageView+WebCache.h>
#import "NSString+CEmojChange.h"
#import "LocationController.h"

#define kScreenHeight [UIScreen mainScreen].bounds.size.height  // 屏高
#define kScreenWidth [UIScreen mainScreen].bounds.size.width    // 屏宽



@interface AboutDetialController () <UITextViewDelegate, UIScrollViewDelegate, CImageViewDelegate, CLabelDeletage> {

    UITextView *_inputView;                                     // 输入框
    UILabel *_holdLabel;                                        // "发表评论"字样

}

@property (assign, nonatomic) BOOL isLike;                      // 是否已经点赞
@property (copy, nonatomic) NSString *user_id;
@property (copy, nonatomic) NSString *about_id;

@end

@implementation AboutDetialController


- (instancetype)initWithUserID:(NSString *)userID aboutID:(NSString *)aboutID {

    self = [super init];
    if (self != nil) {
        // 请求单条动态
        NSDictionary *params = @{@"user_id":userID,
                                 @"about_id":aboutID};
        _user_id = userID;
        _about_id = aboutID;
        [CNetTool loadOneAboutWithParameters:params
                                     success:^(id response) {
                                         if ([response[@"msg"] isEqual:@1]) {
                                             NSDictionary *dic = response[@"data"];
                                             SeeModel *seeModel = [[SeeModel alloc] init];
                                            seeModel.about_id = dic[@"id"];
                                            seeModel.user_id = dic[@"user_id"];
                                            seeModel.nickname = dic[@"nickname"];
                                            seeModel.head_img = dic[@"head_img"];
                                            seeModel.content = dic[@"content"];
                                            seeModel.place = dic[@"place"];
                                            seeModel.about_img = dic[@"about_img"];
                                            seeModel.thumb_img = dic[@"thumb_img"];
                                            seeModel.create_time = dic[@"create_time"];
                                             NSMutableArray *praiseTempArr = [NSMutableArray array];
                                             for (NSDictionary *praiseDic in dic[@"praise"]) {
                                                 PraiseModel *praiseModel = [[PraiseModel alloc] init];
                                                 praiseModel.nickname = praiseDic[@"nickname"];
                                                 praiseModel.user_id = praiseDic[@"user_id"];
                                                 praiseModel.thumb = praiseDic[@"thumb"];
                                                 [praiseTempArr addObject:praiseModel];
                                             }
                                             seeModel.praise = praiseTempArr;
                                             NSMutableArray *aveluateTempArr = [NSMutableArray array];
                                             for (NSDictionary *aveluateDic in dic[@"aveluate"]) {
                                                 AveluateModel *aveluateModel = [[AveluateModel alloc] init];
                                                 aveluateModel.nickname = aveluateDic[@"nickname"];
                                                 aveluateModel.user_id = aveluateDic[@"user_id"];
                                                 aveluateModel.about_content = aveluateDic[@"about_content"];
                                                 aveluateModel.thumb = aveluateDic[@"thumb"];
                                                 aveluateModel.eva_id = aveluateDic[@"eva_id"];
                                                 [aveluateTempArr addObject:aveluateModel];
                                             }
                                             seeModel.aveluate = aveluateTempArr;
                                             
                                             self.detialLayout.seeModel = seeModel;
                                             
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

- (AboutDetialLayout *)detialLayout {

    if (_detialLayout == nil) {
        _detialLayout = [[AboutDetialLayout alloc] init];
    }
    return _detialLayout;

}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationController.navigationBar.translucent = NO;
    
}

- (void)viewDidAppear:(BOOL)animated {

    [super viewDidAppear:animated];

    // 创建输入框
    _inputView = [[UITextView alloc] initWithFrame:CGRectMake(13, kScreenHeight - 29 - 10, kScreenWidth - 13*2, 29)];
    _inputView.layer.cornerRadius = 3;
    _inputView.layer.borderWidth = 1;
    _inputView.backgroundColor = [UIColor colorWithRed:247/255.0 green:247/255.0 blue:247/255.0 alpha:1];
    _inputView.layer.borderColor = [UIColor colorWithRed:229/255.0 green:229/255.0 blue:229/255.0 alpha:1].CGColor;
    _inputView.delegate = self;
    _inputView.returnKeyType = UIReturnKeySend;
    [[UIApplication sharedApplication].keyWindow addSubview:_inputView];
    
    // "发表评论"
    _holdLabel = [[UILabel alloc] initWithFrame:CGRectMake(11.5, 7.5, 100, 13.5)];
    _holdLabel.text = @"发表评论";
    _holdLabel.textColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1];
    _holdLabel.font = [UIFont systemFontOfSize:14];
    [_inputView addSubview:_holdLabel];
    
    // 显示键盘
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showKeyBoard:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    // 隐藏键盘
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(hideKeyBoard:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
}

- (void)viewWillDisappear:(BOOL)animated {

    [super viewWillDisappear:animated];
    
    // 移除输入框
    [_inputView removeFromSuperview];
    _inputView = nil;
    
}

#pragma mark - 创建子视图
- (void)_creatSubview {

    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
    // 根据评论控制滑动视图的高度
    if (_detialLayout.viewHeight + 100 > kScreenHeight) {
        scrollView.contentSize = CGSizeMake(kScreenWidth, _detialLayout.viewHeight + 100);
    } else {
        scrollView.contentSize = CGSizeMake(kScreenWidth, kScreenHeight);
    }
    scrollView.alwaysBounceVertical = YES;
    scrollView.delegate = self;
    [self.view addSubview:scrollView];
    
    // 头像
    UIImageView *headImageView = [[UIImageView alloc] initWithFrame:_detialLayout.headImageFrame];
    [headImageView sd_setImageWithURL:[NSURL URLWithString:_detialLayout.seeModel.head_img]];
    headImageView.layer.cornerRadius = 22;
    headImageView.clipsToBounds = YES;
    [scrollView addSubview:headImageView];
    
    // 昵称
    UILabel *nicknameLabel = [[UILabel alloc] initWithFrame:_detialLayout.nicknameFrame];
    nicknameLabel.text = _detialLayout.seeModel.nickname;
    nicknameLabel.font = [UIFont systemFontOfSize:16];
    nicknameLabel.textColor = [UIColor colorWithRed:35/255.0 green:97/255.0 blue:185/255.0 alpha:1];
    nicknameLabel.textAlignment = NSTextAlignmentLeft;
    [scrollView addSubview:nicknameLabel];
    
    // 文本
    CLabel *contentLabel = [[CLabel alloc] initWithFrame:_detialLayout.contentFrame];
    contentLabel.numberOfLines = 0;
    contentLabel.text = _detialLayout.seeModel.content;
    contentLabel.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1];
    contentLabel.font = [UIFont systemFontOfSize:15];
    contentLabel.delegate = self;
    
    __weak AboutDetialController *weakSelf = self;
    contentLabel.cLabelBlock = ^(NSArray *arr) {
    
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"请选择你的操作"
                                                                       message:nil
                                                                preferredStyle:UIAlertControllerStyleAlert];
        for (int i = 0; i < arr.count; i++) {
            NSString *str = arr[i];
            NSString *title;
            NSURL *url;
            if ([str characterAtIndex:0] == 'h') {
                title = [NSString stringWithFormat:@"打开网址-->%@", str];
                url = [NSURL URLWithString:[NSString stringWithFormat:@"%@", str]];
            } else {
                title = [NSString stringWithFormat:@"拨打电话-->%@", str];
                url = [NSURL URLWithString:[NSString stringWithFormat:@"tel://%@", str]];
            }
            
            UIAlertAction *sureAction = [UIAlertAction actionWithTitle:title
                                                                 style:UIAlertActionStyleDefault
                                                               handler:^(UIAlertAction * _Nonnull action) {
                                                                   [[UIApplication sharedApplication] openURL:url];
                                                               }];
            [alert addAction:sureAction];
        }
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消"
                                                               style:UIAlertActionStyleDefault
                                                             handler:nil];
        
        
        [alert addAction:cancelAction];
        [weakSelf presentViewController:alert animated:YES completion:nil];

    
    };
    [scrollView addSubview:contentLabel];
    
    // 图片
    for (int i = 0; i < _detialLayout.seeModel.about_img.count; i++) {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:[_detialLayout.imageFrameArr[i] CGRectValue]];
        [imageView sd_setImageWithURL:[NSURL URLWithString:_detialLayout.seeModel.thumb_img[i]]];
        if (_detialLayout.seeModel.about_img.count == 1) {
            imageView.contentMode = UIViewContentModeScaleAspectFit;
        } else {
            imageView.contentMode = UIViewContentModeScaleAspectFill;
            imageView.clipsToBounds = YES;
        }
        [scrollView addSubview:imageView];
    }
    
    // 删除按钮
    if ([_detialLayout.seeModel.user_id isEqualToString:[USER_D objectForKey:@"user_id"]]) {
        UIButton *deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        deleteButton.frame = _detialLayout.deleteButtonFrame;
        [deleteButton setTitle:@"删除" forState:UIControlStateNormal];
        deleteButton.titleLabel.font = [UIFont systemFontOfSize:13];
        [deleteButton setTitleColor:[UIColor colorWithRed:246/255.0 green:1/255.0 blue:0 alpha:1] forState:UIControlStateNormal];
        [deleteButton addTarget:self action:@selector(deleteAction:) forControlEvents:UIControlEventTouchUpInside];
        [scrollView addSubview:deleteButton];
    }
    
    // 时间标签
    UILabel *timeLabel = [[UILabel alloc] initWithFrame:_detialLayout.timeLabelFrame];
    timeLabel.text = _detialLayout.timeText;
    timeLabel.textColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1];
    timeLabel.font = [UIFont systemFontOfSize:13];
    [scrollView addSubview:timeLabel];
    
    // 位置标签
    if (_detialLayout.seeModel.place != nil) {
        UILabel *locationLabel = [[UILabel alloc] initWithFrame:_detialLayout.locationLabelFrame];
        locationLabel.text = _detialLayout.locationText;
        locationLabel.textColor = [UIColor colorWithRed:35/255.0 green:97/255.0 blue:185/255.0 alpha:1];
        locationLabel.font = [UIFont systemFontOfSize:13];
        // 添加点击手势，跳转到地图，显示定位
        locationLabel.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(locationTapAction:)];
        [locationLabel addGestureRecognizer:tap];
        [scrollView addSubview:locationLabel];
    }
    
    // 点赞按钮
    UIButton *proButton = [UIButton buttonWithType:UIButtonTypeCustom];
    proButton.frame = _detialLayout.proButtonFrame;
    [proButton setImage:[UIImage imageNamed:@"icon_pro_gray"] forState:UIControlStateNormal];
    // 判断我是否已经点赞
    for (int i = 0; i < _detialLayout.seeModel.praise.count; i++) {
        PraiseModel *praiseModel = _detialLayout.seeModel.praise[i];
        if ([praiseModel.user_id isEqualToString:[USER_D objectForKey:@"user_id"]]) {
            _isLike = YES;
            [proButton setImage:[UIImage imageNamed:@"icon_pro_selected"] forState:UIControlStateNormal];
            break;
        }
    }
    [proButton addTarget:self action:@selector(proAction:) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:proButton];

    // 评论按钮
    UIButton *commentButton = [UIButton buttonWithType:UIButtonTypeCustom];
    commentButton.frame = _detialLayout.commentButtonFrame;
    [commentButton setImage:[UIImage imageNamed:@"icon_comment_new"] forState:UIControlStateNormal];
    [commentButton addTarget:self action:@selector(commentAction:) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:commentButton];
    
    // 点赞跟评论区背景颜色
    UIView *backgroundView = [[UIView alloc] initWithFrame:_detialLayout.proAndCommentBackgroundFrame];
    backgroundView.backgroundColor = [UIColor colorWithRed:238/255.0 green:238/255.0 blue:238/255.0 alpha:1];
    [scrollView addSubview:backgroundView];
    
    //  点赞列表
    if (_detialLayout.seeModel.praise.count > 0) {
        UIImageView *proDetialImage = [[UIImageView alloc] initWithFrame:_detialLayout.proDetialImageFrame];
        proDetialImage.image = [UIImage imageNamed:@"icon_pro"];
        [scrollView addSubview:proDetialImage];
        
        // 点赞人数列表
        for (int i = 0; i < _detialLayout.seeModel.praise.count; i++) {
            NSValue *value = _detialLayout.proImageFrameArray[i];
            CGRect rect = [value CGRectValue];
            CImageView *proImage = [[CImageView alloc] initWithFrame:rect];
            proImage.clipsToBounds = YES;
            proImage.layer.cornerRadius = 14.4;
            PraiseModel *praiseModel = _detialLayout.seeModel.praise[i];
            [proImage sd_setImageWithURL:[NSURL URLWithString:praiseModel.thumb]];
            proImage.imageID = praiseModel.user_id;
            proImage.delegate = self;
            [scrollView addSubview:proImage];
            
        }
        
    }
    
    // 点赞列表的分割线,当超过一行再创建分割线或者存在评论
    if (_detialLayout.seeModel.praise.count >= _detialLayout.headImageCount || _detialLayout.seeModel.aveluate.count > 0) {
        UIView *proLine = [[UIView alloc] initWithFrame:_detialLayout.proLineFrame];
        proLine.backgroundColor = [UIColor colorWithRed:229/255.0 green:229/255.0 blue:229/255.0 alpha:1];
        [scrollView addSubview:proLine];
    }
    
    // 评论列表
    if (_detialLayout.seeModel.aveluate.count > 0) {
        
        for (int i = 0; i < _detialLayout.seeModel.aveluate.count; i++) {
            NSDictionary *dic = _detialLayout.commentFrameArray[i];
            AveluateModel *aveluteModel = _detialLayout.seeModel.aveluate[i];
            // 头像
            NSValue *imageValue = dic[@"image"];
            CImageView *headImage = [[CImageView alloc] initWithFrame:[imageValue CGRectValue]];
            [headImage sd_setImageWithURL:[NSURL URLWithString:aveluteModel.thumb]];
            headImage.layer.cornerRadius = 14.4;
            headImage.clipsToBounds = YES;
            headImage.delegate = self;
            headImage.imageID = aveluteModel.user_id;
            [scrollView addSubview:headImage];
            // 昵称
            NSValue *nicknameValue = dic[@"nickname"];
            UILabel *nicknameLabel = [[UILabel alloc] initWithFrame:[nicknameValue CGRectValue]];
            nicknameLabel.text = aveluteModel.nickname;
            nicknameLabel.textColor = [UIColor colorWithRed:35/255.0 green:97/255.0 blue:185/255.0 alpha:1];
            nicknameLabel.font = [UIFont systemFontOfSize:14];
            nicknameLabel.textAlignment = NSTextAlignmentLeft;
            [scrollView addSubview:nicknameLabel];
            // 评论的内容
            NSValue *contentValue = dic[@"content"];
            CLabel *contentLabel = [[CLabel alloc] initWithFrame:[contentValue CGRectValue]];
            contentLabel.numberOfLines = 0;
            NSString *commentText = [aveluteModel.about_content changeToEmoj];
            contentLabel.text = commentText;
            contentLabel.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1];
            contentLabel.font = [UIFont systemFontOfSize:14];
            contentLabel.textAlignment = NSTextAlignmentLeft;
            contentLabel.delegate = self;
            contentLabel.labelID = aveluteModel.user_id;
            [scrollView addSubview:contentLabel];
            contentLabel.cLabelBlock = ^(NSArray *arr) {
            
                __weak AboutDetialController *weakSelf = self;
                if (arr.count != 0) {
                    // 如果有电话号码就弹出提示，如果没有就直接弹出评论
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"请选择你的操作"
                                                                                   message:nil
                                                                            preferredStyle:UIAlertControllerStyleAlert];
                    for (int i = 0; i < arr.count; i++) {
                        NSString *str = arr[i];
                        NSString *title;
                        NSURL *url;
                        if ([str characterAtIndex:0] == 'h') {
                            title = [NSString stringWithFormat:@"打开网址-->%@", str];
                            url = [NSURL URLWithString:[NSString stringWithFormat:@"%@", str]];
                        } else {
                            title = [NSString stringWithFormat:@"拨打电话-->%@", str];
                            url = [NSURL URLWithString:[NSString stringWithFormat:@"tel://%@", str]];
                        }
                        
                        UIAlertAction *sureAction = [UIAlertAction actionWithTitle:title
                                                                             style:UIAlertActionStyleDefault
                                                                           handler:^(UIAlertAction * _Nonnull action) {
                                                                               [[UIApplication sharedApplication] openURL:url];
                                                                           }];
                        [alert addAction:sureAction];
                    }
                    UIAlertAction *comAction = [UIAlertAction actionWithTitle:@"评论"
                                                                        style:UIAlertActionStyleDefault
                                                                      handler:^(UIAlertAction * _Nonnull action) {
                                                                          
                                                                          // 进行评论操作
                                                                          
                                                                      }];
                    
                    
                    [alert addAction:comAction];
                    
                    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消"
                                                                           style:UIAlertActionStyleDefault
                                                                         handler:nil];
                    
                    
                    [alert addAction:cancelAction];
                    [weakSelf presentViewController:alert animated:YES completion:nil];
                    
                } else {
                    
                    // 如果没有，那就直接评论咯(没必要用协议了)
                    
                    
                }
            
            };
            // 评论分割线,如果是最后一条，那就不需要分割线了
            if (i != _detialLayout.seeModel.aveluate.count-1) {
                NSValue *separatorLineValue = dic[@"line"];
                UIView *separatorLine = [[UIView alloc] initWithFrame:[separatorLineValue CGRectValue]];
                separatorLine.backgroundColor = [UIColor colorWithRed:229/255.0 green:229/255.0 blue:229/255.0 alpha:1];
                [scrollView addSubview:separatorLine];
            }

        }
        
    }
    
    
    
}

#pragma mark - 删除动态
- (void)deleteAction:(UIButton *)button {

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"确定要删除此条目？"
                                                                   message:@"删除后不可恢复"
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    
    // 确定删除动态按钮
    UIAlertAction *sureAction = [UIAlertAction actionWithTitle:@"确定"
                                                         style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction * _Nonnull action) {
                                                           NSDictionary *param = @{@"id":_detialLayout.seeModel.about_id};
                                                           [CNetTool deleteAboutWithParameters:param
                                                                                       success:^(id response) {
                                                                                           [SVProgressHUD dismiss];
                                                                                           [SVProgressHUD showSuccessWithStatus:@"删除动态成功"];
                                                                                           // 返回顶层页面
                                                                                           [self.navigationController popToRootViewControllerAnimated:YES];
                                                                                       } failure:^(NSError *err) {
                                                                                           [SVProgressHUD dismiss];
                                                                                           [SVProgressHUD showErrorWithStatus:@"删除动态失败"];
                                                                                       }];
                                                       }];
    
    // 取消删除动态按钮
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消"
                                                           style:UIAlertActionStyleDefault
                                                         handler:nil];
    [alert addAction:sureAction];
    [alert addAction:cancelAction];
    
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alert
                                                                                 animated:YES
                                                                               completion:nil];
    


}

#pragma mark - 点赞按钮
- (void)proAction:(UIButton *)button {

    _isLike = !_isLike;
    if (_isLike == YES) {
        
        
        // 网络请求点赞功能
        NSDictionary *param = @{
                                @"user_id":[USER_D objectForKey:@"user_id"],
                                @"about_id":_detialLayout.seeModel.about_id
                                };
        [CNetTool postProWithParameters:param
                                success:^(id response) {
                                    [button setImage:[UIImage imageNamed:@"icon_pro_selected"] forState:UIControlStateNormal];
                                    // 刷新UI
                                    [self reloadSubview];
                                } failure:^(NSError *err) {
                                    [SVProgressHUD dismiss];
                                    [SVProgressHUD showErrorWithStatus:@"点赞失败"];
                                }];
        
    } else {
        
        
        // 网络请求取消赞功能
        NSDictionary *param = @{
                                @"user_id":[USER_D objectForKey:@"user_id"],
                                @"about_id":_detialLayout.seeModel.about_id
                                };
        [CNetTool postProWithParameters:param
                                success:^(id response) {
                                    [button setImage:[UIImage imageNamed:@"icon_pro_gray"] forState:UIControlStateNormal];
                                    // 刷新UI
                                    [self reloadSubview];
                                } failure:^(NSError *err) {
                                    [SVProgressHUD dismiss];
                                    [SVProgressHUD showErrorWithStatus:@"取消点赞失败"];
                                }];
    }


}

#pragma mark - 评论按钮
- (void)commentAction:(UIButton *)button {

    
    
}



#pragma mark - 重新加载视图(重要)
- (void)reloadSubview {

    // 请求单条动态
    NSDictionary *params = @{@"user_id":_user_id,
                             @"about_id":_about_id};
    [CNetTool loadOneAboutWithParameters:params
                                 success:^(id response) {
                                     if ([response[@"msg"] isEqual:@1]) {
                                         NSDictionary *dic = response[@"data"];
                                         SeeModel *seeModel = [[SeeModel alloc] init];
                                         seeModel.about_id = dic[@"id"];
                                         seeModel.user_id = dic[@"user_id"];
                                         seeModel.nickname = dic[@"nickname"];
                                         seeModel.head_img = dic[@"head_img"];
                                         seeModel.content = dic[@"content"];
                                         seeModel.about_img = dic[@"about_img"];
                                         seeModel.thumb_img = dic[@"thumb_img"];
                                         seeModel.create_time = dic[@"create_time"];
                                         NSMutableArray *praiseTempArr = [NSMutableArray array];
                                         for (NSDictionary *praiseDic in dic[@"praise"]) {
                                             PraiseModel *praiseModel = [[PraiseModel alloc] init];
                                             praiseModel.nickname = praiseDic[@"nickname"];
                                             praiseModel.user_id = praiseDic[@"user_id"];
                                             praiseModel.thumb = praiseDic[@"thumb"];
                                             [praiseTempArr addObject:praiseModel];
                                         }
                                         seeModel.praise = praiseTempArr;
                                         NSMutableArray *aveluateTempArr = [NSMutableArray array];
                                         for (NSDictionary *aveluateDic in dic[@"aveluate"]) {
                                             AveluateModel *aveluateModel = [[AveluateModel alloc] init];
                                             aveluateModel.nickname = aveluateDic[@"nickname"];
                                             aveluateModel.user_id = aveluateDic[@"user_id"];
                                             aveluateModel.about_content = aveluateDic[@"about_content"];
                                             aveluateModel.thumb = aveluateDic[@"thumb"];
                                             aveluateModel.eva_id = aveluateDic[@"eva_id"];
                                             [aveluateTempArr addObject:aveluateModel];
                                         }
                                         seeModel.aveluate = aveluateTempArr;
                                         
                                         // 不重新创建的花，旧的内容不会改变
                                         _detialLayout = nil;
                                         
                                         self.detialLayout.seeModel = seeModel;
                                         
                                         // 移除所有子视图
                                         for (UIView *view in self.view.subviews) {
                                             [view removeFromSuperview];
                                         }
                                         // 接受到数据菜创建子视图
                                         [self _creatSubview];
                                         
                                     }
                                 } failure:^(NSError *err) {
                                     [SVProgressHUD dismiss];
                                     [SVProgressHUD showErrorWithStatus:@"加载失败"];
                                 }];

}

#pragma mark - 输入框代理方法
- (void)textViewDidChange:(UITextView *)textView {

    if (textView.text.length > 0 && _holdLabel.alpha == 1) {
        [UIView animateWithDuration:.35
                         animations:^{
                             _holdLabel.alpha = 0;
                         }];
    } else if (textView.text.length == 0 && _holdLabel.alpha == 0) {
        [UIView animateWithDuration:.35
                         animations:^{
                             _holdLabel.alpha = 1;
                         }];
    }    
    
    // 调节输入框高度
    CGRect rect = [textView.text boundingRectWithSize:CGSizeMake(kScreenHeight - 29 - 10, 9999)
                                              options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                           attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:14]}
                                              context:nil];
    CGRect frame = _inputView.frame;
    float oldHeight = frame.size.height;
    frame.size.height = rect.size.height + 8*2;
    frame.origin.y -= (frame.size.height - oldHeight);
    if (frame.size.height > _inputView.frame.size.height && frame.size.height < 300) {
        [UIView animateWithDuration:.35
                         animations:^{
                             _inputView.frame = frame;
                         }];
    }
}

#pragma mark - 检测是否点击了return
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {

    if ([text isEqualToString:@"\n"]) {
        // 发送评论
        
        NSString *comment = [textView.text changeToString];
        NSDictionary *params = @{@"user_id":[USER_D objectForKey:@"user_id"],
                                 @"about_id":_detialLayout.seeModel.about_id,
                                 @"about_content":comment};
        [CNetTool postCommentWithParameters:params
                                    success:^(id response) {
                                        if ([response[@"msg"] isEqual:@1]) {
                                            textView.text = nil;
                                            [textView endEditing:YES];
                                            [UIView animateWithDuration:.35
                                                             animations:^{
                                                                 textView.frame = CGRectMake(13, kScreenHeight - 29 - 10, kScreenWidth - 13*2, 29);
                                                             }];
                                            // 刷新视图
                                            [self reloadSubview];
                                            _holdLabel.alpha = 1;
                                        }
                                    } failure:^(NSError *err) {
                                        [SVProgressHUD dismiss];
                                        [SVProgressHUD showErrorWithStatus:@"评论失败"];
                                    }];
        return NO;
    }
    return YES;

}

#pragma mark - 滑动视图隐藏键盘
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {

    if ([scrollView isEqual:_inputView]) {
        return;
    }
    // 当不是滑动输入框才隐藏
    [_inputView endEditing:YES];

}


#pragma mark - 弹出键盘
- (void)showKeyBoard:(NSNotification *)notification {
    
    NSDictionary *userInfo = [notification userInfo];
    NSValue *value = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGFloat keyBoardHeight = value.CGRectValue.size.height;
    
    // 调节输入框位置
    _inputView.transform = CGAffineTransformMakeTranslation(0, -keyBoardHeight);
    
}

#pragma mark - 隐藏键盘
- (void)hideKeyBoard:(NSNotification *)notification {
    
    _inputView.transform = CGAffineTransformIdentity;
    
}

#pragma mark - 点击小头像调用的代理方法
- (void)cImageViewTouch:(CImageView *)cImageView {

    // 跳转到该用户的个人动态界面
    PersonAboutController *personController = [[PersonAboutController alloc] initWithUserID:cImageView.imageID];
    [self.navigationController pushViewController:personController animated:YES];

}

#pragma mark - 点击动态的内容响应代理方法
- (void)cLabelTouch:(CLabel *)cLabel {

    // 在这里可以做回复功能
    NSLog(@"%@", cLabel.text);

}

#pragma mark - 跳转到地图界面
- (void)locationTapAction:(UITapGestureRecognizer *)tap {
    
    LocationController *locationController = [[LocationController alloc] initWithLocationString:_detialLayout.seeModel.place];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:locationController];
    nav.navigationBar.barTintColor = [UIColor blackColor];
    nav.navigationBar.translucent = NO;
    [self presentViewController:nav animated:YES completion:nil];
    
}















// 移除通知
- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    
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
