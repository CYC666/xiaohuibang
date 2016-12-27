//
//  InputView.h
//  XiaoHuiBang
//
//  Created by mac on 16/11/21.
//  Copyright © 2016年 消汇邦. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InputView : UIView


@property (weak, nonatomic) IBOutlet UITextView *input; // 输入框
@property (assign, nonatomic) NSInteger cellRow;        // 单元格的位置row
@property (assign, nonatomic) BOOL isEmoj;              // 是否打开表情输入


@end
