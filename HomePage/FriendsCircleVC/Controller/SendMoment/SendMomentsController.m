//
//  SendMomentsController.m
//  XiaoHuiBang
//
//  Created by mac on 16/11/8.
//  Copyright © 2016年 消汇邦. All rights reserved.
//

// 发表动态编辑界面



#import "SendMomentsController.h"
#import "CNetTool.h"
#import "CImageView.h"
#import "NSString+Extension.h"
#import "FromCameraController.h"
#import <SVProgressHUD.h>
#import "SuPhotoPicker.h"
#import "SuPhotoPreviewer.h"
#import "SuPhotoCenter.h"
#import "NSString+CEmojChange.h"
#import "CLocationShow.h"
#import "LGPhoto.h"
#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>
#import "CPlayerLayer.h"

#define reloadSeeDate @"reloadSeeDate"                          // 刷新动态数据的通知


#define kScreenWidth [UIScreen mainScreen].bounds.size.width    // 屏宽
#define kScreenHeight [UIScreen mainScreen].bounds.size.height  // 屏高
#define kImageSize (kScreenWidth - 15 - 10 - 10 - 10 - 15)/4    // 图片大小
#define kTextViewHeightA 200                                    // 纯文字动态下的输入框高度
#define kTextViewHeightB 100                                    // 非纯文字动态下的输入框高度
#define kNormalCellHeight 40                                    // 其他单元格高度
#define kSpace 15                                               // 组之间的高度




@interface SendMomentsController () <UITextViewDelegate, UIScrollViewDelegate,
                                    UITableViewDelegate, UITableViewDataSource,
                        UIImagePickerControllerDelegate, UINavigationControllerDelegate,
                                    RCEmojiViewDelegate, CImageViewDelegate,
                    LGPhotoPickerViewControllerDelegate, LGPhotoPickerBrowserViewControllerDelegate,
           LGPhotoPickerBrowserViewControllerDataSource> {

    UITableView *_tableView;
    UITextView *_textView;              // 输入框
    RCEmojiBoardView *_emojiInputView;  // 表情输入框
    UIButton *_locationButton;          // 定位按钮
                                        


}

@property (assign, nonatomic) SendType type;                // 发送的类型
@property (strong, nonatomic) NSMutableArray *photoArray;   // 用于显示的图片组，是经过转化后的图片(点击显示大图)

@property (strong, nonatomic) NSMutableArray *imageArray;   // 储存即将上传的图片
@property (strong, nonatomic) NSURL *movieUrl;              // 储存即将上传的视频
@property (assign, nonatomic) float firstCellHeight;        // 第一个cell的高度

// 用于显示视频
@property (strong, nonatomic) AVPlayerItem *playerItem;
@property (strong, nonatomic) AVPlayer *player;
@property (strong, nonatomic) CPlayerLayer *playerLayer;
@property (assign, nonatomic) BOOL isPlayerFull;            // 标志视频播放是否全屏





@end

@implementation SendMomentsController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 创建子视图
    [self _createSubView];
    [self _setNavigationBar];
    
    
}
#pragma mark - 初始化方法
- (instancetype)initWithText {

    if (self = [super init]) {
        _type = CYC_TEXT;
        _firstCellHeight = kTextViewHeightA;
    }
    return self;

}
- (instancetype)initWithImageArray:(NSArray *)imageArray {

    if (self = [super init]) {
        _type = CYC_IMAGE;
        _firstCellHeight = kTextViewHeightB + (imageArray.count / 4 + 1)*(kImageSize + 10) + 10;
        [self.imageArray addObjectsFromArray:imageArray];
    }
    return self;

}
- (instancetype)initWithMovie:(NSURL *)movieUrl {

    if (self = [super init]) {
        _firstCellHeight = kTextViewHeightB + kImageSize + 20;
        _type = CYC_MOVIE;
        self.movieUrl = movieUrl;
    }
    return self;

}






- (void)viewDidAppear:(BOOL)animated {

    [super viewDidAppear:animated];
    
    _scrollView.delegate = self;
    
}



#pragma mark - 转化图片，用于浏览
- (void)transformImage:(NSInteger)index {

    // 修改成只看一张
    self.photoArray = [NSMutableArray array];
    LGPhotoPickerBrowserPhoto *photo = [[LGPhotoPickerBrowserPhoto alloc] init];
    photo.photoImage = _imageArray[index];
    [self.photoArray addObject:photo];
    
//    // 封装图片
//    for (int i = 0; i < _imageArray.count; i++) {
//        LGPhotoPickerBrowserPhoto *photo = [[LGPhotoPickerBrowserPhoto alloc] init];
//        photo.photoImage = _imageArray[i];
//        [self.photoArray addObject:photo];
//    }

}

#pragma mark - 懒加载
- (NSMutableArray *)imageArray {

    if (_imageArray == nil) {
        _imageArray = [NSMutableArray arrayWithCapacity:9];
    }
    return _imageArray;

}



#pragma mark - 设置导航栏
- (void)_setNavigationBar {
    
    self.navigationController.navigationBar.translucent = NO;

    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 40)];
    title.text = @"记录生活";
    title.font = [UIFont boldSystemFontOfSize:19];
    title.textAlignment = NSTextAlignmentCenter;
    title.textColor = [UIColor whiteColor];
    self.navigationItem.titleView = title;
    
    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"取消"
                                                                     style:UIBarButtonItemStylePlain
                                                                    target:self
                                                                    action:@selector(cancelAction:)];
    cancelButton.tintColor = [UIColor whiteColor];
    [self.navigationItem setLeftBarButtonItem:cancelButton];
    
    UIBarButtonItem *sendButton = [[UIBarButtonItem alloc] initWithTitle:@"发布"
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(sendAction:)];
    sendButton.tintColor = [UIColor colorWithRed:29/255.0 green:161/255.0 blue:243/255.0 alpha:1];
    sendButton.enabled = NO;
    [self.navigationItem setRightBarButtonItem:sendButton];

}

#pragma mark - 创建子视图
- (void)_createSubView {
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth,
                                                               _firstCellHeight + kNormalCellHeight*3 + kSpace)
                                              style:UITableViewStyleGrouped];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.scrollEnabled = NO;
    [_backgroundView addSubview:_tableView];

}

#pragma mark - 导航栏按钮响应
// 取消按钮
- (void)cancelAction:(UIBarButtonItem *)button {
    
    // 先隐藏键盘，再dismiss
    [_textView endEditing:YES];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"确定退出此次编辑？"
                                                                       message:nil
                                                                preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *sureAction = [UIAlertAction actionWithTitle:@"确定"
                                                         style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction * _Nonnull action) {
                                                           [self dismissViewControllerAnimated:YES completion:^{
                                                               // 缓存动态编辑的状态
                                                           }];
                                                       }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消"
                                                           style:UIAlertActionStyleDefault
                                                         handler:nil];
    [sureAction setValue:[UIColor redColor] forKey:@"_titleTextColor"];
    
    [alert addAction:cancelAction];
    [alert addAction:sureAction];
    [self presentViewController:alert animated:YES completion:nil];
    
    
}
// 发布按钮
- (void)sendAction:(UIBarButtonItem *)button {
    if (button.enabled == NO) {
        return;
    }
    
    if (_textView.text.length > 255) {
        // 弹窗提示字数过多
        [SVProgressHUD dismiss];
        [SVProgressHUD showErrorWithStatus:@"请少于255字"];
        return;
    }
    
    // 调用自定义类目的方法处理表情问题,讲表情转成字符串
    NSString *content = [_textView.text changeToString];
    


    // 发表动态
    NSMutableArray *imageDataArr = [NSMutableArray array];
    for (int i = 0; i < _imageArray.count; i++) {
        [imageDataArr addObject:UIImageJPEGRepresentation(_imageArray[i], 1)];
    }
    NSDictionary *params = @{@"user_id" : [USER_D objectForKey:@"user_id"],
                             @"content" : content,
                             @"file" : _imageArray.count == 0 ? @"" : _imageArray,
                             @"place" : _locationStr == nil ? @"" : _locationStr};

    
    if (_imageArray.count != 0) {
        [CNetTool postAboutWithParameters:params
                                     data:imageDataArr
                                  success:^(id response) {
                                      
                                      // 成功后刷新数据
                                      [[NSNotificationCenter defaultCenter] postNotificationName:reloadSeeDate
                                                                                          object:nil];
                                  } failure:^(NSError *err) {
                                      [SVProgressHUD dismiss];
                                      [SVProgressHUD showErrorWithStatus:@"发送失败"];
                                  }];
    } else {
    
        [CNetTool postAboutWithParameters:params
                                  success:^(id response) {
                                      
                                      [[NSNotificationCenter defaultCenter] postNotificationName:reloadSeeDate
                                                                                          object:nil];
                                  } failure:^(NSError *err) {
                                      [SVProgressHUD dismiss];
                                      [SVProgressHUD showErrorWithStatus:@"发送失败"];
                                  }];
    
    }
    
    
    
    // 先隐藏键盘，再dismiss
    [_textView endEditing:YES];
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
    
}

#pragma mark - textView代理方法
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {

    // 先判断本地是否存有已经编辑过的状态
    if ([textView.text isEqualToString:@"记录我的生活"]) {
        textView.text = @"";
    }
    
    return YES;

}

- (void)textViewDidChange:(UITextView *)textView {
    if ([textView.text isEmpty]) {
        self.navigationItem.rightBarButtonItem.enabled = NO;
    } else {
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
    if (textView.textColor != [UIColor blackColor]) {
        textView.textColor = [UIColor blackColor];
    }
    
    
}

#pragma mark - scrollView代理方法
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    
    [_textView endEditing:YES];

}

#pragma mark - 表视图代理方法
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
                                                   reuseIdentifier:@"cellID"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (indexPath.section == 0 && indexPath.row == 0) {
        [cell setSeparatorInset:UIEdgeInsetsMake(0, 15, 0, 0)];
        
        if (_type == CYC_TEXT) {
            _textView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kTextViewHeightA)];
        } else {
            _textView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kTextViewHeightB)];
        }
        _textView.text = @"记录我的生活";
        _textView.font = [UIFont systemFontOfSize:17];
        _textView.textColor = [UIColor lightGrayColor];
        _textView.delegate = self;
        [cell.contentView addSubview:_textView];
        
        // 选取的图片或视频预览
        if (_type == CYC_IMAGE) {
            if (_imageArray.count == 9) {
                // 没有+
                for (int i = 0; i < _imageArray.count; i++) {
                    CImageView *imageView = [[CImageView alloc] initWithFrame:CGRectMake(15 + (kImageSize + 10)*(i%4),
                                                                                           kTextViewHeightB + 10 + (kImageSize + 10)*(i/4),
                                                                                           kImageSize, kImageSize)];
                    imageView.image = _imageArray[i];
                    imageView.contentMode = UIViewContentModeScaleAspectFill;
                    imageView.clipsToBounds = YES;
                    imageView.imageID = [NSString stringWithFormat:@"%d", i];
                    imageView.delegate = self;
                    [cell.contentView addSubview:imageView];
                }
            } else {
                // 有+
                for (int i = 0; i < _imageArray.count+1; i++) {
                    CImageView *imageView = [[CImageView alloc] initWithFrame:CGRectMake(15 + (kImageSize + 10)*(i%4),
                                                                                           kTextViewHeightB + 10 + (kImageSize + 10)*(i/4),
                                                                                           kImageSize, kImageSize)];
                    // 特别的，+ 的ID是10
                    if (i == _imageArray.count) {
                        imageView.image = [UIImage imageNamed:@"icon_add-pic"];
                        imageView.imageID = [NSString stringWithFormat:@"%d", 10];
                    } else {
                        imageView.image = _imageArray[i];
                        imageView.imageID = [NSString stringWithFormat:@"%d", i];
                    }
                    imageView.contentMode = UIViewContentModeScaleAspectFill;
                    imageView.clipsToBounds = YES;
                    imageView.delegate = self;
                    [cell.contentView addSubview:imageView];
                    
                }
            }
            
        } else if (_type == CYC_MOVIE) {
            // 把分割线移到另一边，重新创作
            [cell setSeparatorInset:UIEdgeInsetsMake(0, 600, 0, 0)];
            CALayer *lineLayer = [[CALayer alloc] init];
            lineLayer.frame = CGRectMake(15, _firstCellHeight-0.5, 600, 0.5);
            lineLayer.backgroundColor = [UIColor colorWithRed:179/255.0
                                                        green:179/255.0
                                                         blue:179/255.0
                                                        alpha:1].CGColor;
            [cell.contentView.layer addSublayer:lineLayer];
            
            // 创建视频预览层
            self.playerItem = [AVPlayerItem playerItemWithURL:_movieUrl];
            self.player = [[AVPlayer alloc] initWithPlayerItem:_playerItem];
            self.playerLayer = [[CPlayerLayer alloc] initWithFrame:CGRectMake(15, kTextViewHeightB + 10,
                                                                              kImageSize, kImageSize)];
            self.playerLayer.player = _player;
            [cell.contentView addSubview:_playerLayer];
            [_player play];
            // 点击了播放器
            __weak SendMomentsController *weakSelf = self;
            self.playerLayer.touchPlayer = ^() {
                
                [[UIApplication sharedApplication].keyWindow endEditing:YES];
                
                // 如果已经全屏，那么缩小
                if (weakSelf.isPlayerFull) {
                    [UIView animateWithDuration:.35
                                     animations:^{
                                         
                                         weakSelf.playerLayer.frame = CGRectMake(15, kTextViewHeightB + 10,
                                                                                 kImageSize, kImageSize);
                                         [cell.contentView addSubview:weakSelf.playerLayer];
                                     }];
                } else {
                // 如果还未全屏，那么全屏显示
                    [UIView animateWithDuration:.35
                                     animations:^{
                                         weakSelf.playerLayer.frame = [UIScreen mainScreen].bounds;
                                         [[UIApplication sharedApplication].keyWindow addSubview:weakSelf.playerLayer];
                                     }];
                }
                
                _isPlayerFull = !_isPlayerFull;
            };
            // 添加视频播放结束通知
            [[NSNotificationCenter defaultCenter]addObserver:self
                                                    selector:@selector(moviePlayDidEnd:)
                                                        name:AVPlayerItemDidPlayToEndTimeNotification
                                                      object:_playerItem];
            
        }
        
    } else if (indexPath.section == 0 && indexPath.row == 1) {
        [cell setSeparatorInset:UIEdgeInsetsMake(0, 0, 0, 0)];
        cell.imageView.image = [UIImage imageNamed:@"icon_location"];
        cell.textLabel.text = @"所在位置";
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    } else if (indexPath.section == 1 && indexPath.row == 0) {
        [cell setSeparatorInset:UIEdgeInsetsMake(0, 15, 0, 0)];
        cell.imageView.image = [UIImage imageNamed:@"icon_open"];
        cell.textLabel.text = @"谁可以看";
        cell.detailTextLabel.text = @"公开";
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    } else if (indexPath.section == 1 && indexPath.row == 1) {
        [cell setSeparatorInset:UIEdgeInsetsMake(0, 0, 0, 0)];
        cell.imageView.image = [UIImage imageNamed:@"icon_@"];
        cell.textLabel.text = @"提醒谁看";
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    if (indexPath.row == 0 && indexPath.section == 0) {
        return _firstCellHeight;
    } else {
        return kScreenHeight*.06;
    }

}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    if (indexPath.section == 0 && indexPath.row == 0) {
        return;
    } else if (indexPath.section == 0 && indexPath.row == 1) {
        [self openLocation];
    } else {
        [SVProgressHUD dismiss];
        [SVProgressHUD showErrorWithStatus:@"此功能还没开放呢"];
    }
    
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.0001;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (section == 0) {
        return 15;
    } else {
        return 0.0001;
    }
}




#pragma mark - 监听视频预览结束
- (void)moviePlayDidEnd:(NSNotification *)notification {
    
    __weak typeof(self) weakSelf = self;
    [self.playerLayer.player seekToTime:kCMTimeZero completionHandler:^(BOOL finished) {
        [weakSelf.player play];
    }];
}




#pragma mark - imagePicker代理方法
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {

    // 判断资源的来源摄像头
    if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
        UIImage *image = info[UIImagePickerControllerOriginalImage];
        
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
        [_imageArray insertObject:image atIndex:0];
        
        // 刷新
        [self reloadImageData];
        
    }
    
    [picker dismissViewControllerAnimated:YES completion:^{
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
    }];
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {

    [picker dismissViewControllerAnimated:YES completion:^{
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
    }];

}



#pragma mark - 打开定位界面
- (void)openLocation {

    CLocationShow *pickerLocation = [[CLocationShow alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:pickerLocation];
    nav.navigationBar.translucent = NO;
    nav.navigationBar.barTintColor = [UIColor blackColor];
    [self presentViewController:nav animated:YES completion:nil];
    
    // 接收传过来的地理信息
    pickerLocation.locationBlock = ^(NSString *str){
    
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:1 inSection:0];
        UITableViewCell *cell = [_tableView cellForRowAtIndexPath:indexPath];
        if (str.length > 0) {
            self.locationStr = str;
            NSArray *array = [str componentsSeparatedByString:@"+"];
            // 更改定位按钮的颜色
            // [_locationButton setImage:[UIImage imageNamed:@"icon_position_blue"] forState:UIControlStateNormal];
            cell.textLabel.text = [array firstObject];
            cell.imageView.image = [UIImage imageNamed:@"icon_location_selected"];
        } else {
            cell.textLabel.text = @"不使用定位";
            cell.imageView.image = [UIImage imageNamed:@"icon_location"];
        }
        
    
    };

}

#pragma mark - 点击了图片预览，跳转查看已经选着的image
- (void)cImageViewTouch:(CImageView *)cImageView {
    
    [[UIApplication sharedApplication].keyWindow endEditing:YES];
    
    if ([cImageView.imageID isEqualToString:@"10"]) {
        // 添加照片
        
        // 提示从系统相册添加还是来自摄像头
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"从哪里获取图片?"
                                                                           message:nil
                                                                    preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction *sureAction = [UIAlertAction actionWithTitle:@"拍照"
                                                             style:UIAlertActionStyleDefault
                                                           handler:^(UIAlertAction * _Nonnull action) {
                                                               [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
                                                               UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
                                                               imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
                                                               imagePickerController.delegate = self;
                                                               [self presentViewController:imagePickerController animated:YES completion:nil];

                                                           }];
        UIAlertAction *otherAction = [UIAlertAction actionWithTitle:@"从手机相册选择"
                                                               style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction * _Nonnull action) {
                                                                 // 打开相册
                                                                 LGPhotoPickerViewController *pickerVc = [[LGPhotoPickerViewController alloc] initWithShowType:LGShowImageTypeImagePicker];
                                                                 pickerVc.status = PickerViewShowStatusCameraRoll;
                                                                 pickerVc.maxCount = 9 - _imageArray.count;   // 最多能选的图片数量
                                                                 pickerVc.delegate = self;
                                                                 [pickerVc showPickerVc:self];
                                                             }];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消"
                                                               style:UIAlertActionStyleDefault
                                                             handler:nil];
        [cancelAction setValue:[UIColor redColor] forKey:@"titleTextColor"];
        [alert addAction:sureAction];
        [alert addAction:otherAction];
        [alert addAction:cancelAction];
        [self presentViewController:alert animated:YES completion:nil];
        
    } else {
        // 查看照片
        
        // 转换图片
        NSInteger index = [cImageView.imageID integerValue];
        [self transformImage:index];
        
        // 开启图片浏览器
        LGPhotoPickerBrowserViewController *BroswerVC = [[LGPhotoPickerBrowserViewController alloc] init];
        BroswerVC.delegate = self;
        BroswerVC.dataSource = self;
        BroswerVC.showType = LGShowImageTypeImageBroswer;
        [self presentViewController:BroswerVC animated:YES completion:nil];
        // 前往实现代理方法，传递图片
        
    }
    
}
- (void)cImageViewLongTouch:(CImageView *)cImageView {
    // 长按图片，那就删除
    NSInteger number = [cImageView.imageID integerValue];
    if (number != 10) {
        [_imageArray removeObjectAtIndex:number];
        [self reloadImageData];
    }
    
    
}

#pragma mark - 图片浏览器代理方法
- (NSInteger)photoBrowser:(LGPhotoPickerBrowserViewController *)photoBrowser numberOfItemsInSection:(NSUInteger)section {

    return self.photoArray.count;

}

- (id<LGPhotoPickerBrowserPhoto>)photoBrowser:(LGPhotoPickerBrowserViewController *)pickerBrowser photoAtIndexPath:(NSIndexPath *)indexPath {

    return [self.photoArray objectAtIndex:indexPath.item];

}

#pragma mark - 选取照片成功后回调
- (void)pickerViewControllerDoneAsstes:(NSArray *)assets isOriginal:(BOOL)original {

    for (LGPhotoAssets *photo in assets) {
        //原图
        [_imageArray addObject:photo.originImage];
    }
    // 刷新表视图
    [self reloadImageData];

}

#pragma mark - 根据图片的增删，刷新表视图
- (void)reloadImageData {

    // 重新计算高度
    _firstCellHeight = kTextViewHeightB + (_imageArray.count / 4 + 1)*(kImageSize + 10) + 10;
    _tableView.frame = CGRectMake(0, 0, kScreenWidth, _firstCellHeight + kNormalCellHeight*3 + kSpace);
    [_tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];

}











/*

 被丢弃的代码
 
 
 //    NSString *urlStr = @"http://115.28.6.7/rongyun.php/Home/about/about_publish";
 //    AFHTTPSessionManager *session = [AFHTTPSessionManager manager];
 //    session.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html", nil];
 //    [session POST:urlStr
 //       parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
 //           if (_photo != nil) {   // 图片数据不为空才传递
 //
 //               [formData appendPartWithFileData:_photoData name:@"file" fileName:@"user.jpg" mimeType:@"image/jpg"];
 //           }
 //       } progress:^(NSProgress * _Nonnull uploadProgress) {
 //
 //       } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
 //           [SVProgressHUD dismiss];
 //           [SVProgressHUD showSuccessWithStatus:@"发送成功"];
 //       } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
 //           [SVProgressHUD dismiss];
 //           [SVProgressHUD showSuccessWithStatus:@"发送失败"];
 //       }];

 - (UIImageView *)willPushImageView {
 
 if (_willPushImageView == nil) {
 // 控制位置
 _willPushImageView = [[UIImageView alloc] initWithFrame:CGRectMake((kScreenWidth - 240)/2.0, kScreenHeight-240, 240, 240)];
 _willPushImageView.contentMode = UIViewContentModeScaleAspectFit;
 _willPushImageView.userInteractionEnabled = YES;
 [self.view addSubview:_willPushImageView];
 
 // 给图片添加点击手势，点击图片后将图片删除
 UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(deleteImage:)];
 tap.numberOfTapsRequired = 2;
 [_willPushImageView addGestureRecognizer:tap];
 
 // 提示双指点击可删除
 NSString *result = [USER_D objectForKey:@"双击图片可删除"];
 if (result == nil) {
 [SVProgressHUD dismiss];
 [SVProgressHUD showSuccessWithStatus:@"双击图片可删除"];
 [USER_D setObject:@"已经提示过" forKey:@"双击图片可删除"];
 }
 
 }
 return _willPushImageView;
 
 }
 
 
 //    //关闭,返回
 //    [picker dismissViewControllerAnimated:YES completion:^{
 //        [SVProgressHUD dismiss];
 //        [SVProgressHUD showSuccessWithStatus:@"添加图片成功"];
 //    }];

 #pragma mark - 隐藏状态栏
 - (BOOL)prefersStatusBarHidden {
 
 //    if (_hideStatus == YES) {
 //        _hideStatus = NO;
 //        return NO;
 //    } else {
 //        _hideStatus = YES;
 //        return YES;
 //    }
 
 return YES;
 
 }
 
 //        NSString *urlStr = @"http://115.28.6.7/rongyun.php/Home/about/about_publish";
 //        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
 //        [request setHTTPMethod:@"POST"];
 //        NSString *bodyString = [NSString stringWithFormat:@"user_id=%@&content=%@", [USER_D objectForKey:@"user_id"], _textView.text];
 //        NSData *bodyData = [bodyString dataUsingEncoding:NSUTF8StringEncoding];
 //        [request setHTTPBody:bodyData];
 //        NSURLSession *session = [NSURLSession sharedSession];
 //        NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
 //            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
 //            NSLog(@"%@", httpResponse);
 //        }];
 //        [task resume];

 //    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
 //    imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
 //    imagePickerController.delegate = self;
 //
 //    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
 //
 //    [self presentViewController:imagePickerController animated:YES completion:nil];

 - (instancetype)initWithImage:(UIImage *)image {
 
 self = [super init];
 if (self != nil) {
 
 self.imageWillPush.image = image;
 _imageWillPush.imageNum = 1;
 
 [self.willPushPhotoArr addObject:image];
 
 }
 return self;
 
 }

 // 传入一张图片以初始化
 - (instancetype)initWithImage:(UIImage *)image;
 
 //    else if (indexPath.row == 4) {
 //        cell.selectionStyle = UITableViewCellSelectionStyleNone;
 //        cell.backgroundColor = [UIColor colorWithRed:238/255.0 green:238/255.0 blue:238/255.0 alpha:1];
 //        NSArray *array = @[@"icon_emoj", @"icon_album", @"icon_camera_b", @"icon_position"];
 //        float buttonWidth = kScreenWidth/4;
 //        for (int i = 0; i < 4; i++) {
 //            UIImage *image = [UIImage imageNamed:array[i]];
 //            float imageHeight = image.size.height;
 //            float imageWidth = image.size.width;
 //            UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(buttonWidth*i + (buttonWidth - imageWidth)/2.0, (kScreenHeight*.06 - imageHeight)/2.0, imageWidth, imageHeight)];
 //            button.tag = 989 + i;
 //            [button addTarget:self action:@selector(moreOptionButtonAction:) forControlEvents:UIControlEventTouchUpInside];
 //            [button setImage:image forState:UIControlStateNormal];
 //            [cell.contentView addSubview:button];
 //            [cell setSeparatorInset:UIEdgeInsetsMake(0, 0, 0, 0)];
 //        }
 //    }

 
 #pragma mark - 输入框下面按钮的点击响应
 - (void)moreOptionButtonAction:(UIButton *)button {
 
 NSInteger num = button.tag - 989;
 if (num == 0) {
 // 打开表情输入
 [self openEmojiInput];
 } else if (num == 1) {
 // 打开系统相册
 [self openSystemPicture];
 } else if (num == 2) {
 //        [self presentViewController:[[FromCameraController alloc] init]
 //                           animated:YES
 //                         completion:nil];
 // 打开摄像头
 [self openSystemCamare];
 } else if (num == 3) {
 _locationButton = button;
 [self openLocation];
 }
 
 }
 
 #pragma mark - RCEmojiViewDelegate表情输入框代理方法
 
 点击表情的回调
 
 @param emojiView 表情输入的View
 @param string    点击的表情对应的字符串编码
 
- (void)didTouchEmojiView:(RCEmojiBoardView *)emojiView touchedEmoji:(NSString *)string{
    
    if ([_textView.text isEqualToString:@"记录我的生活"]) {
        _textView.text = @"";
    }
    
    // 表情输入板的删除按钮，没有相应的协议方法，只能根据输入的是否未空，来判断当前输入的是否未删除按钮
    // 删除按钮不做任何操作,因为有些表情是2bit，有的是1bit
    if (string != nil) {
        // 将表情转换成字符串
        // NSString *str = [string stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        _textView.text = [_textView.text stringByAppendingString:string];
    }
    
    // 表情 》》》字符串
    // NSString *stri = [string stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    // 字符串 》》》表情
    // NSString *str = [stri stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
}

- (void)didSendButtonEvent:(RCEmojiBoardView *)emojiView sendButton:(UIButton *)sendButton {
    
    // 当点击发送按钮时，将表情面板隐藏
    [UIView animateWithDuration:.35
                     animations:^{
                         emojiView.alpha = 0;
                     } completion:^(BOOL finished) {
                         [emojiView removeFromSuperview];
                     }];
    emojiView = nil;
}
 
 #pragma mark - 打开表情输入
 - (void)openEmojiInput {
 
 if (_emojiInputView == nil) {
 [_textView endEditing:YES];
 _emojiInputView = [[RCEmojiBoardView alloc] initWithFrame:CGRectMake(0,
 kScreenHeight*.48,
 kScreenWidth,
 223)];
 // 设置表情的协议代理方法
 _emojiInputView.delegate = self;
 _emojiInputView.alpha = 0;
 [_emojiInputView enableSendButton:YES];
 [_backgroundView addSubview:_emojiInputView];
 [UIView animateWithDuration:.35
 animations:^{
 _emojiInputView.alpha = 1;
 }];
 
 } else {
 // 如果不从父视图移除的话，会内存泄露，不断创建_emojiInputView
 [UIView animateWithDuration:.35
 animations:^{
 _emojiInputView.alpha = 0;
 } completion:^(BOOL finished) {
 [_emojiInputView removeFromSuperview];
 }];
 _emojiInputView = nil;
 }
 
 }

 //    // 开始编辑文字输入框的时候就把表情面板隐藏掉
 //    if (_emojiInputView != nil) {
 //        [UIView animateWithDuration:.35
 //                         animations:^{
 //                             _emojiInputView.alpha = 0;
 //                         } completion:^(BOOL finished) {
 //                             [_emojiInputView removeFromSuperview];
 //                         }];
 //        _emojiInputView = nil;
 //    }

 - (CImageView *)imageWillPush {
 
 if (_imageWillPush == nil) {
 _imageWillPush = [[CImageView alloc] initWithFrame:CGRectMake(kScreenWidth - 40 - 8, 19.5, 40, 40)];
 _imageWillPush.contentMode = UIViewContentModeScaleAspectFill;
 _imageWillPush.clipsToBounds = YES;
 _imageWillPush.delegate = self;
 // 将提示的图片添加到输入框的父视图，而不是添加到输入框（添加到输入框的话，输入框字数过多，图片会被顶出屏幕）
 [_textView.superview addSubview:_imageWillPush];
 }
 return _imageWillPush;
 
 }

 // 首次创建，重置图片筛选
 [SuPhotoCenter shareCenter].reset = YES;
 
 @property (strong, nonatomic) CImageView *imageWillPush;    // 显示即将上传的图片
 //完成选择后的操作
 self.willPushPhotoArr = [NSMutableArray arrayWithArray:photos];
 self.imageWillPush.image = photos.firstObject;
 self.imageWillPush.imageNum = photos.count;
 
 [self.willPushPhotoArr addObject:image];
 self.imageWillPush.image = image;
 self.imageWillPush.imageNum += 1;
 
 self.imageWillPush.image = image;
 _imageWillPush.imageNum = 1;
 
 [self.willPushPhotoArr addObject:image];
 
 - (NSMutableArray *)willPushPhotoArr {
 
 if (_willPushPhotoArr == nil) {
 _willPushPhotoArr = [NSMutableArray array];
 }
 return _willPushPhotoArr;
 
 }
 
 #pragma mark - 打开系统相册选区照片
 - (void)openSystemPicture {
 
 // 收起键盘
 [[UIApplication sharedApplication].keyWindow endEditing:YES];
 
 SuPhotoPicker * picker = [[SuPhotoPicker alloc]init];
 //最大选择图片的数量以及最大快速预览图片的数量，默认为20
 picker.selectedCount = 9;
 picker.preViewCount = 20;
 //现在在界面上
 [picker showInSender:self handle:^(NSArray<UIImage *> *photos) {
 
 }];
 
 
 }
 
 
 #pragma mark - 打开摄像头
 - (void)openSystemCamare {
 
 FromCameraController *fromCamera = [[FromCameraController alloc] init];
 [self presentViewController:fromCamera animated:YES completion:nil];
 
 fromCamera.imageBlock = ^(id pagram) {
 
 if ([pagram isKindOfClass:[UIImage class]]) {
 UIImage *image = (UIImage *)pagram;
 // 接收image
 
 } else if ([pagram isKindOfClass:[NSURL class]]) {
 NSURL *url = (NSURL *)pagram;
 
 }
 
 
 
 };
 
 
 
 }
 
 
 */

@end
