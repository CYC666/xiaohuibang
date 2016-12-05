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
#import "NSString+Extension.h"
#import "CLocationController.h"
#import "FromCameraController.h"
#import <SVProgressHUD.h>
#import "SuPhotoPicker.h"
#import "SuPhotoPreviewer.h"

#define kScreenWidth [UIScreen mainScreen].bounds.size.width    // 屏宽
#define kScreenHeight [UIScreen mainScreen].bounds.size.height  // 屏高


@interface SendMomentsController () <UITextViewDelegate, UIScrollViewDelegate,
                                    UITableViewDelegate, UITableViewDataSource,
                        UIImagePickerControllerDelegate, UINavigationControllerDelegate,
                                    RCEmojiViewDelegate, CImageViewDelegate> {

    UITableView *_tableView;
    UITextView *_textView;              // 输入框
    RCEmojiBoardView *_emojiInputView;  // 表情输入框
    NSData *_photoData;                 // 等待上传的图片数据

}
@property (strong, nonatomic) CImageView *imageWillPush;    // 显示即将上传的图片


@end

@implementation SendMomentsController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 创建子视图
    [self _createSubView];
    [self _setNavigationBar];
    
    
    
    
}

- (instancetype)initWithImage:(UIImage *)image {

    self = [super init];
    if (self != nil) {
        self.willPushPhoto = image;
        self.imageWillPush.image = image;
        _imageWillPush.imageNum = 1;
        
    }
    return self;

}

- (void)viewDidAppear:(BOOL)animated {

    [super viewDidAppear:animated];
    
    _scrollView.delegate = self;

}



#pragma mark - 懒加载
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

- (NSMutableArray *)willPushPhotoArr {

    if (_willPushPhotoArr == nil) {
        _willPushPhotoArr = [NSMutableArray array];
    }
    return _willPushPhotoArr;

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

    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight*.48)
                                              style:UITableViewStylePlain];
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
    [self dismissViewControllerAnimated:YES completion:^{
        // 缓存动态编辑的状态
    }];
    
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
    
    // 判断是否含有表情
    if ([NSString stringContainsEmoji:_textView.text]) {
        [SVProgressHUD dismiss];
        [SVProgressHUD showErrorWithStatus:@"暂不支持表情"];
        return;
    }

    // 发表动态
    _photoData = UIImageJPEGRepresentation(_willPushPhoto, 0.75);
    NSDictionary *params = @{@"user_id" : [USER_D objectForKey:@"user_id"],
                             @"content" : _textView.text,
                             @"file" : _willPushPhoto == nil ? @"" : _willPushPhoto};
    
    
    if (_willPushPhoto != nil) {
        [CNetTool postAboutWithParameters:params
                                     data:_photoData
                                  success:^(id response) {
                                      [SVProgressHUD dismiss];
                                      [SVProgressHUD showSuccessWithStatus:@"发送成功"];
                                  } failure:^(NSError *err) {
                                      [SVProgressHUD dismiss];
                                      [SVProgressHUD showErrorWithStatus:@"发送失败"];
                                  }];
    } else {
    
        [CNetTool postAboutWithParameters:params
                                  success:^(id response) {
                                      [SVProgressHUD dismiss];
                                      [SVProgressHUD showSuccessWithStatus:@"发送成功"];
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
    
    // 开始编辑文字输入框的时候就把表情面板隐藏掉
    if (_emojiInputView != nil) {
        [UIView animateWithDuration:.35
                         animations:^{
                             _emojiInputView.alpha = 0;
                         } completion:^(BOOL finished) {
                             [_emojiInputView removeFromSuperview];
                         }];
        _emojiInputView = nil;
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
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return 4;

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
                                                   reuseIdentifier:@"cellID"];
    if (indexPath.row == 0) {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell setSeparatorInset:UIEdgeInsetsMake(0, 0, 0, 0)];
        
        _textView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth - 62.5, kScreenHeight*.3)];
        _textView.text = @"记录我的生活";
        _textView.font = [UIFont systemFontOfSize:17];
        _textView.textColor = [UIColor lightGrayColor];
        _textView.delegate = self;
        [cell.contentView addSubview:_textView];
    } else if (indexPath.row == 1) {
        [cell setSeparatorInset:UIEdgeInsetsMake(0, 10, 0, 0)];
        cell.imageView.image = [UIImage imageNamed:@"icon_open"];
        cell.textLabel.text = @"谁可以看";
        cell.detailTextLabel.text = @"公开";
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    } else if (indexPath.row == 2) {
        [cell setSeparatorInset:UIEdgeInsetsMake(0, 0, 0, 0)];
        cell.imageView.image = [UIImage imageNamed:@"icon_@"];
        cell.textLabel.text = @"提醒谁看";
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    } else if (indexPath.row == 3) {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor colorWithRed:238/255.0 green:238/255.0 blue:238/255.0 alpha:1];
        NSArray *array = @[@"icon_emoj", @"icon_album", @"icon_camera_b", @"icon_position"];
        float buttonWidth = kScreenWidth/4;
        for (int i = 0; i < 4; i++) {
            UIImage *image = [UIImage imageNamed:array[i]];
            float imageHeight = image.size.height;
            float imageWidth = image.size.width;
            UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(buttonWidth*i + (buttonWidth - imageWidth)/2.0, (kScreenHeight*.06 - imageHeight)/2.0, imageWidth, imageHeight)];
            button.tag = 989 + i;
            [button addTarget:self action:@selector(moreOptionButtonAction:) forControlEvents:UIControlEventTouchUpInside];
            [button setImage:image forState:UIControlStateNormal];
            [cell.contentView addSubview:button];
            [cell setSeparatorInset:UIEdgeInsetsMake(0, 0, 0, 0)];
        }
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    if (indexPath.row == 0) {
        return kScreenHeight*.3;
    } else {
        return kScreenHeight*.06;
    }

}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    if (indexPath.row == 0 || indexPath.row == 1 || indexPath.row == 2) {
        [SVProgressHUD dismiss];
        [SVProgressHUD showErrorWithStatus:@"此功能还没开放呢"];
    }
    
}


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
        [self openLocation];
    }

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
        NSLog(@"%@", _emojiInputView);
        
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

#pragma mark - 打开系统相册选区照片
- (void)openSystemPicture {

    SuPhotoPicker * picker = [[SuPhotoPicker alloc]init];
    //最大选择图片的数量以及最大快速预览图片的数量，默认为20
    picker.selectedCount = 9;
    picker.preViewCount = 20;
    //现在在界面上
    [picker showInSender:self handle:^(NSArray<UIImage *> *photos) {
        //完成选择后的操作
        self.willPushPhotoArr = [NSMutableArray arrayWithArray:photos];
        self.imageWillPush.image = photos.firstObject;
        self.imageWillPush.imageNum = photos.count;
    }];
    
    
}

#pragma mark - 打开摄像头
- (void)openSystemCamare {

    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
    imagePickerController.delegate = self;
    [self presentViewController:imagePickerController animated:YES completion:nil];

}

#pragma mark - imagePicker代理方法
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {

    // 判断资源的来源 相册||摄像头
    if (picker.sourceType == UIImagePickerControllerSourceTypePhotoLibrary || picker.sourceType == UIImagePickerControllerSourceTypeSavedPhotosAlbum) {
        // 取出照片
        UIImage *image = info[UIImagePickerControllerOriginalImage];
        
        self.imageWillPush.image = image;
        _imageWillPush.imageNum = 1;
        self.willPushPhoto = image;
        
    } else if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
        UIImage *image = info[UIImagePickerControllerOriginalImage];
        
        self.imageWillPush.image = image;
        _imageWillPush.imageNum = 1;
        self.willPushPhoto = image;
    }
    
    //关闭,返回
    [picker dismissViewControllerAnimated:YES completion:^{
        [SVProgressHUD dismiss];
        [SVProgressHUD showSuccessWithStatus:@"添加图片成功"];
    }];
}

#pragma mark - RCEmojiViewDelegate表情输入框代理方法
/*!
 点击表情的回调
 
 @param emojiView 表情输入的View
 @param string    点击的表情对应的字符串编码
 */
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


#pragma mark - 打开定位界面
- (void)openLocation {

    CLocationController *locationCtrl = [[CLocationController alloc] init];
    [self.navigationController pushViewController:locationCtrl animated:YES];

}
#pragma mark - 删除即将上传的照片
- (void)deleteImage:(UITapGestureRecognizer *)tap {


    
}

#pragma mark - 点击了图片预览，跳转查看已经选着的image
- (void)cImageViewTouch:(CImageView *)cImageView {

//    SuPhotoPreviewer * previewer = [[SuPhotoPreviewer alloc]init];
//    previewer.isPreviewSelectedPhotos = YES;
//    previewer.previewPhotos = self.willPushPhotoArr;
//    [self.navigationController pushViewController:previewer animated:YES];

    for (UIImage *image in self.willPushPhotoArr) {
        NSLog(@"%@", image);
    }
    
}












- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
 
 //    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
 //    imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
 //    imagePickerController.delegate = self;
 //    [self presentViewController:imagePickerController animated:YES completion:nil];

 
 */

@end
