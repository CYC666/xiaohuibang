//
//  AboutDetialLayout.h
//  XiaoHuiBang
//
//  Created by mac on 16/11/30.
//  Copyright © 2016年 消汇邦. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SeeModel.h"

@interface AboutDetialLayout : NSObject

@property (strong, nonatomic) SeeModel *seeModel;
@property (assign, nonatomic) float viewHeight;                     // 视图的高度
@property (assign, nonatomic) CGRect headImageFrame;                // 头像
@property (assign, nonatomic) CGRect nicknameFrame;                 // 昵称
@property (assign, nonatomic) CGRect contentFrame;                  // 内容

@property (strong, nonatomic) NSMutableArray *imageFrameArr;        // 图片frame数组
@property (assign, nonatomic) CGRect movieFrame;                    // 视频frame
@property (assign, nonatomic) CGRect deleteButtonFrame;             // 删除按钮
@property (assign, nonatomic) CGRect timeLabelFrame;                // 时间标签
@property (copy, nonatomic) NSString *timeText;                     // 转化后的时间
@property (copy, nonatomic) NSString *locationText;                 // 转化后的定位
@property (assign, nonatomic) CGRect locationLabelFrame;            // 地址标签
@property (assign, nonatomic) CGRect proButtonFrame;                // 点赞按钮
@property (assign, nonatomic) CGRect commentButtonFrame;            // 评论按钮
@property (assign, nonatomic) CGRect proDetialImageFrame;           // 点赞详情图标
@property (assign, nonatomic) NSInteger headImageCount;             // 计算每行应该放多少个点赞人的头像
@property (assign, nonatomic) CGRect proLineFrame;                  // 点赞详情的分割线
@property (strong, nonatomic) NSMutableArray *proImageFrameArray;   // 点赞详情头像frame数组
@property (assign, nonatomic) CGRect commentDetialImageFrame;       // 评论详情图标
@property (strong, nonatomic) NSMutableArray *commentFrameArray;    // 评论详情文本frame数组
@property (assign, nonatomic) CGRect proAndCommentBackgroundFrame;  // 点赞和评论区的灰色背景

@end
