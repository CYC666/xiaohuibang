//
//  CSwitchButtom.m
//  CSwitchButton
//
//  Created by mac on 16/12/21.
//  Copyright © 2016年 CYC. All rights reserved.
//

#import "CSwitchButton.h"
#import "BottomLayer.h"
#import "TopLayer.h"

@interface CSwitchButton () {
    
    NSTimer *_timer;
    BOOL _isMovie;
    float _endAngle;
    
    BottomLayer *_bottomLayer;  // 底部
    TopLayer *_topLayer;     // 顶部
    
}

@property (strong, nonatomic) UILabel *timeCount;   // 记录录像时间

@end

@implementation CSwitchButton

- (instancetype)initWithFrame:(CGRect)frame {

    self = [super initWithFrame:frame];
    if (self != nil) {
        self.backgroundColor = [UIColor colorWithRed:207/255.0 green:206/255.0 blue:200/255.0 alpha:.8];
        self.layer.cornerRadius = self.frame.size.height/2.0;
        _bottomLayer = [[BottomLayer alloc] initWithFrame:self.bounds];
        [self addSubview:_bottomLayer];
        _topLayer = [[TopLayer alloc] initWithFrame:self.bounds];
        _topLayer.transform = CGAffineTransformMakeScale(0.75, 0.75);
        [self addSubview:_topLayer];
        
    }
    return self;

}

- (UILabel *)timeCount {

    if (_timeCount == nil) {
        _timeCount = [[UILabel alloc] initWithFrame:CGRectMake((self.frame.size.height - 25)/2.0, (self.frame.size.height - 25)/2.0, 25, 25)];
        _timeCount.font = [UIFont systemFontOfSize:12];
        _timeCount.textAlignment = NSTextAlignmentCenter;
        _timeCount.textColor = [UIColor colorWithRed:29/255.0 green:161/255.0 blue:243/255.0 alpha:1];
        [self addSubview:_timeCount];
    }
    return _timeCount;

}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    _touchTime = 0;
    _timer = [NSTimer scheduledTimerWithTimeInterval:.02
                                             repeats:YES
                                               block:^(NSTimer * _Nonnull timer) {
                                                   _touchTime += 0.02;
                                                   
                                                   // 正在摄像
                                                   if (_touchTime > 0.5) {
                                                       _startMovieBlock();
                                                       
                                                       // 录制时间,如果放在缩放下面设置的话，会有位移偏差
                                                       self.timeCount.text = [NSString stringWithFormat:@"%ld", (NSInteger)(_touchTime/1)];
                                                       
                                                       [UIView animateWithDuration:.35
                                                                        animations:^{
                                                                            self.transform = CGAffineTransformMakeScale(1.3, 1.3);
                                                                            _topLayer.transform = CGAffineTransformMakeScale(0.3, 0.3);
                                                                        }];
                                                       // 进度条
                                                       _bottomLayer.endAngle = M_PI * 2 * ((_touchTime - 0.5)/60);
                                                       
                                                   }
                                                   
                                                   if (_touchTime > 60.5) {
                                                       // 结束
                                                       [_timer invalidate];
                                                       [self touchesEnded:touches withEvent:event];
                                                   }
                                               }];
    
    
}


- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {

    // 让顶部layer跟随手指移动
//    UITouch *touch = [touches anyObject];
//    CGPoint point = [touch locationInView:self];
//    _topLayer.center = point;

}


- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    _timeCount.text = @"";
    
    if (_touchTime < 0.5) {
        // 触发拍照
        _pictureBlock();
    } else {
        // 结束摄像
        __block float time = _touchTime;
        _endMovieBlock(time);
    }
    
    [_timer invalidate];
    _timer = nil;
    
    _bottomLayer.endAngle = 0;
    
    [UIView animateWithDuration:.35
                     animations:^{
                         self.transform = CGAffineTransformIdentity;
                         _topLayer.transform = CGAffineTransformMakeScale(0.8, 0.8);
                         _topLayer.center = CGPointMake(self.bounds.size.height/2.0, self.bounds.size.height/2.0);
                     }];
    
}





@end
