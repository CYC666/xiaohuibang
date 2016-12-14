//
//  FromCamera.m
//  XiaoHuiBang
//
//  Created by mac on 16/12/14.
//  Copyright © 2016年 消汇邦. All rights reserved.
//

#import "FromCamera.h"

#define kScreenHeight [UIScreen mainScreen].bounds.size.height                          // 屏高
#define kScreenWidth [UIScreen mainScreen].bounds.size.width                            // 屏宽
#define openSendCommentControllerNotification @"openSendCommentControllerNotification"  // 发送打开发送动态界面的通知

@interface FromCamera () <UINavigationControllerDelegate, UIImagePickerControllerDelegate> {

    BOOL _isMovie;    // 是否是摄像

}

@end

@implementation FromCamera

- (instancetype)initWithType:(CameraType)type {

    self = [super init];
    if (self != nil) {
        if (type == Picture) {
            _isMovie = NO;
        } else if (type == Movie) {
            _isMovie = YES;
        }
    }
    return self;

}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    
    self.sourceType = UIImagePickerControllerSourceTypeCamera;
    self.videoQuality = UIImagePickerControllerQualityTypeHigh;
    if (_isMovie == YES) {
        self.mediaTypes = @[(NSString *)kUTTypeMovie];
        self.cameraCaptureMode = UIImagePickerControllerCameraCaptureModeVideo;
        self.videoMaximumDuration = 10;
        self.allowsEditing = YES;
    } else {
        self.mediaTypes = @[(NSString *)kUTTypeImage];
        self.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
    }
    self.delegate = self;
    
}



- (void)viewWillAppear:(BOOL)animated {

    [super viewWillAppear:animated];
    
    [UIView animateWithDuration:.35
                     animations:^{
                         // 隐藏状态栏
                         [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
                     }];

}

- (void)viewWillDisappear:(BOOL)animated {

    // 显示状态栏
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];

}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    
    NSString *mediaType=[info objectForKey:UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {//如果是拍照
        UIImage *image;
        //如果允许编辑则获得编辑后的照片，否则获取原始照片
        if (self.allowsEditing) {
            image=[info objectForKey:UIImagePickerControllerEditedImage];//获取编辑后的照片
        }else{
            image=[info objectForKey:UIImagePickerControllerOriginalImage];//获取原始照片
        }
        
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);//保存到相簿
        
        // dismiss必须这样写，不然那边接受到通知也会dismiss，没效果
        [picker dismissViewControllerAnimated:YES completion:^{
            // 发送通知，跳转到发动态界面,将选好的图片发送过去
            [[NSNotificationCenter defaultCenter] postNotificationName:openSendCommentControllerNotification
                                                                object:image];
        }];
        
    }else if([mediaType isEqualToString:(NSString *)kUTTypeMovie]){//如果是录制视频

        NSURL *url=[info objectForKey:UIImagePickerControllerMediaURL];//视频路径
        NSString *urlStr=[url path];
        if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(urlStr)) {
            //保存视频到相簿，注意也可以使用ALAssetsLibrary来保存
            // UISaveVideoAtPathToSavedPhotosAlbum(urlStr, nil, nil, nil);//保存视频到相簿
        }
        // 发送视频
        [picker dismissViewControllerAnimated:YES completion:nil];
    }
    
    [picker dismissViewControllerAnimated:YES completion:nil];

}


- (void)dismissViewControllerAnimated:(BOOL)flag completion:(void (^)(void))completion {

    [super dismissViewControllerAnimated:flag completion:completion];
    
    // 在此返回数据
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];

}




































@end
