//
//  AboutWithImageController.h
//  XiaoHuiBang
//
//  Created by mac on 16/11/29.
//  Copyright © 2016年 消汇邦. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PersonSeeModel.h"

@interface AboutWithImageController : UIViewController

@property (strong, nonatomic) PersonSeeModel *personModel;
@property (strong, nonatomic) UIImageView *aboutImageView;  

- (instancetype)initWithPersonModel:(PersonSeeModel *)model;


@end
