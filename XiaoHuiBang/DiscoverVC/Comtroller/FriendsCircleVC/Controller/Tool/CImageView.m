//
//  CImageView.m
//  XiaoHuiBang
//
//  Created by mac on 16/12/3.
//  Copyright © 2016年 消汇邦. All rights reserved.
//

#import "CImageView.h"

@interface CImageView ()

@property (strong, nonatomic) NSTimer *timer;
@property (assign, nonatomic) float touchTime;

@end

@implementation CImageView


- (instancetype)initWithFrame:(CGRect)frame {

    self = [super initWithFrame:frame];
    if (self != nil) {
        // 打开交互
        self.userInteractionEnabled = YES;
    }
    return self;

}


// 点击开始
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {

    _timer = [NSTimer scheduledTimerWithTimeInterval:.1 repeats:YES block:^(NSTimer * _Nonnull timer) {
        _touchTime += 0.1;
    }];

}

// 触摸离开后调用代理方法
-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    // 当触摸时长超过1秒，那就执行长按
    if (_touchTime > 1) {
        if ([_delegate respondsToSelector:@selector(cImageViewLongTouch:)]) {
            [_delegate cImageViewLongTouch:self];
        }
        [_timer invalidate];
    } else if (_touchTime < 1) {
        if ([_delegate respondsToSelector:@selector(cImageViewTouch:)]) {
            [_delegate cImageViewTouch:self];
        }
    }
    
    if (_timer.valid) {
        [_timer invalidate];
        _timer = nil;
    }
    // 结束后要将触摸时间归零，不然下次触摸太短，会记住上一次的触摸时间，倒是点击不能用
    _touchTime = 0;
    

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
