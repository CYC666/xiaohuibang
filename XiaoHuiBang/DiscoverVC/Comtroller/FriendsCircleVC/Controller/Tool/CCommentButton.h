//
//  CCommentButton.h
//  XiaoHuiBang
//
//  Created by mac on 16/12/9.
//  Copyright © 2016年 消汇邦. All rights reserved.
//


// 点击评论按钮获取所在的点的位置

#import <UIKit/UIKit.h>
@class CCommentButton;

@protocol CCommentButtonDelegate <NSObject>

- (void)cCommentButtonTouch:(CCommentButton *)button;

@end


@interface CCommentButton : UIButton

@property (assign, nonatomic) CGPoint locationPoint;    // 点击的位置
@property (weak, nonatomic) id<CCommentButtonDelegate> delegate;


@end
