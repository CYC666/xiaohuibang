//
//  FromCameraController.m
//  XiaoHuiBang
//
//  Created by mac on 16/11/8.
//  Copyright © 2016年 消汇邦. All rights reserved.
//

// 曹老师今天去哪玩？
// 跟老板一起玩项目

// 从摄像头获取视频或照片



#import "FromCameraController.h"
#import "SendMomentsController.h"
#import "CSwitchButton.h"
#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>

#define openSendCommentControllerNotification @"openSendCommentControllerNotification"  // 发送打开发送动态界面的通知
#define kScreenHeight [UIScreen mainScreen].bounds.size.height                          // 屏高
#define kScreenWidth [UIScreen mainScreen].bounds.size.width                            // 屏宽


typedef void(^PropertyChangeBlock)(AVCaptureDevice *captureDevice);

@interface FromCameraController () <AVCaptureFileOutputRecordingDelegate> {
    SystemSoundID soundID;                                                          // 系统声音标识符
}

@property (strong,nonatomic) AVCaptureSession *captureSession;                      // 负责输入和输出设备之间的数据传递
@property (strong,nonatomic) AVCaptureDeviceInput *captureDeviceInput;              // 负责从AVCaptureDevice获得输入数据
@property (strong,nonatomic) AVCaptureDeviceInput *audioCaptureDeviceInput;         // 音频输入数据
@property (strong,nonatomic) AVCaptureStillImageOutput *captureStillImageOutput;    // 照片输出流
@property (strong,nonatomic) AVCaptureMovieFileOutput *captureMovieFileOutput;      // 视频输出流
@property (strong,nonatomic) AVCaptureVideoPreviewLayer *captureVideoPreviewLayer;  // 相机拍摄预览图层
@property (weak, nonatomic) IBOutlet UIView *viewContainer;
@property (weak, nonatomic) IBOutlet UIView *tapGestureView;                        // 接收点击手势的图层
@property (weak, nonatomic) IBOutlet UIButton *flashOnButton;                       // 打开闪光灯按钮
@property (weak, nonatomic) IBOutlet UIImageView *focusCursor;                      // 聚焦光标
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIButton *changeCameraButton;
@property (weak, nonatomic) IBOutlet UIButton *changeFlashButton;
@property (strong, nonatomic) UIImageView *imageShow;                               // 显示拍好的照片
@property (strong, nonatomic) AVPlayerViewController *moviePlayer;                  // 显示拍好的视频
@property (strong, nonatomic) UIButton *redoButton;                                 // 重做按钮
@property (strong, nonatomic) UIButton *saveButton;                                 // 保存按钮
@property (strong, nonatomic) UIButton *sureButton;                                 // 确定按钮
@property (strong, nonatomic) UIImage *imageOK;                                     // 暂存的image
@property (strong, nonatomic) NSURL *movieUrlOK;                                    // 暂存视频的URL
@property (assign, nonatomic) float audioTime;                                      // 时长
@property (assign, nonatomic) BOOL isPicture;                                       // 标志是拍照
@property (weak, nonatomic) IBOutlet UIImageView *holderImage;


@end

@implementation FromCameraController

- (UIImageView *)imageShow {

    if (_imageShow == nil) {
        _imageShow = [[UIImageView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        [self.view addSubview:_imageShow];
    }
    return _imageShow;

}

- (AVPlayerViewController *)moviePlayer {

    if (_moviePlayer == nil) {
        _moviePlayer = [[AVPlayerViewController alloc] init];
        _moviePlayer.showsPlaybackControls = NO;
        _moviePlayer.view.frame = [UIScreen mainScreen].bounds;
        [self.view addSubview:_moviePlayer.view];
    }
    return _moviePlayer;

}

- (UIButton *)redoButton {

    if (_redoButton == nil) {
        _redoButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _redoButton.frame = CGRectMake((kScreenWidth - 64)/2, kScreenHeight - 64 - 50, 64, 64);
        [_redoButton setImage:[UIImage imageNamed:@"icon_redo"] forState:UIControlStateNormal];
        _redoButton.alpha = 0;
        [_redoButton addTarget:self action:@selector(redoAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_redoButton];
    }
    return _redoButton;

}
- (UIButton *)saveButton {
    
    if (_saveButton == nil) {
        _saveButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _saveButton.frame = CGRectMake((kScreenWidth - 64)/2, kScreenHeight - 64 - 50, 64, 64);
        [_saveButton setImage:[UIImage imageNamed:@"icon_download"] forState:UIControlStateNormal];
        _saveButton.alpha = 0;
        [_saveButton addTarget:self action:@selector(saveAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_saveButton];
    }
    return _saveButton;
    
}

- (UIButton *)sureButton {

    if (_sureButton == nil) {
        _sureButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _sureButton.frame = CGRectMake((kScreenWidth - 64)/2, kScreenHeight - 64 - 50, 64, 64);
        [_sureButton setImage:[UIImage imageNamed:@"icon_done"] forState:UIControlStateNormal];
        _sureButton.alpha = 0;
        [_sureButton addTarget:self action:@selector(doneAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_sureButton];
    }
    return _sureButton;

}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 隐藏轻击拍照提示和聚焦框
    [self performSelector:@selector(hideHolderLabel) withObject:nil afterDelay:4];
    
    CSwitchButton *cameraSwitch = [[CSwitchButton alloc] initWithFrame:CGRectMake((kScreenWidth - 75)/2.0, kScreenHeight - (63 + 75/2.0), 75, 75)];
    [self.view addSubview:cameraSwitch];
    
    __weak FromCameraController *weakSelf = self;
    // 拍照
    cameraSwitch.pictureBlock = ^() {
        
        [weakSelf takePhoto];
    
    };
    
    
    
    // 摄像开始
    cameraSwitch.startMovieBlock = ^() {
        
        [weakSelf takeMocieBegin];
        
    };
    
    // 结束摄像
    cameraSwitch.endMovieBlock = ^(float time) {
        
        [weakSelf takeMovieEnd:time];
    
    };
    
    
    
}

#pragma mark - 拍照
- (void)takePhoto {

    _isPicture = YES;
    
    AVCaptureConnection *captureConnection = [self.captureStillImageOutput connectionWithMediaType:AVMediaTypeVideo];
    [self.captureStillImageOutput captureStillImageAsynchronouslyFromConnection:captureConnection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
        if (imageDataSampleBuffer) {
            NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
            _imageOK = [UIImage imageWithData:imageData];
            
            // 显示预览
            self.imageShow.image = _imageOK;
            self.redoButton.alpha = 1;
            self.saveButton.alpha = 0;
            self.sureButton.alpha = 1;
            [UIView animateWithDuration:.35
                             animations:^{
                                 self.redoButton.transform = CGAffineTransformMakeTranslation(-100, 0);
                                 self.saveButton.alpha = 1;
                                 self.sureButton.transform = CGAffineTransformMakeTranslation(100, 0);
                             }];
            
        }
        
    }];

}

#pragma mark - 摄像
// 开始
- (void)takeMocieBegin {
    
    //根据设备输出获得连接
    AVCaptureConnection *captureConnection = [self.captureMovieFileOutput connectionWithMediaType:AVMediaTypeVideo];
    //根据连接取得设备输出的数据
    if (![self.captureMovieFileOutput isRecording]) {
        //预览图层和视频方向保持一致
        captureConnection.videoOrientation = [self.captureVideoPreviewLayer connection].videoOrientation;
        NSString *outputFielPath = [NSTemporaryDirectory() stringByAppendingString:@"myMovie.mov"];
        NSLog(@"save path is :%@",outputFielPath);
        NSURL *fileUrl = [NSURL fileURLWithPath:outputFielPath];
        [self.captureMovieFileOutput startRecordingToOutputFileURL:fileUrl recordingDelegate:self];
    }



    [UIView animateWithDuration:.35
                     animations:^{
                         _cancelButton.alpha = 0;
                         _changeFlashButton.alpha = 0;
                         _changeCameraButton.alpha = 0;
                     }];
    

    
}
// 结束
- (void)takeMovieEnd:(float)time {

    _isPicture = NO;

    _audioTime = time;

    [self.captureMovieFileOutput stopRecording];//停止录制

    [UIView animateWithDuration:.35
                     animations:^{
                         _cancelButton.alpha = 1;
                         _changeFlashButton.alpha = 1;
                         _changeCameraButton.alpha = 1;
                     }];
    
}

#pragma mark - 视频输出代理方法
-(void)captureOutput:(AVCaptureFileOutput *)captureOutput didStartRecordingToOutputFileAtURL:(NSURL *)fileURL fromConnections:(NSArray *)connections{
    
}

-(void)captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray *)connections error:(NSError *)error{
    
    if (_audioTime > 0.5) {
        
        float distence = kScreenWidth/2 - 75;
        // 预览视频，要或不要
        self.moviePlayer.player = [[AVPlayer alloc] initWithURL:outputFileURL];
        [self.moviePlayer.player play];
        self.redoButton.alpha = 1;
        self.saveButton.alpha = 0;
        self.sureButton.alpha = 1;
        [UIView animateWithDuration:.35
                         animations:^{
                             self.redoButton.transform = CGAffineTransformMakeTranslation(-distence, 0);
                             self.saveButton.alpha = 1;
                             self.sureButton.transform = CGAffineTransformMakeTranslation(distence, 0);
                         }];
        _movieUrlOK = outputFileURL;
        
    } else {
        // 舍弃视频
    }
    
}

#pragma mark - 拍照成功后的重做、确定按钮响应
- (void)redoAction:(UIButton *)button {
    
    [UIView animateWithDuration:.35
                     animations:^{
                         self.redoButton.transform = CGAffineTransformIdentity;
                         self.saveButton.alpha = 0;
                         self.sureButton.transform = CGAffineTransformIdentity;
                     } completion:^(BOOL finished) {
                         if (_imageShow != nil) {
                             [_imageShow removeFromSuperview];
                             _imageShow = nil;
                         }
                         if (_moviePlayer != nil) {
                             [_moviePlayer.view removeFromSuperview];
                             _moviePlayer = nil;
                         }
                         [self.redoButton removeFromSuperview];
                         [self.saveButton removeFromSuperview];
                         [self.sureButton removeFromSuperview];
                         self.redoButton = nil;
                         self.saveButton = nil;
                         self.sureButton = nil;
                     }];

}
- (void)doneAction:(UIButton *)button {
    
    //这里要先dismiss，不然传数据过去后，那边的present会被撤销
    [self dismissViewControllerAnimated:YES completion:nil];

    if (_isPicture == YES) {
        // 保存并返回image
        UIImageWriteToSavedPhotosAlbum(_imageOK, nil, nil, nil);
        __block UIImage *image = _imageOK;
        self.imageBlock(image);
    } else {
        __block NSURL *url = _movieUrlOK;
        self.imageBlock(url);
    
    }

}
- (void)saveAction:(UIButton *)button {

    if (_isPicture == YES) {
        // 保存图片
        UIImageWriteToSavedPhotosAlbum(_imageOK, nil, nil, nil);
    } else {
        // 保存视频
        ALAssetsLibrary *assetsLibrary=[[ALAssetsLibrary alloc] init];
        [assetsLibrary writeVideoAtPathToSavedPhotosAlbum:_movieUrlOK completionBlock:^(NSURL *assetURL, NSError *error) {
            
        }];

    }
    [SVProgressHUD dismiss];
    [SVProgressHUD showSuccessWithStatus:@"已保存"];
    button.enabled = NO;

}

#pragma mark - 轻击拍照提示隐藏
- (void)hideHolderLabel {

    [UIView animateWithDuration:.35
                     animations:^{
                         _holderImage.alpha = 0;
                         _focusCursor.alpha = 0;
                     }];

}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    // 初始化会话
    _captureSession = [[AVCaptureSession alloc] init];
    // 设置分辨率
    if ([_captureSession canSetSessionPreset:AVCaptureSessionPresetHigh]) {
        _captureSession.sessionPreset=AVCaptureSessionPresetHigh;
    }
    // 获得输入设备
    AVCaptureDevice *captureDevice = [self getCameraDeviceWithPosition:AVCaptureDevicePositionBack];//取得后置摄像头
    if (!captureDevice) {
        NSLog(@"取得后置摄像头时出现问题.");
        return;
    }
    
    
    
    
// 拍照的设置
    
    
    NSError *error=nil;
    // 根据输入设备初始化设备输入对象，用于获得输入数据
    _captureDeviceInput = [[AVCaptureDeviceInput alloc] initWithDevice:captureDevice error:&error];
    if (error) {
        NSLog(@"取得设备输入对象时出错，错误原因：%@", error.localizedDescription);
        return;
    }
    
    //初始化设备输出对象，用于获得输出数据
    _captureStillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    NSDictionary *outputSettings = @{AVVideoCodecKey:AVVideoCodecJPEG};
    [_captureStillImageOutput setOutputSettings:outputSettings];//输出设置
    
    //将设备输入添加到会话中
    if ([_captureSession canAddInput:_captureDeviceInput]) {
        [_captureSession addInput:_captureDeviceInput];
    }
    
    //将设备输出添加到会话中
    if ([_captureSession canAddOutput:_captureStillImageOutput]) {
        [_captureSession addOutput:_captureStillImageOutput];
    }
    
    
    
// 摄像的设置
    
    // 添加一个麦克风输入设备
    AVCaptureDevice *audioCaptureDevice = [[AVCaptureDevice devicesWithMediaType:AVMediaTypeAudio] firstObject];
    NSError *audioError;
    _audioCaptureDeviceInput = [[AVCaptureDeviceInput alloc] initWithDevice:audioCaptureDevice error:&audioError];
    if (audioError) {
        NSLog(@"取得设备输入对象时出错，错误原因：%@",error.localizedDescription);
        return;
    }
    //初始化设备输出对象，用于获得输出数据
    _captureMovieFileOutput = [[AVCaptureMovieFileOutput alloc] init];
    //将设备输入添加到会话中
    if ([_captureSession canAddInput:_audioCaptureDeviceInput]) {
        [_captureSession addInput:_audioCaptureDeviceInput];
        AVCaptureConnection *captureConnection = [_captureMovieFileOutput connectionWithMediaType:AVMediaTypeVideo];
        if ([captureConnection isVideoStabilizationSupported]) {
            captureConnection.preferredVideoStabilizationMode = AVCaptureVideoStabilizationModeAuto;
        }
    }
    //将设备输出添加到会话中
    if ([_captureSession canAddOutput:_captureMovieFileOutput]) {
        [_captureSession addOutput:_captureMovieFileOutput];
    }
    
    
    
    
    
    
    
    
    //创建视频预览层，用于实时展示摄像头状态
    _captureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.captureSession];
    
    CALayer *layer = self.viewContainer.layer;
    layer.masksToBounds = YES;
    
    _captureVideoPreviewLayer.frame = [UIScreen mainScreen].bounds;
    _captureVideoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;//填充模式
    //将视频预览层添加到界面中
    [layer insertSublayer:_captureVideoPreviewLayer below:self.focusCursor.layer];
    
    [self addNotificationToCaptureDevice:captureDevice];
    [self addGenstureRecognizer];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self.captureSession startRunning];
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [self.captureSession stopRunning];
}

-(void)dealloc{
    [self removeNotification];
}




#pragma mark - 通知
// 给输入设备添加通知
-(void)addNotificationToCaptureDevice:(AVCaptureDevice *)captureDevice{
    //注意添加区域改变捕获通知必须首先设置设备允许捕获
    [self changeDeviceProperty:^(AVCaptureDevice *captureDevice) {
        captureDevice.subjectAreaChangeMonitoringEnabled = YES;
    }];
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    //捕获区域发生改变
    [notificationCenter addObserver:self selector:@selector(areaChange:) name:AVCaptureDeviceSubjectAreaDidChangeNotification object:captureDevice];
}
-(void)removeNotificationFromCaptureDevice:(AVCaptureDevice *)captureDevice{
    NSNotificationCenter *notificationCenter= [NSNotificationCenter defaultCenter];
    [notificationCenter removeObserver:self name:AVCaptureDeviceSubjectAreaDidChangeNotification object:captureDevice];
}
/**
 *  移除所有通知
 */
-(void)removeNotification{
    NSNotificationCenter *notificationCenter= [NSNotificationCenter defaultCenter];
    [notificationCenter removeObserver:self];
}

-(void)addNotificationToCaptureSession:(AVCaptureSession *)captureSession{
    NSNotificationCenter *notificationCenter= [NSNotificationCenter defaultCenter];
    //会话出错
    [notificationCenter addObserver:self selector:@selector(sessionRuntimeError:) name:AVCaptureSessionRuntimeErrorNotification object:captureSession];
}



// 捕获区域改变
-(void)areaChange:(NSNotification *)notification{
    NSLog(@"捕获区域改变...");
}


// 会话出错
-(void)sessionRuntimeError:(NSNotification *)notification{
    NSLog(@"会话发生错误.");
}

#pragma mark - 私有方法


// 取得指定位置的摄像头---前置、后置摄像头
-(AVCaptureDevice *)getCameraDeviceWithPosition:(AVCaptureDevicePosition )position{
    NSArray *cameras= [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *camera in cameras) {
        if ([camera position] == position) {
            return camera;
        }
    }
    return nil;
}


// 改变设备属性的统一操作方法
-(void)changeDeviceProperty:(PropertyChangeBlock)propertyChange{
    AVCaptureDevice *captureDevice= [self.captureDeviceInput device];
    NSError *error;
    //注意改变设备属性前一定要首先调用lockForConfiguration:调用完之后使用unlockForConfiguration方法解锁
    if ([captureDevice lockForConfiguration:&error]) {
        propertyChange(captureDevice);
        [captureDevice unlockForConfiguration];
    }else{
        NSLog(@"设置设备属性过程发生错误，错误信息：%@",error.localizedDescription);
    }
}

// 设置闪光灯模式
-(void)setFlashMode:(AVCaptureFlashMode )flashMode{
    [self changeDeviceProperty:^(AVCaptureDevice *captureDevice) {
        if ([captureDevice isFlashModeSupported:flashMode]) {
            [captureDevice setFlashMode:flashMode];
        }
    }];
}

// 设置聚焦模式
-(void)setFocusMode:(AVCaptureFocusMode )focusMode{
    [self changeDeviceProperty:^(AVCaptureDevice *captureDevice) {
        if ([captureDevice isFocusModeSupported:focusMode]) {
            [captureDevice setFocusMode:focusMode];
        }
    }];
}

// 设置曝光模式
-(void)setExposureMode:(AVCaptureExposureMode)exposureMode{
    [self changeDeviceProperty:^(AVCaptureDevice *captureDevice) {
        if ([captureDevice isExposureModeSupported:exposureMode]) {
            [captureDevice setExposureMode:exposureMode];
        }
    }];
}

// 设置聚焦点
-(void)focusWithMode:(AVCaptureFocusMode)focusMode exposureMode:(AVCaptureExposureMode)exposureMode atPoint:(CGPoint)point{
    [self changeDeviceProperty:^(AVCaptureDevice *captureDevice) {
        if ([captureDevice isFocusModeSupported:focusMode]) {
            [captureDevice setFocusMode:AVCaptureFocusModeAutoFocus];
        }
        if ([captureDevice isFocusPointOfInterestSupported]) {
            [captureDevice setFocusPointOfInterest:point];
        }
        if ([captureDevice isExposureModeSupported:exposureMode]) {
            [captureDevice setExposureMode:AVCaptureExposureModeAutoExpose];
        }
        if ([captureDevice isExposurePointOfInterestSupported]) {
            [captureDevice setExposurePointOfInterest:point];
        }
    }];
}


// 添加点按手势，点按时聚焦
-(void)addGenstureRecognizer{
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapScreen:)];
    [self.tapGestureView addGestureRecognizer:tapGesture];
}
// 聚焦
-(void)tapScreen:(UITapGestureRecognizer *)tapGesture{
    CGPoint point= [tapGesture locationInView:self.viewContainer];
    // 将UI坐标转化为摄像头坐标
    CGPoint cameraPoint = [self.captureVideoPreviewLayer captureDevicePointOfInterestForPoint:point];
    [self setFocusCursorWithPoint:point];
    [self focusWithMode:AVCaptureFocusModeAutoFocus exposureMode:AVCaptureExposureModeAutoExpose atPoint:cameraPoint];
}

// 设置聚焦光标位置
-(void)setFocusCursorWithPoint:(CGPoint)point{
    self.focusCursor.center = point;
    self.focusCursor.transform = CGAffineTransformMakeScale(1.3, 1.3);
    self.focusCursor.alpha = 1.0;
    [UIView animateWithDuration:1.0 animations:^{
        self.focusCursor.transform=CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        self.focusCursor.alpha=0;
        
    }];
}

// 播放快门声音
- (void)soundPlay {

    // 不播放快门声音
//    NSString *sysPath = [[NSBundle mainBundle] pathForResource:@"sound.mp3" ofType:nil];
//    NSURL *sysUrl=[NSURL fileURLWithPath:sysPath];
//    AudioServicesCreateSystemSoundID((__bridge CFURLRef)sysUrl, &soundID);
//    AudioServicesPlaySystemSound(soundID);
}























#pragma mark - 按钮响应
// 取消
- (IBAction)cancelButton:(UIButton *)sender {
    
    [UIView animateWithDuration:.35
                     animations:^{
                         sender.transform = CGAffineTransformMakeScale(1.5, 1.5);
                     } completion:^(BOOL finished) {
                         [UIView animateWithDuration:.2
                                          animations:^{
                                              sender.transform = CGAffineTransformIdentity;
                                          } completion:^(BOOL finished) {
                                              [self dismissViewControllerAnimated:YES completion:nil];
                                          }];
                     }];
    
}

// 打开闪光灯
- (IBAction)openFlash:(UIButton *)sender {
    
    _isFlash = !_isFlash;
    if (_isFlash == YES) {
        [self setFlashMode:AVCaptureFlashModeOn];
        [sender setImage:[UIImage imageNamed:@"icon_flash_open"] forState:UIControlStateNormal];
    } else {
        [self setFlashMode:AVCaptureFlashModeOff];
        [sender setImage:[UIImage imageNamed:@"icon_flash_close"] forState:UIControlStateNormal];
    }
    
}



// 切换前后摄像头
- (IBAction)toggleButtonClick:(UIButton *)sender {
    
    AVCaptureDevice *currentDevice = [self.captureDeviceInput device];
    AVCaptureDevicePosition currentPosition = [currentDevice position];
    [self removeNotificationFromCaptureDevice:currentDevice];
    AVCaptureDevice *toChangeDevice;
    AVCaptureDevicePosition toChangePosition = AVCaptureDevicePositionFront;
    if (currentPosition == AVCaptureDevicePositionUnspecified || currentPosition == AVCaptureDevicePositionFront) {
        toChangePosition=AVCaptureDevicePositionBack;
    }
    toChangeDevice = [self getCameraDeviceWithPosition:toChangePosition];
    [self addNotificationToCaptureDevice:toChangeDevice];
    //获得要调整的设备输入对象
    AVCaptureDeviceInput *toChangeDeviceInput=[[AVCaptureDeviceInput alloc]initWithDevice:toChangeDevice error:nil];
    
    //改变会话的配置前一定要先开启配置，配置完成后提交配置改变
    [self.captureSession beginConfiguration];
    //移除原有输入对象
    [self.captureSession removeInput:self.captureDeviceInput];
    //添加新的输入对象
    if ([self.captureSession canAddInput:toChangeDeviceInput]) {
        [self.captureSession addInput:toChangeDeviceInput];
        self.captureDeviceInput = toChangeDeviceInput;
    }
    //提交会话配置
    [self.captureSession commitConfiguration];
    
}
         
@end






/*
 
 // 拍照
 - (IBAction)takeButtonClick:(UIButton *)sender {
 
 [self soundPlay];
 //根据设备输出获得连接
 AVCaptureConnection *captureConnection=[self.captureStillImageOutput connectionWithMediaType:AVMediaTypeVideo];
 //根据连接取得设备输出的数据
 [self.captureStillImageOutput captureStillImageAsynchronouslyFromConnection:captureConnection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
 if (imageDataSampleBuffer) {
 NSData *imageData=[AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
 __block UIImage *image=[UIImage imageWithData:imageData];
 
 // 显示预览
 
 UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
 self.imageBlock(image);
 [self dismissViewControllerAnimated:YES completion:nil];
 
 }
 
 }];
 }
 
 #pragma mark - 轻扫切换摄像跟拍照
 - (void)swipeRightAction:(UISwipeGestureRecognizer *)swipe {
 // 拍照
 
 [UIView animateWithDuration:.35
 animations:^{
 _picLabel.transform = CGAffineTransformIdentity;
 _movLabel.transform = CGAffineTransformIdentity;
 } completion:^(BOOL finished) {
 _picLabel.textColor = [UIColor colorWithRed:29/255.0 green:161/255.0 blue:243/255.0 alpha:1];
 _movLabel.textColor = [UIColor whiteColor];
 }];
 
 }
 
 - (void)swipeLeftAction:(UISwipeGestureRecognizer *)swipe {
 // 摄像
 
 [UIView animateWithDuration:.35
 animations:^{
 _picLabel.transform = CGAffineTransformMakeTranslation(-40, 0);
 _movLabel.transform = CGAffineTransformMakeTranslation(-40, 0);
 } completion:^(BOOL finished) {
 _picLabel.textColor = [UIColor whiteColor];
 _movLabel.textColor = [UIColor colorWithRed:29/255.0 green:161/255.0 blue:243/255.0 alpha:1];
 }];
 
 }
 
 @property (weak, nonatomic) IBOutlet UILabel *picLabel;                             // 拍照标签
 @property (weak, nonatomic) IBOutlet UILabel *movLabel;                             // 摄像标签
@property (weak, nonatomic) IBOutlet UIButton *takeButton;                          //拍照按钮
 
 UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self
 action:@selector(swipeRightAction:)];
 swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
 swipeRight.numberOfTouchesRequired = 1;
 [self.view addGestureRecognizer:swipeRight];
 
 UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self
 action:@selector(swipeLeftAction:)];
 swipeLeft.direction = UISwipeGestureRecognizerDirectionLeft;
 swipeLeft.numberOfTouchesRequired = 1;
 [self.view addGestureRecognizer:swipeLeft];
 
 */






/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


