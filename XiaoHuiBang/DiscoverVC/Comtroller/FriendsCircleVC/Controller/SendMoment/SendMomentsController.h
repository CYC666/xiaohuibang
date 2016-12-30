//
//  SendMomentsController.h
//  XiaoHuiBang
//
//  Created by mac on 16/11/8.
//  Copyright © 2016年 消汇邦. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    CYC_TEXT,
    CYC_IMAGE,
    CYC_MOVIE,
} SendType;

@interface SendMomentsController : UIViewController
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;          // 背景滑动视图
@property (weak, nonatomic) IBOutlet UIView *backgroundView;            // 背景父视图

@property (copy, nonatomic) NSString *locationStr;                      // 储存了地理信息的字符串

// 地址
@property (copy, nonatomic) NSString *address;
@property (copy, nonatomic) NSString *lat;
@property (copy, nonatomic) NSString *lon;


// 只发送文字
- (instancetype)initWithText;

// 带图片
- (instancetype)initWithImageArray:(NSArray *)imageArray;

// 带视频
- (instancetype)initWithMovie:(NSURL *)movieUrl;

@end



/*
 
 @property (strong, nonatomic) NSMutableArray *willPushPhotoArr;         // 储存选中的image
 
 */
