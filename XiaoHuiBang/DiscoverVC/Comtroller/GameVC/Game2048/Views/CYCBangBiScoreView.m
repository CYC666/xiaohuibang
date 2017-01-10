//
//  CYCBangBiScoreView.m
//  XiaoHuiBang
//
//  Created by mac on 2017/1/10.
//  Copyright © 2017年 消汇邦. All rights reserved.
//

#import "CYCBangBiScoreView.h"



@interface CYCBangBiScoreView ()
@property (nonatomic, strong) UILabel *scoreLabel;
@end



@implementation CYCBangBiScoreView



+ (instancetype)bangBiScoreViewWithCornerRadius:(CGFloat)radius
                                backgroundColor:(UIColor *)color
                                      textColor:(UIColor *)textColor
                                       textFont:(UIFont *)textFont
                                          frame:(CGRect)frame{
    CYCBangBiScoreView *view = [[[self class] alloc] initWithFrame:frame];
    view.score = 0;
    view.layer.cornerRadius = radius;
    view.backgroundColor = color ?: [UIColor whiteColor];
    view.userInteractionEnabled = YES;
    if (textColor) {
        view.scoreLabel.textColor = textColor;
    }
    if (textFont) {
        view.scoreLabel.font = textFont;
    }
    return view;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (!self) return nil;
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 110, 115)];
    imageView.image = [UIImage imageNamed:@"icon_bangbi_score"];
    [self addSubview:imageView];
    UILabel *scoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 55, 110, 60)];
    scoreLabel.textAlignment = NSTextAlignmentCenter;
    scoreLabel.adjustsFontSizeToFitWidth = YES;
    scoreLabel.textColor = [UIColor whiteColor];
    [self addSubview:scoreLabel];
    self.scoreLabel = scoreLabel;
    return self;
}

- (void)setScore:(NSInteger)score {
    _score = score;
    self.scoreLabel.text = [NSString stringWithFormat:@"%ld", (long)score];
}









































@end
