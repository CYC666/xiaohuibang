//
//  PersonSeeModel.h
//  XiaoHuiBang
//
//  Created by mac on 16/11/22.
//  Copyright © 2016年 消汇邦. All rights reserved.
//


// 个人动态model


#import <Foundation/Foundation.h>

@interface PersonSeeModel : NSObject

@property (copy, nonatomic) NSString *about_id;     // 动态id
@property (copy, nonatomic) NSString *user_id;      // 用户id
@property (copy, nonatomic) NSString *content;      // 动态内容
@property (strong, nonatomic) NSMutableArray *about_img;    // 动态图片
@property (strong, nonatomic) NSMutableArray *thumb_img;    // 缩略图
@property (copy, nonatomic) NSString *create_time;  // 动态创建时间

/*
 
 "id": "41",
 "user_id": "9",
 "content": "再发一条动态试试\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n王慧今天直接不来\n\n\n\n\n\n\n\n\n很强",
 "about_img": "0",
 "create_time": "1479181196"
 
*/

@end
