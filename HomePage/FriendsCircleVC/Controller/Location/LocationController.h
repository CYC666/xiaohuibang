//
//  LocationController.h
//  XiaoHuiBang
//
//  Created by mac on 16/12/19.
//  Copyright © 2016年 消汇邦. All rights reserved.
//

// 根据字符串获取位置并显示在地图上
// 字符串：  地名+纬度+经度


#import <UIKit/UIKit.h>

@interface LocationController : UIViewController


- (instancetype)initWithLocationString:(NSString *)string;


@end
