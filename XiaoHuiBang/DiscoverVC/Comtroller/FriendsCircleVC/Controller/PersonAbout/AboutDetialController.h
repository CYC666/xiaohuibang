//
//  AboutDetialController.h
//  XiaoHuiBang
//
//  Created by mac on 16/11/30.
//  Copyright © 2016年 消汇邦. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AboutDetialLayout.h"

@interface AboutDetialController : UIViewController

@property (strong, nonatomic) AboutDetialLayout *detialLayout;

- (instancetype)initWithUserID:(NSString *)userID
                       aboutID:(NSString *)aboutID;


@end
