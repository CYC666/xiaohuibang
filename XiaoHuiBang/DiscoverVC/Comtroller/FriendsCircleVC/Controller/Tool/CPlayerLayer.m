//
//  CPlayerLayer.m
//  XiaoHuiBang
//
//  Created by mac on 16/12/23.
//  Copyright © 2016年 消汇邦. All rights reserved.
//

#import "CPlayerLayer.h"

@interface CPlayerLayer ()

// @property (assign, nonatomic) float touchTime;

@end

@implementation CPlayerLayer


+ (Class)layerClass {
    return [AVPlayerLayer class];
}

- (AVPlayer *)player {
    return [(AVPlayerLayer *)[self layer] player];
}

- (void)setPlayer:(AVPlayer *)player {
    [(AVPlayerLayer *)[self layer] setPlayer:player];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {

    self.touchPlayer();

}



@end
