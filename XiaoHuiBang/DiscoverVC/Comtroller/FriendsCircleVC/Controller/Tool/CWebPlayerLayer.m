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

- (instancetype)initWithFrame:(CGRect)frame withUrl:(NSString *)urlStr {

    if (self = [super initWithFrame:frame]) {
        self.movieUrlStr = urlStr;
    }
    return self;
    
}


- (UIProgressView *)progressView {

    if (_progressView == nil) {
        self.backgroundColor = [UIColor blackColor];
        _progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, .5)];
        [self addSubview:_progressView];
    }
    return _progressView;

}


// 设置url的时候，开始下载视频
- (void)setMovieUrlStr:(NSString *)movieUrlStr {
    
    // 判断本地是否已经有了视频
    // 有则播放，无则下载，下载完后保存到本地
    NSMutableString *mString = [NSMutableString stringWithString:movieUrlStr];
    [mString replaceCharactersInRange:NSMakeRange(0, 45) withString:@""];
    __block NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@", mString]];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:path]) {
        // 存在视频，直接播放
        [self playeMovie:[NSURL URLWithString:path]];
    } else {
        _movieUrlStr = movieUrlStr;
        __weak typeof(self) weakSelf = self;
        _manager = [AFHTTPSessionManager manager];
        NSURL *movieUrl = [NSURL URLWithString:movieUrlStr];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:movieUrl];
        NSURLSessionDownloadTask *task = [_manager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
            dispatch_sync(dispatch_get_main_queue(), ^{
                self.progressView.progress = (double)downloadProgress.fractionCompleted;
            });
        } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
            
            return [NSURL fileURLWithPath:path];
            
        } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
            // 这里应该保存视频
            NSLog(@"%@", path);
            weakSelf.progressView.alpha = 0;
            if (!error) {
                [weakSelf playeMovie:filePath];
            }
        }];
        [task resume];
    }
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
