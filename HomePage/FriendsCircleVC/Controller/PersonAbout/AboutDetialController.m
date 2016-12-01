//
//  AboutDetialController.m
//  XiaoHuiBang
//
//  Created by mac on 16/11/30.
//  Copyright © 2016年 消汇邦. All rights reserved.
//


// 单条动态详情


#import "AboutDetialController.h"
#import "CNetTool.h"
#import "SeeModel.h"
#import "PraiseModel.h"
#import "AveluateModel.h"
#import <SVProgressHUD.h>
#import <UIImageView+WebCache.h>

#define kScreenHeight [UIScreen mainScreen].bounds.size.height  // 屏高
#define kScreenWidth [UIScreen mainScreen].bounds.size.width    // 屏宽


@interface AboutDetialController ()

@end

@implementation AboutDetialController


- (instancetype)initWithUserID:(NSString *)userID aboutID:(NSString *)aboutID {

    self = [super init];
    if (self != nil) {
        // 请求单条动态
        NSDictionary *params = @{@"user_id":userID,
                                 @"about_id":aboutID};
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
                                             
                                             self.detialLayout.seeModel = seeModel;
                                             
                                             // 接受到数据菜创建子视图
                                             [self _creatSubview];
                                             
                                         }
                                     } failure:^(NSError *err) {
                                         [SVProgressHUD dismiss];
                                         [SVProgressHUD showSuccessWithStatus:@"加载失败"];
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
    
}

#pragma mark - 创建子视图
- (void)_creatSubview {

    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
    scrollView.contentSize = CGSizeMake(kScreenWidth, kScreenHeight);
    scrollView.alwaysBounceVertical = YES;
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
    UILabel *contentLabel = [[UILabel alloc] initWithFrame:_detialLayout.contentFrame];
    contentLabel.numberOfLines = 0;
    contentLabel.text = _detialLayout.seeModel.content;
    contentLabel.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1];
    contentLabel.font = [UIFont systemFontOfSize:15];
    [scrollView addSubview:contentLabel];
    
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
    timeLabel.numberOfLines = 0;
    timeLabel.text = _detialLayout.timeText;
    timeLabel.textColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1];
    timeLabel.font = [UIFont systemFontOfSize:15];
    [scrollView addSubview:timeLabel];
    
    // 点赞按钮
    UIButton *proButton = [UIButton buttonWithType:UIButtonTypeCustom];
    proButton.frame = _detialLayout.proButtonFrame;
    [proButton setImage:[UIImage imageNamed:@"icon_pro_gray"] forState:UIControlStateNormal];
    // 判断我是否已经点赞
    for (int i = 0; i < _detialLayout.seeModel.praise.count; i++) {
        PraiseModel *praiseModel = _detialLayout.seeModel.praise[i];
        if ([praiseModel.user_id isEqualToString:[USER_D objectForKey:@"user_id"]]) {
            [proButton setImage:[UIImage imageNamed:@"icon_pro_red"] forState:UIControlStateNormal];
            break;
        }
    }
    [proButton addTarget:self action:@selector(proAction:) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:proButton];

    // 评论按钮
    UIButton *commentButton = [UIButton buttonWithType:UIButtonTypeCustom];
    commentButton.frame = _detialLayout.commentButtonFrame;
    [commentButton setImage:[UIImage imageNamed:@"icon_comment_gray"] forState:UIControlStateNormal];
    [commentButton addTarget:self action:@selector(commentAction:) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:commentButton];
    
    //  点赞列表
    if (_detialLayout.seeModel.praise.count > 0) {
        UIImageView *proDetialImage = [[UIImageView alloc] initWithFrame:_detialLayout.proDetialImageFrame];
        proDetialImage.image = [UIImage imageNamed:@"icon_pro_blue"];
        [scrollView addSubview:proDetialImage];
        
        // 点赞人数列表
        for (int i = 0; i < _detialLayout.seeModel.praise.count; i++) {
            NSValue *value = _detialLayout.proImageFrameArray[i];
            CGRect rect = [value CGRectValue];
            UIImageView *proImage = [[UIImageView alloc] initWithFrame:rect];
            proImage.clipsToBounds = YES;
            proImage.layer.cornerRadius = 14.4;
            PraiseModel *praiseModel = _detialLayout.seeModel.praise[i];
            [proImage sd_setImageWithURL:[NSURL URLWithString:praiseModel.thumb]];
            [scrollView addSubview:proImage];
        }
        
    }
    
    
}

#pragma mark - 删除动态
- (void)deleteAction:(UIButton *)button {



}

#pragma mark - 点赞按钮
- (void)proAction:(UIButton *)button {



}

#pragma mark - 评论按钮
- (void)commentAction:(UIButton *)button {



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
