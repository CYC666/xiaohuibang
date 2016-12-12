//
//  PersonSeeCell.h
//  XiaoHuiBang
//
//  Created by mac on 16/11/22.
//  Copyright © 2016年 消汇邦. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "PersonSeeLayout.h"

@interface PersonSeeCell : UITableViewCell

@property (strong, nonatomic) PersonSeeLayout *personSeeModelLayout;    // 数据
@property (strong, nonatomic) UILabel *timeLabel;                       // 时间文本
@property (strong, nonatomic) UIImageView *aboutImageView;              // 动态图片的视图
@property (strong, nonatomic) UIView *backgroundColor;                  // 文本的背景颜色框
@property (strong, nonatomic) UILabel *contentLabel;                    // 动态文本
@property (strong, nonatomic) UITextView *contentText;                  // 动态文本
@property (assign, nonatomic) BOOL hideBackgroundColor;                 // 是否隐藏底色


@end
