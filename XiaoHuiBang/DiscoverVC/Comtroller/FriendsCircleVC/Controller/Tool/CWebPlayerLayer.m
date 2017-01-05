//
//  CWebPlayerLayer.m
//  XiaoHuiBang
//
//  Created by mac on 16/12/29.
//  Copyright © 2016年 消汇邦. All rights reserved.
//

#import "CWebPlayerLayer.h"
#import <UIImageView+WebCache.h>


@interface CWebPlayerLayer ()



@end

@implementation CWebPlayerLayer



- (instancetype)initWithFrame:(CGRect)frame withUrl:(NSString *)urlStr movieThumb:(NSString *)thumb{

    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor blackColor];
        self.movieThumb = thumb;
        self.movieUrlStr = urlStr;
    }
    return self;
    
}


- (UIProgressView *)progressView {

    if (_progressView == nil) {
        self.backgroundColor = [UIColor blackColor];
        _progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(0, -0.5, self.bounds.size.width, 1)];
        [self addSubview:_progressView];
    }
    return _progressView;

}

- (UIProgressView *)playProgressView {
    
    if (_playProgressView == nil) {
        _playProgressView = [[UIProgressView alloc] initWithFrame:CGRectMake(0, -0.5, self.bounds.size.width, 1)];
        [self addSubview:_playProgressView];
    }
    return _progressView;
    
}

- (UIActivityIndicatorView *)activityView {

    if (_activityView == nil) {
        _activityView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake((self.bounds.size.width - 100)/2.0, (self.bounds.size.height - 100)/2.0, 100, 100)];
        _activityView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
        [self addSubview:_activityView];
    }
    return _activityView;

}

- (UIImageView *)thumbView {

    if (_thumbView == nil) {
        _thumbView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [_thumbView sd_setImageWithURL:[NSURL URLWithString:_movieThumb]];
        _thumbView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:_thumbView];
    }
    return _thumbView;

}

- (void)setIsCycle:(BOOL)isCycle {

    _isCycle = isCycle;
    if (_isCycle) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(moviePlayDidEnd:)
                                                     name:AVPlayerItemDidPlayToEndTimeNotification
                                                   object:_playerItem];
    }

}

// 设置url的时候，开始下载视频
- (void)setMovieUrlStr:(NSString *)movieUrlStr {
    
    _movieUrlStr = movieUrlStr;
    
    // 判断本地是否已经有了视频
    // 有则播放，无则下载，下载完后保存到本地
    NSMutableString *mString = [NSMutableString stringWithString:movieUrlStr];
    [mString replaceCharactersInRange:NSMakeRange(0, 45) withString:@""];
    __block NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@", mString]];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:path]) {
        // 存在视频，直接播放
        [self playeMovie:[NSURL fileURLWithPath:path]];
    } else {
        // 显示截图(!!!错误，不能在这里设置，因为只设置了movie的url，截图的url没获取到。故不能显示截图)
        // 改正，在设置movie的url之前先设置好截图的url
        self.thumbView.frame = self.bounds;
        [self.activityView startAnimating];
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
            if (!error) {
                
                [weakSelf playeMovie:filePath];
            }
        }];
        [task resume];
    }
}

#pragma mark - 播放
- (void)playeMovie:(NSURL *)url {
    
    if (_thumbView != nil) {
        _thumbView.alpha = 0;
        _thumbView = nil;
    }

    if (_progressView != nil) {
        _progressView.alpha = 0;
        _progressView = nil;
    }
    
    if (_activityView != nil) {
        _activityView.alpha = 0;
        _activityView = nil;
    }
    _playerItem = [[AVPlayerItem alloc] initWithURL:url];
    _player = [[AVPlayer alloc] initWithPlayerItem:_playerItem];
    _playerLayer = [[AVPlayerLayer alloc] init];
    _playerLayer.frame = self.bounds;
    _playerLayer.player = _player;
    [self.layer addSublayer:_playerLayer];
    [_player play];
    
    

}

#pragma mark - 循环播放
- (void)moviePlayDidEnd:(NSNotification *)notification {
    
    __weak typeof(self) weakSelf = self;
    [self.playerLayer.player seekToTime:kCMTimeZero completionHandler:^(BOOL finished) {
        [weakSelf.player play];
    }];
}


#pragma mark - 销毁
- (void)dealloc {

    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:AVPlayerItemDidPlayToEndTimeNotification
                                                  object:_playerItem];
    

}






























@end
