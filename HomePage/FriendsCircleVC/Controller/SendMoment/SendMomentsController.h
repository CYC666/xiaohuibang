//
//  SendMomentsController.h
//  XiaoHuiBang
//
//  Created by mac on 16/11/8.
//  Copyright © 2016年 消汇邦. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SendMomentsController : UIViewController
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;  // 背景滑动视图
@property (weak, nonatomic) IBOutlet UIView *backgroundView;    // 背景父视图
@property (strong, nonatomic) UIImageView *willPushImageView;   // 显示即将上传的image
@property (strong, nonatomic) UIImage *willPushPhoto;                   // 储存选中的image
// 传入一张图片以初始化
- (instancetype)initWithImage:(UIImage *)image;

@end
