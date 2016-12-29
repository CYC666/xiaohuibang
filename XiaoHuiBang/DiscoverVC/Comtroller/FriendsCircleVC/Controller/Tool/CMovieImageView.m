//
//  CMovieImageView.m
//  XiaoHuiBang
//
//  Created by mac on 16/12/29.
//  Copyright © 2016年 消汇邦. All rights reserved.
//

#import "CMovieImageView.h"

@interface CMovieImageView () {

    UIImageView *_imageView;

}

@end

@implementation CMovieImageView


- (instancetype)initWithFrame:(CGRect)frame {

    if (self = [super initWithFrame:frame]) {
        
        self.contentMode = UIViewContentModeScaleAspectFit;
        self.userInteractionEnabled = YES;
        // 播放按钮
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake((self.bounds.size.width - 40)/2.0, (self.bounds.size.height - 40)/2.0, 40, 40)];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        _imageView.image = [UIImage imageNamed:@"icon_play"];
        [self addSubview:_imageView];
        
    }
    return self;

}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    _imageView.alpha = 0.5;
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {

    _imageView.alpha = 1;
    if ([_delegate respondsToSelector:@selector(touchMovieImageViewEnd)]) {
        [_delegate touchMovieImageViewEnd];
    }

}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    _imageView.alpha = 1;
}



@end
