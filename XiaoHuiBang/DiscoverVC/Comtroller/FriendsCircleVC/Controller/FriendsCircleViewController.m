//
//  FriendsCircleViewController.m
//  XiaoHuiBang
//
//  Created by 消汇邦 on 2016/11/4.
//  Copyright © 2016年 消汇邦. All rights reserved.
//

#import "FriendsCircleViewController.h"
#import "SeeModel.h"
#import "CRefresh.h"
#import "CNetTool.h"
#import "SeeLayout.h"
#import "PraiseModel.h"
#import "AveluateModel.h"
#import "FromCameraController.h"
#import "SendMomentsController.h"
#import "FromCamera.h"
#import <UIImageView+WebCache.h>
#import <FMDB.h>
#import "LGPhoto.h"







#define kScreenHeight [UIScreen mainScreen].bounds.size.height                          // 屏高
#define kScreenWidth [UIScreen mainScreen].bounds.size.width                            // 屏宽
#define NotigicationOfSelfTranslucent @"NotigicationOfSelfTranslucent"                  // 修改导航栏不透明的通知
#define openSendCommentControllerNotification @"openSendCommentControllerNotification"  // 发送打开发送动态界面的通知
#define reloadSeeDate @"reloadSeeDate"                                                  // 刷新动态数据的通知
#define HideCommentView @"HideCommentView"                                              // 发送隐藏评论点赞框的通知

@interface FriendsCircleViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate,     LGPhotoPickerViewControllerDelegate>

@property (strong, nonatomic) NSMutableArray *seeModelList;      // 储存动态的数组
@property (assign, nonatomic) NSInteger dataTag;                 // 标志上拉加载下拉刷新
@property (assign, nonatomic) NSInteger dataPage;                // 记录加载页数

@end

@implementation FriendsCircleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 默认加载页数为1
    _dataTag = 1;
    
    self.navigationController.navigationBar.translucent = NO;
    // 监听修改导航栏透明的通知
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(notigicationOfSelfTranslucent:)
                                                 name:NotigicationOfSelfTranslucent
                                               object:nil];
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
    backItem.title = @"邦友圈";
    self.navigationItem.backBarButtonItem = backItem;
    
    self.view.backgroundColor = [UIColor colorWithRed:238/255.0 green:238/255.0 blue:238/255.0 alpha:1];
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 40)];
    title.text = @"邦友圈";
    title.font = [UIFont boldSystemFontOfSize:19];
    title.textAlignment = NSTextAlignmentCenter;
    title.textColor = [UIColor whiteColor];
    self.navigationItem.titleView = title;
    
    // 发布动态按钮
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, 40, 40);
    [button setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, -20)];
    [button setImage:[UIImage imageNamed:@"icon_camera"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(sendMomentsAction:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *sendMomentsButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    [self.navigationItem setRightBarButtonItem:sendMomentsButton];
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                                                            action:@selector(jumpToSendAbout:)];
    [button addGestureRecognizer:longPress];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    // 加载动态数据
    [self reloadSeeData];
    
    // 监听打开发送动态界面的通知
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveOpenSendCommentControllerNotification:)
                                                 name:openSendCommentControllerNotification
                                               object:nil];
    // 监听刷新数据的通知
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadSeeData)
                                                 name:reloadSeeDate
                                               object:nil];
}

// 等视图都出现了再添加上拉加载下拉刷新的功能
- (void)viewDidAppear:(BOOL)animated {

    // 创建一个若引用的self在block中调用方法，防止循环引用
    __weak FriendsCircleViewController *weakSelf = self;
    [self.seeTableView addPullDownRefreshBlock:^{
        @synchronized (weakSelf) {
            // 下拉刷新
            [weakSelf reloadSeeData];
        }
        
    }];
    
    [self.seeTableView addInfiniteScrollingWithActionHandler:^{
        @synchronized (weakSelf) {
            // 上拉加载
            [weakSelf downloadData];
        }
    }];

}

- (void)viewWillDisappear:(BOOL)animated {

    // 发送通知，收起点赞框
    [[NSNotificationCenter defaultCenter] postNotificationName:HideCommentView object:nil];

}

#pragma mark - 懒加载
- (SeeTableView *)seeTableView {

    if (_seeTableView == nil) {
        _seeTableView = [[SeeTableView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight-64)
                                                      style:UITableViewStyleGrouped];
        _seeTableView.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:_seeTableView];
    }
    return _seeTableView;

}
- (NSMutableArray *)seeModelList {

    if (_seeModelList == nil) {
        _seeModelList = [NSMutableArray array];
    }
    return _seeModelList;

}




#pragma mark - 导航栏发布动态按钮
- (void)sendMomentsAction:(UIButton *)button {
    
    // 做缩小动画
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
    [UIView animateWithDuration:.2
                     animations:^{
                         self.view.transform = CGAffineTransformMakeScale(0.85, 0.85);
                         self.navigationController.navigationBar.alpha = 0;
                     } completion:^(BOOL finished) {
                         [UIView animateWithDuration:.1
                                          animations:^{
                                              self.view.transform = CGAffineTransformMakeScale(.9, .9);
                                          }];
                     }];
    
    UIView *virtualView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    virtualView.backgroundColor = [UIColor colorWithWhite:0 alpha:.3];
    [self.view.window addSubview:virtualView];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
    [virtualView addGestureRecognizer:tap];

    // 创建选项view，提供功能选着
    float alertHeight = kScreenHeight*.25;
    UIView *alertView = [[UIView alloc] initWithFrame:CGRectMake(0,kScreenHeight , kScreenWidth, alertHeight)];
    alertView.backgroundColor = [UIColor colorWithRed:229/255.0 green:229/255.0 blue:229/255.0 alpha:1];
    alertView.tag = 1001;
    [virtualView addSubview:alertView];
    
    [UIView animateWithDuration:.35
                     animations:^{
                         alertView.transform = CGAffineTransformMakeTranslation(0, -alertHeight);
                     }];
    
    float buttonHeight = (alertHeight - 10)/3.0;
    NSArray *titleArr = @[@"拍摄", @"从手机相册选择", @"取消"];
    for (int i = 0; i < titleArr.count; i++) {
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setTitle:titleArr[i] forState:UIControlStateNormal];
        [button setBackgroundColor:[UIColor whiteColor]];
        [button setBackgroundImage:[self createImageWithColor:[UIColor colorWithRed:221/255.0 green:221/255.0 blue:221/255.0 alpha:1]] forState:UIControlStateHighlighted];
        [button setTitleColor:[UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1]
                     forState:UIControlStateNormal];
        if (i == 0) {
            button.frame = CGRectMake(0, 0, kScreenWidth, buttonHeight+10);
        } else if (i == 1) {
            button.frame = CGRectMake(0, buttonHeight + 10 + 1, kScreenWidth, buttonHeight-5);
        } else {
            button.frame = CGRectMake(0, alertHeight - buttonHeight + 5, kScreenWidth, buttonHeight-5);
        }
        [alertView addSubview:button];
        if (i == 0) {
            button.titleLabel.font = [UIFont systemFontOfSize:19];
            [button setTitleEdgeInsets:UIEdgeInsetsMake(-15, 0, 0, 0)];
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, button.frame.size.width, button.frame.size.height-20)];
            label.text = @"照片或视频";
            label.font = [UIFont systemFontOfSize:12];
            label.textColor = [UIColor lightGrayColor];
            label.textAlignment = NSTextAlignmentCenter;
            [alertView addSubview:label];
        } else {
            button.titleLabel.font = [UIFont systemFontOfSize:15];
        }
        [button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
        
    }

}

// alert背景点击手势，移除alert
- (void)tapAction:(UITapGestureRecognizer *)tap {

    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
    [UIView animateWithDuration:.35
                     animations:^{
                         self.navigationController.navigationBar.alpha = 1;
                         self.view.transform = CGAffineTransformIdentity;
                         [tap.view viewWithTag:1001].transform = CGAffineTransformMakeTranslation(0, kScreenHeight*.25);
                     } completion:^(BOOL finished) {
                         [tap.view removeFromSuperview];
                     }];
}

// alert按钮响应
- (void)buttonAction:(UIButton *)button {

    if ([button.titleLabel.text isEqualToString:@"拍摄"]) {
        
        FromCameraController *fromCamera = [[FromCameraController alloc] init];
        [self presentViewController:fromCamera animated:YES completion:nil];
        
        fromCamera.imageBlock = ^(id pagram) {
            
            if ([pagram isKindOfClass:[UIImage class]]) {
                UIImage *image = (UIImage *)pagram;
                SendMomentsController *sendController = [[SendMomentsController alloc] initWithImageArray:[NSArray arrayWithObject:image]];
                UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:sendController];
                nav.navigationBar.barTintColor = [UIColor colorWithRed:42.0/255.0 green:42.0/255.0 blue:48.0/255.0 alpha:1.0];
                [self presentViewController:nav animated:YES completion:nil];
                
                
                
            } else if ([pagram isKindOfClass:[NSURL class]]) {
                NSURL *url = (NSURL *)pagram;
                SendMomentsController *sendController = [[SendMomentsController alloc] initWithMovie:url];
                UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:sendController];
                nav.navigationBar.barTintColor = [UIColor colorWithRed:42.0/255.0 green:42.0/255.0 blue:48.0/255.0 alpha:1.0];
                [self presentViewController:nav animated:YES completion:nil];
            }
            
            
            
        };

        
        
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
        // 移除alert
        [UIView animateWithDuration:.35
                         animations:^{
                             [button.superview.superview viewWithTag:1001].transform = CGAffineTransformMakeTranslation(0, kScreenHeight*.25);
                             self.navigationController.navigationBar.alpha = 1;
                             self.view.transform = CGAffineTransformIdentity;
                             self.navigationController.navigationBar.transform = CGAffineTransformIdentity;
                         } completion:^(BOOL finished) {
                             [button.superview.superview removeFromSuperview];
                         }];

    } else if ([button.titleLabel.text isEqualToString:@"从手机相册选择"]) {
        
        // 打开相册
        LGPhotoPickerViewController *pickerVc = [[LGPhotoPickerViewController alloc] initWithShowType:LGShowImageTypeImagePicker];
        pickerVc.status = PickerViewShowStatusCameraRoll;
        pickerVc.maxCount = 9;   // 最多能选9张图片
        pickerVc.delegate = self;
        [pickerVc showPickerVc:self];
        
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
        // 移除alert
        [UIView animateWithDuration:.35
                         animations:^{
                             [button.superview.superview viewWithTag:1001].transform = CGAffineTransformMakeTranslation(0, kScreenHeight*.25);
                             self.navigationController.navigationBar.alpha = 1;
                             self.view.transform = CGAffineTransformIdentity;
                             self.navigationController.navigationBar.transform = CGAffineTransformIdentity;
                         } completion:^(BOOL finished) {
                             [button.superview.superview removeFromSuperview];
                         }];
        
    } else {
        
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
        // 移除alert
        [UIView animateWithDuration:.35
                         animations:^{
                             [button.superview.superview viewWithTag:1001].transform = CGAffineTransformMakeTranslation(0, kScreenHeight*.25);
                             self.navigationController.navigationBar.alpha = 1;
                             self.view.transform = CGAffineTransformIdentity;
                             self.navigationController.navigationBar.transform = CGAffineTransformIdentity;
                         } completion:^(BOOL finished) {
                             [button.superview.superview removeFromSuperview];
                         }];
    }
}

#pragma mark - 跳转到发图片动态界面
- (void)pickerViewControllerDoneAsstes:(NSArray *)assets isOriginal:(BOOL)original {

    NSMutableArray *originImage = [NSMutableArray array];
    
    for (LGPhotoAssets *photo in assets) {
        //原图
        [originImage addObject:photo.originImage];
    }
    
    // 延迟一点时间，让所有模态控制器都消失了，再弹出发送动态的模态控制器
    [self performSelector:@selector(presentToSendCotroller:) withObject:originImage afterDelay:1];
    
}

- (void)presentToSendCotroller:(NSArray *)array {

    // 跳转
    SendMomentsController *sendController = [[SendMomentsController alloc] initWithImageArray:array];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:sendController];
    nav.navigationBar.barTintColor = [UIColor colorWithRed:42.0/255.0 green:42.0/255.0 blue:48.0/255.0 alpha:1.0];
    [self presentViewController:nav animated:YES completion:nil];


}

#pragma mark - 跳转到发送纯文本动态界面
- (void)jumpToSendAbout:(UILongPressGestureRecognizer *)longPress {

    if (longPress.state == UIGestureRecognizerStateBegan) {
        // push到编辑界面
        SendMomentsController *momentsController = [[SendMomentsController alloc] initWithText];
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:momentsController];
        nav.navigationBar.barTintColor = [UIColor colorWithRed:42.0/255.0 green:42.0/255.0 blue:48.0/255.0 alpha:1.0];
        [self presentViewController:nav animated:YES completion:nil];
    }

}

// 颜色转换成image
-(UIImage *)createImageWithColor:(UIColor*) color {
    CGRect rect=CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

#pragma mark - 创建内容视图
- (void)_createContent {
    
    _dataPage = 1;
    _dataTag = 0;

    // 获取动态
    NSDictionary *params = @{@"user_id" : [USER_D objectForKey:@"user_id"],
                             @"page" : [NSString stringWithFormat:@"%ld", _dataPage]
                             };
    
    [CNetTool loadAboutWithParameters:params
                              success:^(id response) {
                                  // 查看是否有动态
                                  NSDictionary *dic = response;
                                  if ([dic[@"msg"]  isEqual: @1]) {
                                      // 在支线程处理数据,加载数据
                                      dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                                          [self loadData:response];
                                      });
                                  } else {
                                      [SVProgressHUD dismiss];
                                      [SVProgressHUD showSuccessWithStatus:@"没有动态"];
                                  }
                              } failure:^(NSError *err) {
                                  [SVProgressHUD dismiss];
                                  [SVProgressHUD showSuccessWithStatus:@"请求失败"];
                              }];
    
   

}


#pragma mark - 首次加载或下拉刷新
- (void)reloadSeeData {
    
    _dataPage = 1;
    _dataTag = 0;
    
    // 获取动态
    NSDictionary *params = @{@"user_id" : [USER_D objectForKey:@"user_id"],
                             @"page" : [NSString stringWithFormat:@"%ld", _dataPage]
                             };
    
    [CNetTool loadAboutWithParameters:params
                              success:^(id response) {
                                  // 查看是否有动态
                                  NSDictionary *dic = response;
                                  
                                  
                                  
                                  
                                  
                                  if ([dic[@"msg"]  isEqual: @1]) {
                                      // 在支线程处理数据,加载数据
                                      dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                                          [self loadData:response];
                                      });
                                  } else {
                                      [SVProgressHUD dismiss];
                                      [SVProgressHUD showSuccessWithStatus:@"没有更多动态"];
                                      // 结束刷新
                                      [self.seeTableView.pullToRefreshView stopAnimating];
                                  }
                              } failure:^(NSError *err) {
                                  [SVProgressHUD dismiss];
                                  [SVProgressHUD showSuccessWithStatus:@"请求失败"];
                                  // 结束刷新
                                  [self.seeTableView.pullToRefreshView stopAnimating];
                              }];
    
    
    
}

#pragma mark - 上拉加载
- (void)downloadData {
    
    _dataPage += 1;
    _dataTag = 1;
    
    // 获取动态
    NSDictionary *params = @{@"user_id" : [USER_D objectForKey:@"user_id"],
                             @"page" : [NSString stringWithFormat:@"%ld", _dataPage]
                             };
    
    [CNetTool loadAboutWithParameters:params
                              success:^(id response) {
                                  // 查看是否有动态
                                  NSDictionary *dic = response;
                                  if ([dic[@"msg"]  isEqual: @1]) {
                                      // 在支线程处理数据,加载数据
                                      dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                                          [self loadData:response];
                                      });
                                  } else {
                                      
                                      [SVProgressHUD dismiss];
                                      [SVProgressHUD showSuccessWithStatus:@"没有更多动态"];
                                      
                                      // 如果没有动态就结束加载，不然会一直加载，导致刷新过后不能加载
                                      [self.seeTableView.infiniteScrollingView stopAnimating];
                                  }
                              } failure:^(NSError *err) {
                                  [SVProgressHUD dismiss];
                                  [SVProgressHUD showSuccessWithStatus:@"请求失败"];
                                  // 请求失败也要停止转动
                                  [self.seeTableView.infiniteScrollingView stopAnimating];
                              }];
    
    
    
}

#pragma mark - 从手机相册选择
- (void)sendFromSystemPicture {

    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePickerController.delegate = self;
    [self presentViewController:imagePickerController animated:YES completion:nil];
    
}

#pragma mark - imagePicker代理方法
//已经选好照片
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    
    //判断资源的来源 相册||摄像头
    if (picker.sourceType == UIImagePickerControllerSourceTypePhotoLibrary ||
        picker.sourceType == UIImagePickerControllerSourceTypeSavedPhotosAlbum) {
        //取出照片
        UIImage *image = info[UIImagePickerControllerOriginalImage];
        //关闭,返回
        [picker dismissViewControllerAnimated:YES completion:^{
            // 发送通知，跳转到发动态界面,将选好的图片发送过去
            [[NSNotificationCenter defaultCenter] postNotificationName:openSendCommentControllerNotification
                                                                object:image];
        }];
    }
    
}

#pragma mark - 接受到打开发送动态界面的通知
- (void)receiveOpenSendCommentControllerNotification:(NSNotification *)notification {
    
//    SendMomentsController *sendController = [[SendMomentsController alloc] initWithImage:notification.object];
//    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:sendController];
//    nav.navigationBar.barTintColor = [UIColor colorWithRed:42.0/255.0 green:42.0/255.0 blue:48.0/255.0 alpha:1.0];
//    [self presentViewController:nav animated:YES completion:nil];

}

#pragma mark - 接收修改导航栏不透明的通知
- (void)notigicationOfSelfTranslucent:(NSNotification *)notification {

    self.navigationController.navigationBar.translucent = NO;

}

#pragma mark - 处理动态数据
- (void)loadData:(id)data {
    
    // 如果是第一次加载数据，或者刷新数据
    if (_dataTag == 0) {
        [self.seeModelList removeAllObjects];
    }
    
    NSArray *dataArr = data[@"data"];
    
    NSMutableArray *seeTempArr = [NSMutableArray array];
    for (NSDictionary *dic in dataArr) {
        SeeModel *seeModel = [[SeeModel alloc] init];
        seeModel.about_id = dic[@"id"];
        seeModel.user_id = dic[@"user_id"];
        seeModel.nickname = dic[@"nickname"];
        seeModel.head_img = dic[@"head_img"];
        seeModel.content = dic[@"content"];
        seeModel.address = dic[@"address"];
        seeModel.lat = dic[@"lat"];
        seeModel.lon = dic[@"lon"];
        seeModel.type = dic[@"type"];
        // 纯文本
        if ([dic[@"type"] isEqualToString:@"1"]) {
            
        }
        // 带图片
        else if ([dic[@"type"] isEqualToString:@"2"]) {
            seeModel.about_img = dic[@"about_img"];
            seeModel.thumb_img = dic[@"thumb_img"];
        }
        // 带视频
        else if ([dic[@"type"] isEqualToString:@"3"]) {
            seeModel.movieThumb = dic[@"jt"];
            seeModel.movie = dic[@"video"];
        }
        seeModel.create_time = dic[@"create_time"];
        
        NSMutableArray *praiseTempArr = [NSMutableArray array];
        for (NSDictionary *praiseDic in dic[@"praise"]) {
            PraiseModel *praiseModel = [[PraiseModel alloc] init];
            praiseModel.nickname = praiseDic[@"nickname"];
            praiseModel.user_id = praiseDic[@"user_id"];
            [praiseTempArr addObject:praiseModel];
        }
        seeModel.praise = praiseTempArr;
        
        NSMutableArray *aveluateTempArr = [NSMutableArray array];
        for (NSDictionary *aveluateDic in dic[@"aveluate"]) {
            AveluateModel *aveluateModel = [[AveluateModel alloc] init];
            aveluateModel.nickname = aveluateDic[@"nickname"];
            aveluateModel.user_id = aveluateDic[@"user_id"];
            aveluateModel.about_content = aveluateDic[@"about_content"];
            aveluateModel.eva_id = aveluateDic[@"eva_id"];
            [aveluateTempArr addObject:aveluateModel];
        }
        seeModel.aveluate = aveluateTempArr;
        
        // 将包含了动态数据和布局对象的模型存到数组中
        SeeLayout *seeLayout = [[SeeLayout alloc] init];
        seeLayout.seeModel = seeModel;
        [seeTempArr addObject:seeLayout];
        
        
    }
    
    // 返回主线程，刷新表视图
    dispatch_sync(dispatch_get_main_queue(), ^{
        
        // 以下内容涉及到UI，多疑要放到主线程，不然界面的UI很难刷新出来
        
        // 将接受到的数据储存到全局变量
        if (_dataTag == 0) {    // 第一次加载或刷新
            self.seeModelList = seeTempArr;
            self.seeTableView.seeLayoutList = self.seeModelList;
            // self.seeTableView.seeLayoutList = seeTempArr;
            // 结束刷新
            [self.seeTableView.pullToRefreshView stopAnimating];
        } else if (_dataTag == 1) {     // 加载
            [self.seeModelList addObjectsFromArray:seeTempArr];
            self.seeTableView.seeLayoutList = self.seeModelList;
            // [self.seeTableView.seeLayoutList addObjectsFromArray:seeTempArr];
            // 结束加载
            [self.seeTableView.infiniteScrollingView stopAnimating];
        }
        
        [self.seeTableView reloadData];
        
    });
    
    

}


- (void)dealloc {

    [[NSNotificationCenter defaultCenter] removeObserver:self name:openSendCommentControllerNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NotigicationOfSelfTranslucent object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:reloadSeeDate object:nil];
    // 必须将上拉加载下拉刷新移除
    self.seeTableView.showsPullToRefresh = NO;
    self.seeTableView.showsInfiniteScrolling = NO;
    
}





























/*
 
被丢弃的代码
 
 if ([button.titleLabel.text isEqualToString:@"记录生活"]) {
 // push到编辑界面
 SendMomentsController *momentsController = [[SendMomentsController alloc] init];
 UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:momentsController];
 nav.navigationBar.barTintColor = [UIColor colorWithRed:42.0/255.0 green:42.0/255.0 blue:48.0/255.0 alpha:1.0];
 [self presentViewController:nav animated:YES completion:nil];
 
 // 移除alert
 [UIView animateWithDuration:.35
 animations:^{
 [button.superview.superview viewWithTag:1001].transform = CGAffineTransformMakeTranslation(0, kScreenHeight*.25);
 } completion:^(BOOL finished) {
 [button.superview.superview removeFromSuperview];
 }];
 
 } else
 
 // 加载头像
 //UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:dic[@"head_img"]]]];
 //[self.imageArr addObject:image];
 
 // 此方法不能调起get方法，imageArr没有初始化，不能使用，添加不了image
 // [_imageArr addObject:image];
 
 // 当加载到图片，则添加到数组中，如果加载不到图片，给个0
 //if (![dic[@"about_img"] isEqualToString:@"0"]) {
 //    UIImage *aboutImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:dic[@"about_img"]]]];
 //    [self.AboutImageArr addObject:aboutImage];
 //} else {
 //    [self.AboutImageArr addObject:@"0"];
 //}
 
 // 加载自己的头像
 //self.seeTableView.selfHeadImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:imageUrl]];

 //            [self.seeTableView.headImgArr addObjectsFromArray:_imageArr];
 //            [self.seeTableView.aboutImgArr addObjectsFromArray:_AboutImageArr];

 
 // 获取URL对应的头像,自己的头像
 //NSURL *imageUrl = [NSURL URLWithString:[USER_D objectForKey:@"head_img"]];
 //            self.seeTableView.headImgArr = _imageArr;
 //            self.seeTableView.aboutImgArr = _AboutImageArr;

 @property (strong, nonatomic) NSMutableArray *imageArr;          // 缓存头像的数组
 
 - (NSMutableArray *)imageArr {
 
 if (_imageArr == nil) {
 _imageArr = [NSMutableArray array];
 }
 return _imageArr;
 
 }
 
 self.imageArr = nil;
 
 @property (strong, nonatomic) NSMutableArray *AboutImageArr;     // 缓存动态图像的数组
 
 - (NSMutableArray *)AboutImageArr {
 
 if (_AboutImageArr == nil) {
 _AboutImageArr = [NSMutableArray array];
 }
 return _AboutImageArr;
 
 }
 
 self.AboutImageArr = nil;
 
 //    NSString *urlStr = @"http://115.28.6.7/rongyun.php/Home/about/about_see";
 //    AFHTTPSessionManager *session = [AFHTTPSessionManager manager];
 //    session.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html", nil];
 //    [session POST:urlStr
 //       parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
 //
 //       } progress:^(NSProgress * _Nonnull uploadProgress) {
 //
 //       } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
 //           // 查看是否有动态
 //           NSDictionary *dic = responseObject;
 //           if ([dic[@"msg"]  isEqual: @1]) {
 //               // 在支线程处理数据,加载数据
 //               dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
 //                   [self loadData:responseObject];
 //               });
 //           } else {
 //               [SVProgressHUD dismiss];
 //               [SVProgressHUD showSuccessWithStatus:@"没有动态"];
 //           }
 //
 //       } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
 //           // 请求数据失败
 //
 //       }];
 
 NSString *urlStr = @"http://115.28.6.7/rongyun.php/Home/about/about_see";
 
 
 AFHTTPSessionManager *session = [AFHTTPSessionManager manager];
 session.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html", nil];
 [session POST:urlStr
 parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
 
 } progress:^(NSProgress * _Nonnull uploadProgress) {
 
 } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
 // 查看是否有动态
 NSDictionary *dic = responseObject;
 if ([dic[@"msg"]  isEqual: @1]) {
 // 在支线程处理数据,加载数据
 dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
 [self loadData:responseObject];
 });
 } else {
 
 // 如果没有动态就结束加载，不然会一直加载，导致刷新过后不能加载
 [self.seeTableView.infiniteScrollingView stopAnimating];
 
 [SVProgressHUD dismiss];
 [SVProgressHUD showSuccessWithStatus:@"没有动态"];
 }
 
 } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
 // 请求数据失败
 
 }];
 
 NSString *urlStr = @"http://115.28.6.7/rongyun.php/Home/about/about_see";
 AFHTTPSessionManager *session = [AFHTTPSessionManager manager];
 session.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html", nil];
 [session POST:urlStr
 parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
 
 } progress:^(NSProgress * _Nonnull uploadProgress) {
 
 } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
 
 // 查看是否有动态
 NSDictionary *dic = responseObject;
 if ([dic[@"msg"]  isEqual: @1]) {
 // 在支线程处理数据,加载数据
 dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
 [self loadData:responseObject];
 });
 } else {
 [SVProgressHUD dismiss];
 [SVProgressHUD showSuccessWithStatus:@"没有动态"];
 }
 
 } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
 // 请求数据失败
 
 }];
 
 
 
*/








@end
