//
//  CScrollImage.h
//  XiaoHuiBang
//
//  Created by mac on 16/12/9.
//  Copyright © 2016年 消汇邦. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CScrollImage : UIView

@property (assign, nonatomic) BOOL allowHide;   // 提供一个标志，外界可根据标志判断是否允许单击，以不影响双击

- (instancetype)initWithFrame:(CGRect)frame imageArray:(NSArray *)array currentPage:(NSInteger)page;

@end
