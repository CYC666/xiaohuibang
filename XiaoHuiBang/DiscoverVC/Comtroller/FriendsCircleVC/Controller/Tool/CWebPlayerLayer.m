//
//  CWebPlayerLayer.m
//  XiaoHuiBang
//
//  Created by mac on 16/12/29.
//  Copyright © 2016年 消汇邦. All rights reserved.
//

#import "CWebPlayerLayer.h"
#import <AFNetworking.h>
#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>

@interface CWebPlayerLayer ()

@property (strong, nonatomic) AFHTTPSessionManager *manager;
@property (strong, nonatomic) AVPlayerLayer *playerLayer;
@property (strong, nonatomic) AVPlayerItem *playerItem;
@property (strong, nonatomic) AVPlayer *player;
@property (strong, nonatomic) UIProgressView *progressView;

@end

@implementation CWebPlayerLayer

- (instancetype)initWithFrame:(CGRect)frame withUrl:(NSURL *)url {

    if (self = [super initWithFrame:frame]) {
        self.movieUrl = url;
    }
    return self;
    
}


- (UIProgressView *)progressView {

    if (_progressView == nil) {
        self.backgroundColor = [UIColor blackColor];
        _progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 2)];
        [self addSubview:_progressView];
    }
    return _progressView;

}


- (void)setMovieUrl:(NSURL *)movieUrl {

    __weak typeof(self) weakSelf = self;
    _manager = [AFHTTPSessionManager manager];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:movieUrl];
    NSURLSessionDownloadTask *task = [_manager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
        dispatch_sync(dispatch_get_main_queue(), ^{
            self.progressView.progress = (double)downloadProgress.fractionCompleted;
        });
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        
        NSString *filePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/a.mp4"];
        return [NSURL fileURLWithPath:filePath];
        
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        weakSelf.progressView.alpha = 0;
        if (!error) {
            [weakSelf playeMovie:filePath];
        }
    }];
    [task resume];
}

#pragma mark - 播放
- (void)playeMovie:(NSURL *)url {

    _playerItem = [[AVPlayerItem alloc] initWithURL:url];
    _player = [[AVPlayer alloc] initWithPlayerItem:_playerItem];
    _playerLayer = [[AVPlayerLayer alloc] init];
    _playerLayer.frame = self.bounds;
    _playerLayer.player = _player;
    [self.layer addSublayer:_playerLayer];
    [_player play];

}



































@end
