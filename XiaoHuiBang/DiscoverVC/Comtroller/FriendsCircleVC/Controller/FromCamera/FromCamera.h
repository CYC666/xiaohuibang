//
//  FromCamera.h
//  XiaoHuiBang
//
//  Created by mac on 16/12/14.
//  Copyright © 2016年 消汇邦. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, CameraType) {
    Picture         = 0,
    Movie           = 1,
};


@interface FromCamera : UIImagePickerController

- (instancetype)initWithType:(CameraType)type;

@end
