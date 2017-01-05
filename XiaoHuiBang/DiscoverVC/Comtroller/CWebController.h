//
//  CWebController.h
//  XiaoHuiBang
//
//  Created by mac on 2017/1/4.
//  Copyright © 2017年 消汇邦. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CWebController : UIViewController

@property (assign, nonatomic) BOOL allowGesture;    // 是否加载左滑右滑手势
@property (assign, nonatomic) BOOL allowRightItem;  // 是否加载导航栏右边的主页按钮
@property (assign, nonatomic) BOOL isModel;         // 是否是模态进入


- (instancetype)initWithName:(NSString *)controllerName
                         url:(NSString *)controllerUrl;

- (instancetype)initWithModelName:(NSString *)controllerName
                              url:(NSString *)controllerUrl;


@end
