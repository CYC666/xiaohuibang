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

@property (weak, nonatomic) id<CImageViewDelegate> delegate;
@property (copy, nonatomic) NSString *imageID;


@end
