//
//  CWebPlayerLayer.h
//  XiaoHuiBang
//
//  Created by mac on 16/12/29.
//  Copyright © 2016年 消汇邦. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CWebPlayerLayer : UIView

@property (strong, nonatomic) NSURL *movieUrl;

- (instancetype)initWithFrame:(CGRect)frame withUrl:(NSURL *)url;

@end
