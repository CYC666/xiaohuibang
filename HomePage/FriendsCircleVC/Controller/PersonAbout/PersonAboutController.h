//
//  PersonAboutController.h
//  XiaoHuiBang
//
//  Created by mac on 16/11/22.
//  Copyright © 2016年 消汇邦. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface PersonAboutController : UIViewController

@property (copy, nonatomic) NSString *user_id;  // 用户id
@property (copy, nonatomic) NSString *headImageUrl;    // 用户头像str
@property (copy, nonatomic) NSString *nickname; // 用户昵称


// 传入对象的id，即可查看他的动态
- (instancetype)initWithUserID:(NSString *)user_id;

@end
