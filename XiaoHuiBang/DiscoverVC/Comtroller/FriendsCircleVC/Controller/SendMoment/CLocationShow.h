//
//  CLocationShow.h
//  XiaoHuiBang
//
//  Created by mac on 16/12/19.
//  Copyright © 2016年 消汇邦. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CLocationShow : UIViewController


// 返回的block，传递数据
@property (copy, nonatomic) void(^locationBlock)();


@end
