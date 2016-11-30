//
//  AboutWithImageController.h
//  XiaoHuiBang
//
//  Created by mac on 16/11/29.
//  Copyright © 2016年 消汇邦. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PersonSeeModel.h"
#import "SeeModel.h"
@interface AboutWithImageController : UIViewController

@property (strong, nonatomic) SeeModel *seeModel;
@property (strong, nonatomic) UIImageView *aboutImageView;


- (instancetype)initWithUserID:(NSString *)userID
                       aboutID:(NSString *)aboutID;

@end
