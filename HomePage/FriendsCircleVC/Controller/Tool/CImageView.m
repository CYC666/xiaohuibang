//
//  CImageView.m
//  XiaoHuiBang
//
//  Created by mac on 16/12/3.
//  Copyright © 2016年 消汇邦. All rights reserved.
//

#import "CImageView.h"

@implementation CImageView


- (instancetype)initWithFrame:(CGRect)frame {

    self = [super initWithFrame:frame];
    if (self != nil) {
        // 打开交互
        self.userInteractionEnabled = YES;
    }
    return self;

}

// 触摸离开后调用代理方法
-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {

    [_delegate cImageViewTouch:self];

}




@end
