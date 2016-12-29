//
//  CMovieImageView.h
//  XiaoHuiBang
//
//  Created by mac on 16/12/29.
//  Copyright © 2016年 消汇邦. All rights reserved.
//

// 用于显示动态中视频缩略图


#import <UIKit/UIKit.h>

@protocol CMovieImageViewDelegate <NSObject>

@optional

// 点击结束
- (void)touchMovieImageViewEnd;

@end


@interface CMovieImageView : UIImageView

@property (weak, nonatomic) id<CMovieImageViewDelegate> delegate;



@end
