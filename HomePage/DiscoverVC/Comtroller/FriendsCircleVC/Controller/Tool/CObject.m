//
//  CObject.m
//  XiaoHuiBang
//
//  Created by mac on 16/12/15.
//  Copyright © 2016年 消汇邦. All rights reserved.
//

#import "CObject.h"

@implementation CObject





- (void)encodeWithCoder:(NSCoder *)aCoder {

    [aCoder encodeObject:self.seeArray forKey:@"seeArray"];

}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {

    self = [super init];
    if (self != nil) {
        self.seeArray = [aDecoder decodeObjectForKey:@"seeArray"];
    }
    return self;

}



@end
