//
//  CWebPlayerLayer.h
//  XiaoHuiBang
//
//  Created by mac on 16/12/29.
//  Copyright © 2016年 消汇邦. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CWebPlayerLayer : UIView

@property (strong, nonatomic) NSString *movieUrlStr;
@property (assign, nonatomic) BOOL isCycle;             // 是否循环播放

- (instancetype)initWithFrame:(CGRect)frame withUrl:(NSString *)urlStr;

@end
