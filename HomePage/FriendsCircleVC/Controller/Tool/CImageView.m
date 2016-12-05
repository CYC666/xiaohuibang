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

- (void)setImageNum:(NSInteger)imageNum {

    _imageNum = imageNum;
    
    // 添加数量显示
    UIView *tipView = [[UIView alloc] initWithFrame:CGRectMake(8, 8, 24, 24)];
    tipView.layer.cornerRadius = 12;
    tipView.backgroundColor = [UIColor colorWithRed:29/255.0 green:161/255.0 blue:243/255.0 alpha:1];
    [self addSubview:tipView];
    
    UILabel *numLabel = [[UILabel alloc] initWithFrame:CGRectMake(8, 14.5, 24, 11)];
    numLabel.textAlignment = NSTextAlignmentCenter;
    numLabel.text = [NSString stringWithFormat:@"%ld", imageNum];
    numLabel.textColor = [UIColor whiteColor];
    numLabel.font = [UIFont systemFontOfSize:14];
    [self addSubview:numLabel];

}




@end
