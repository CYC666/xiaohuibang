//
//  InputView.m
//  XiaoHuiBang
//
//  Created by mac on 16/11/21.
//  Copyright © 2016年 消汇邦. All rights reserved.
//

#import "InputView.h"
#define kScreenHeight [UIScreen mainScreen].bounds.size.height  // 屏高
#define kScreenWidth [UIScreen mainScreen].bounds.size.width    // 屏宽
#define kHeight 53  // 输入框默认高度
#define ScrollTableView @"ScrollTableView"  // 接收调节表视图偏移的通知


@interface InputView () 

@end

@implementation InputView

// 使用xib加载的视图，应该调用此方法
- (instancetype)initWithCoder:(NSCoder *)aDecoder {

    self = [super initWithCoder:aDecoder];
    if (self != nil) {
        
        // 显示键盘
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(showKeyBoard:)
                                                     name:UIKeyboardWillShowNotification
                                                   object:nil];
        // 隐藏键盘
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(hideKeyBoard:)
                                                     name:UIKeyboardWillHideNotification
                                                   object:nil];
        self.layer.borderColor = [UIColor colorWithRed:216/255.0
                                                 green:216/255.0
                                                  blue:216/255.0 alpha:1].CGColor;
        self.layer.borderWidth = 0.5;       
        
        
    }
    return self;

}





#pragma mark - 表情按钮
- (IBAction)emoj:(UIButton *)sender {
    
    
    
}

#pragma mark - 弹出键盘
- (void)showKeyBoard:(NSNotification *)notification {

    NSDictionary *userInfo = [notification userInfo];
    NSValue *value = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGFloat keyBoardHeight = value.CGRectValue.size.height;
    
    // 调节输入框高度
    self.transform = CGAffineTransformMakeTranslation(0, -(keyBoardHeight + kHeight));

    // 发送通知调节滑动视图
    // 设置表视图的偏移(提供输入框的Y起点即可)
    [[NSNotificationCenter defaultCenter] postNotificationName:ScrollTableView
                                                        object:@{@"y":[NSString stringWithFormat:@"%f", kScreenHeight - (keyBoardHeight + kHeight)],
                                                                 @"indexpathRow":[NSString stringWithFormat:@"%ld", _cellRow]}];
}

#pragma mark - 隐藏键盘
- (void)hideKeyBoard:(NSNotification *)notification {

    self.transform = CGAffineTransformIdentity;
    [self removeFromSuperview];     // 必须移除，不然会有内存泄露

}

// 移除通知
- (void)dealloc {

    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];

}







































@end
