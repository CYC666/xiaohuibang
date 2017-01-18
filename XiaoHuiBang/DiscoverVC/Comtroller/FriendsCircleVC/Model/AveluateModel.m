//
//  AveluateModel.m
//  XiaoHuiBang
//
//  Created by mac on 16/11/14.
//  Copyright © 2016年 消汇邦. All rights reserved.
//

#import "AveluateModel.h"

@implementation AveluateModel

//消除关键字的错误提示
- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    
    if ([key isEqualToString:@"id"]) {
        _aveluate_id = value;
    }
    
}


@end
