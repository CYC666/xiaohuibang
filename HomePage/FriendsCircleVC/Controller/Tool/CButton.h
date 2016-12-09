//
//  CButton.h
//  XiaoHuiBang
//
//  Created by mac on 16/11/24.
//  Copyright © 2016年 消汇邦. All rights reserved.
//

// 点击评论列表的名称button跳转到对应id的个人动态界面，这个类主要是传递id


#import <UIKit/UIKit.h>


@interface CButton : UIButton


@property (copy, nonatomic) NSString *user_id;  // 点击按钮传递的用户id



@end
