//
//  CLabel.h
//  LabelDelegate
//
//  Created by mac on 16/12/3.
//  Copyright © 2016年 CYC. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^CLableBlock)(NSArray *);

typedef enum : NSUInteger {
    CContent,       // 动态详情文本
    CComment,       // 评论文本
} CLabelType;

@class CLabel;

@protocol CLabelDeletage <NSObject>

@optional

- (void)cLabelTouch:(CLabel *)cLabel;
- (void)cLabelLongTouch:(CLabel *)cLabel;

@end


@interface CLabel : UILabel


@property (weak, nonatomic) id<CLabelDeletage> delegate;
@property (copy, nonatomic) NSString *labelID;
@property (assign, nonatomic) BOOL isNickname;  // 点击的是否是昵称
@property (assign, nonatomic) CGPoint touchPoint;
@property (assign, nonatomic) CLabelType labelType; 


// 如果label中存在电话、网址等，那就返回存储它们的数组
@property (copy, nonatomic) CLableBlock cLabelBlock;


@end
