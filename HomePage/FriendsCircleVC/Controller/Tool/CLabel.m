//
//  CLabel.m
//  LabelDelegate
//
//  Created by mac on 16/12/3.
//  Copyright © 2016年 CYC. All rights reserved.
//

#import "CLabel.h"

@interface CLabel ()

@property (strong, nonatomic) UIColor *cColor;  // 记录初始颜色,以便触摸结束后还能显示原始颜色

@end

@implementation CLabel

- (instancetype)initWithFrame:(CGRect)frame {

    self = [super initWithFrame:frame];
    if (self != nil) {
        // 打开交互
        self.userInteractionEnabled = YES;
    }
    return self;

}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {

    // 如果是富文本，那就不要设定颜色了，不然颜色会改变
    if (self.attributedText == nil) {
        self.cColor = self.textColor;
        self.textColor = [UIColor lightGrayColor];
    }
    
    // 改变底色
    self.backgroundColor = [UIColor colorWithWhite:0 alpha:.1];
    

}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    // 执行代理方法,传递数据
    [_delegate cLabelTouch:self];

    // 如果是富文本，那就不要设定颜色了，不然颜色会改变
    if (self.attributedText == nil) {
        self.textColor = _cColor;
    }
    
    self.backgroundColor = [UIColor clearColor];
    

}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event {

    self.backgroundColor = [UIColor clearColor];
    
}


#pragma mark - 懒加载
- (UIColor *)cColor {

    if (_cColor == nil) {
        _cColor = [UIColor clearColor];
    }
    return _cColor;

}

@end
