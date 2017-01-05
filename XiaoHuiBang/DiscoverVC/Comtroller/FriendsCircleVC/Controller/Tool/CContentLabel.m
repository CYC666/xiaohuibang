//
//  CContentLabel.m
//  XiaoHuiBang
//
//  Created by mac on 2017/1/5.
//  Copyright © 2017年 消汇邦. All rights reserved.
//

#import "CContentLabel.h"
#import "RegexKitLite.h"

@interface CContentLabel ()

@property (strong, nonatomic) UIColor *cColor;  // 记录初始颜色,以便触摸结束后还能显示原始颜色
@property (strong, nonatomic) NSTimer *timer;
@property (assign, nonatomic) float touchTime;


@end

@implementation CContentLabel


- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self != nil) {
        // 打开交互
        self.userInteractionEnabled = YES;
    }
    return self;
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    __weak typeof(self) weakSelf = self;
    _timer = [NSTimer scheduledTimerWithTimeInterval:.1
                                             repeats:YES
                                               block:^(NSTimer * _Nonnull timer) {
                                                   weakSelf.touchTime += 0.1;
                                                   if (weakSelf.touchTime > 1) {
                                                       [weakSelf.timer invalidate];
                                                   }
                                               }];
    // 改变底色
    self.backgroundColor = [UIColor colorWithWhite:0 alpha:.1];
    
    
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    if (_touchTime < 1) {
        // 执行点击代理方法
        [_delegate cContentLabelTouch:self];
    } else {
        // 执行长按代理方法
        [_delegate cContentLabelLongTouch:self];
    }
    
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
        // _cLabelBlock(newArr);
    }
    
    
    self.backgroundColor = [UIColor clearColor];
    
    
}




































@end
