//
//  CBottomAlert.m
//  XiaoHuiBang
//
//  Created by mac on 16/12/21.
//  Copyright © 2016年 消汇邦. All rights reserved.
//

#import "CBottomAlert.h"

#define CWIDTH [UIScreen mainScreen].bounds.size.width
#define CHEIGHT [UIScreen mainScreen].bounds.size.height
#define CBUTTONHEIGHT 40
#define CSPACE 5


@interface CBottomAlert ()

@property (strong, nonatomic) NSArray *titleArray;
@property (strong, nonatomic) UIButton *backgroundButton;
@property (strong, nonatomic) UIView *bottomView;

@end

@implementation CBottomAlert

- (instancetype)initWtihTitleArray:(NSArray *)titleArray {
    
    if (self = [super init]) {
        self.frame = [UIScreen mainScreen].bounds;
        self.titleArray = titleArray;
        // 创建子视图
        [self _creatSubviews];
        
    }
    return self;
    
}

#pragma mark - 创建子视图
- (void)_creatSubviews {
    
    _backgroundButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _backgroundButton.frame = [UIScreen mainScreen].bounds;
    [_backgroundButton addTarget:self
                          action:@selector(cancelAction:)
                forControlEvents:UIControlEventTouchUpInside];
    _backgroundButton.backgroundColor = [UIColor colorWithWhite:0 alpha:.2];
    _backgroundButton.alpha = 0;
    [self addSubview:_backgroundButton];
    
    _bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, CHEIGHT, CWIDTH, (CBUTTONHEIGHT+0.5)*(_titleArray.count+1)+CSPACE)];
    _bottomView.backgroundColor = [UIColor colorWithRed:229/255.0 green:229/255.0 blue:229/255.0 alpha:1];
    [self addSubview:_bottomView];
    
    for (NSInteger i = 0; i < (_titleArray.count + 1); i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setBackgroundColor:[UIColor whiteColor]];
        [button setBackgroundImage:[self createImageWithColor:[UIColor colorWithRed:221/255.0 green:221/255.0 blue:221/255.0 alpha:1]] forState:UIControlStateHighlighted];
        [button setTitleColor:[UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1]
                     forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize:17];
        if (i != _titleArray.count) {
            button.frame = CGRectMake(0, 0.5+(CBUTTONHEIGHT+0.5)*i, CWIDTH, CBUTTONHEIGHT);
            [button setTitle:_titleArray[i] forState:UIControlStateNormal];
        } else {
            button.frame = CGRectMake(0, ((CBUTTONHEIGHT+0.5)*(_titleArray.count+1)+CSPACE)-(CBUTTONHEIGHT+0.5),
                                      CWIDTH, CBUTTONHEIGHT);
            [button setTitle:@"取消" forState:UIControlStateNormal];
            [button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        }
        [button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
        [_bottomView addSubview:button];
        
    }
    
}

#pragma mark - 展示
- (void)show {
    
    [[UIApplication sharedApplication].keyWindow addSubview:self];
    
    __block float bottomHeight = CBUTTONHEIGHT*(_titleArray.count+1)+CSPACE;
    [UIView animateWithDuration:.35
                     animations:^{
                         _backgroundButton.alpha = 1;
                         _bottomView.transform = CGAffineTransformMakeTranslation(0, -bottomHeight);
                     }];
    
}
- (void)dismiss {
    
    [UIView animateWithDuration:.35
                     animations:^{
                         _backgroundButton.alpha = 0;
                         _bottomView.transform = CGAffineTransformMakeTranslation(0, 0);
                         
                     } completion:^(BOOL finished) {
                         [self removeFromSuperview];
                     }];
    
}

#pragma mark - 点击背景退出
- (void)cancelAction:(UIButton *)button {
    
    [UIView animateWithDuration:.35
                     animations:^{
                         _backgroundButton.alpha = 0;
                         _bottomView.transform = CGAffineTransformMakeTranslation(0, 0);
                         
                     } completion:^(BOOL finished) {
                         [self removeFromSuperview];
                     }];
    
    
}

#pragma mark - 按钮点击响应
- (void)buttonAction:(UIButton *)button {
    
    [self dismiss];
    
    __block NSString *title = button.titleLabel.text;
    self.block(title);
    
}


#pragma mark - 颜色转换成image
-(UIImage *)createImageWithColor:(UIColor*) color {
    CGRect rect=CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}





























@end
