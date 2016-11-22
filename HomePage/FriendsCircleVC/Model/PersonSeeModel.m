//
//  PersonSeeModel.m
//  XiaoHuiBang
//
//  Created by mac on 16/11/22.
//  Copyright © 2016年 消汇邦. All rights reserved.
//

// 个人动态model

#import "PersonSeeModel.h"

@implementation PersonSeeModel


//消除关键字的错误提示
- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    
    if ([key isEqualToString:@"id"]) {
        _about_id = value;
    }
    
}


@end
