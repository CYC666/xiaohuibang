//
//  CPlayerLayer.h
//  XiaoHuiBang
//
//  Created by mac on 16/12/23.
//  Copyright © 2016年 消汇邦. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>


@interface CPlayerLayer : UIView

@property (strong, nonatomic) AVPlayer *player;
@property (copy, nonatomic) void(^touchPlayer)();       // 点击事件

@end
