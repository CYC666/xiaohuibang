//
//  CLabel.m
//  LabelDelegate
//
//  Created by mac on 16/12/3.
//  Copyright © 2016年 CYC. All rights reserved.
//

#import "CLabel.h"

#import "RegexKitLite.h"

@interface CLabel ()

@property (strong, nonatomic) UIColor *cColor;  // 记录初始颜色,以便触摸结束后还能显示原始颜色
@property (strong, nonatomic) NSTimer *timer;
@property (assign, nonatomic) float touchTime;

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

    _timer = [NSTimer scheduledTimerWithTimeInterval:.1
                                             repeats:YES
                                               block:^(NSTimer * _Nonnull timer) {
                                                   _touchTime += 0.1;
                                                   if (_touchTime > 1) {
                                                       // 长按了
                                                       if ([_delegate respondsToSelector:@selector(cLabelLongTouch:)]) {
                                                           [_delegate cLabelLongTouch:self];
                                                       }
                                                       [_timer invalidate];
                                                       _touchTime = 0;
                                                   }
                                               }];
    
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
    
    // 查询是否存在电话、网址,如果有，那就执行block，并返回存住这些电话、网址的数组
    NSMutableArray *resultArr = [NSMutableArray array];
    NSString *MOBILEA = @"1\\d\\d\\d\\d\\d\\d\\d\\d\\d\\d";
    [resultArr addObjectsFromArray:[self.text componentsMatchedByRegex:MOBILEA]];
    NSString *MOBILEB = @"\\d{3}-\\d{8}|\\d{4}-\\d{7}";
    [resultArr addObjectsFromArray:[self.text componentsMatchedByRegex:MOBILEB]];
    NSString *http = @"(http|ftp|https)://[\\w\\-_]+(\\.[\\w\\-_]+)+([\\w\\-\\.,@?^=%&amp;:/~\\+#]*[\\w\\-\\@?^=%&amp;/~\\+#])?";
    [resultArr addObjectsFromArray:[self.text componentsMatchedByRegex:http]];
    // 根据字典的唯一性，去除数组重复元素
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    for (NSString *str in resultArr) {
        [dic setObject:str forKey:str];
    }
    __block NSArray *newArr = [dic allValues];
    if (newArr.count != 0) {
        _cLabelBlock(newArr);
    }

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
