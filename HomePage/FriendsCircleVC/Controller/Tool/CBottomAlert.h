//
//  CBottomAlert.h
//  XiaoHuiBang
//
//  Created by mac on 16/12/21.
//  Copyright © 2016年 消汇邦. All rights reserved.
//

// 在底部弹出的提示框

#import <UIKit/UIKit.h>

typedef void(^CBottomAlertBlock)(NSString *);


@interface CBottomAlert : UIView

@property (copy, nonatomic) CBottomAlertBlock block;// 按钮回调

- (instancetype)initWtihTitleArray:(NSArray *)titleArray;

- (void)show;
- (void)dismiss;



@end
