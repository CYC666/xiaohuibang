//
//  SeeModel.m
//  XiaoHuiBang
//
//  Created by mac on 16/11/14.
//  Copyright © 2016年 消汇邦. All rights reserved.
//






#import "SeeModel.h"

@implementation SeeModel

//消除关键字的错误提示
- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    
    if ([key isEqualToString:@"id"]) {
        _about_id = value;
    }
    
}

- (NSMutableArray *)about_img {

    if (_about_img == nil) {
        _about_img = [NSMutableArray array];
    }
    return _about_img;

}

- (NSMutableArray *)thumb_img {

    if (_thumb_img == nil) {
        _thumb_img = [NSMutableArray array];
    }
    return _thumb_img;

}

- (NSMutableArray *)praise {

    if (_praise == nil) {
        _praise = [NSMutableArray array];
    }
    return _praise;

}

- (NSMutableArray *)aveluate {

    if (_aveluate == nil) {
        _aveluate = [NSMutableArray array];
    }
    return _aveluate;

}



@end
