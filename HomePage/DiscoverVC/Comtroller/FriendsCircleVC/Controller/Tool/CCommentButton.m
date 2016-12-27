//
//  CCommentButton.m
//  XiaoHuiBang
//
//  Created by mac on 16/12/9.
//  Copyright © 2016年 消汇邦. All rights reserved.
//

#import "CCommentButton.h"

@implementation CCommentButton

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    // 获取所在位置
    UITouch *touch = touches.anyObject;
    _locationPoint = [touch locationInView:[UIApplication sharedApplication].keyWindow];
    
    [_delegate cCommentButtonTouch:self];
    
    
}

@end
