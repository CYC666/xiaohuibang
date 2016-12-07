//
//  CScrollView.h
//  XiaoHuiBang
//
//  Created by mac on 16/12/6.
//  Copyright © 2016年 消汇邦. All rights reserved.
//

// 滑动查看大图

#import <UIKit/UIKit.h>

@interface CScrollView : UIScrollView

/*
 
 array  存储原图的url
 page   当前页
 
 
 */


- (instancetype)initWithFrame:(CGRect)frame imageArray:(NSArray *)array currentPage:(NSInteger)page;


@end
