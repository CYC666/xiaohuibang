//
//  LocationSearchBar.h
//  XiaoHuiBang
//
//  Created by mac on 16/12/26.
//  Copyright © 2016年 消汇邦. All rights reserved.
//


// 输入框
// 发布动态 -- 地址 -- 输入框


#import <UIKit/UIKit.h>

@interface LocationSearchBar : UIView

@property (copy, nonatomic) void(^searchBarEditBeginBlock)();   // 开始编辑
@property (copy, nonatomic) void(^searchBarCancelBlock)();      // 取消按钮
@property (copy, nonatomic) void(^searchBarReturnBlock)();      // return按下

- (instancetype)initWithFrame:(CGRect)frame;

- (void)cancelAction;


@end
