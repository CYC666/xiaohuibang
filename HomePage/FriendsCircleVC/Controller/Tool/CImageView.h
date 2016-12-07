//
//  CImageView.h
//  XiaoHuiBang
//
//  Created by mac on 16/12/3.
//  Copyright © 2016年 消汇邦. All rights reserved.
//

// 代理方法在点击UI后会自动调用


#import <UIKit/UIKit.h>
@class CImageView;


@protocol CImageViewDelegate <NSObject>

- (void)cImageViewTouch:(CImageView *)cImageView;

@end





@interface CImageView : UIImageView

// 点击头像跳转界面
@property (weak, nonatomic) id<CImageViewDelegate> delegate;
@property (copy, nonatomic) NSString *imageID;

// 发表多图动态界面
@property (assign, nonatomic) NSInteger imageNum;   // 图片量

// 滑动视图点击的页数
@property (assign, nonatomic) NSInteger imagePage;  // 当前页数


@end
