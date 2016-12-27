//
//  PersonSeeLayout.h
//  XiaoHuiBang
//
//  Created by mac on 16/11/22.
//  Copyright © 2016年 消汇邦. All rights reserved.
//


// 个人动态布局模型

#import <Foundation/Foundation.h>
#import "PersonSeeModel.h"

@interface PersonSeeLayout : NSObject

@property (strong, nonatomic) PersonSeeModel *personSeeModel;   // 个人动态model
@property (assign, nonatomic) float cellHeight;                 // 单元格高度
@property (assign, nonatomic) CGRect timeLabelFrame;            // 时间框frame
@property (assign, nonatomic) CGRect aboutImageFrame;           // 动态图片frame
@property (strong, nonatomic) NSMutableArray *imageFrameArr;    // 动态图片的frame数组
@property (assign, nonatomic) CGRect contentFrame;              // 动态文本frame
@property (assign, nonatomic) CGRect backgroundColorFrame;      // 文本背后的颜色区frame

@property (copy, nonatomic) NSMutableAttributedString *timeText;// 转换之后的时间，月日
@property (copy, nonatomic) NSString *timeTextYear;             // 转换之后的时间，年份
@property (assign, nonatomic) BOOL isFirst;                     // 标识是不是新日期的第一个动态


@end
