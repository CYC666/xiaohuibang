//
//  AboutWithImageController.m
//  XiaoHuiBang
//
//  Created by mac on 16/11/29.
//  Copyright © 2016年 消汇邦. All rights reserved.
//

// 显示带有图片的动态



#import "AboutWithImageController.h"
#import <UIImageView+WebCache.h>

#define kScreenHeight [UIScreen mainScreen].bounds.size.height  // 屏高
#define kScreenWidth [UIScreen mainScreen].bounds.size.width    // 屏宽

#define NotigicationOfSelfTranslucent @"NotigicationOfSelfTranslucent"  // 修改导航栏不透明的通知


@interface AboutWithImageController () <UITextFieldDelegate> {

    UIView *_tabView;           // 底部收纳按钮的视图
    UITextField *_inputField;    // 底部输入框

}

@property (assign, nonatomic) BOOL isHideNav;   // 是否隐藏导航栏
@property (assign, nonatomic) BOOL isShowKeyBoard;  // 是否已经展示了键盘

@end

@implementation AboutWithImageController

- (instancetype)initWithPersonModel:(PersonSeeModel *)model {

    self = [super init];
    if (self != nil) {
        self.personModel = model;
    }
    return self;
    
}
#pragma mark - 懒加载
- (UIImageView *)aboutImageView {

    if (_aboutImageView == nil) {
        _aboutImageView = [[UIImageView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        _aboutImageView.userInteractionEnabled = YES;
        _aboutImageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.view addSubview:_aboutImageView];
        //  添加手势，点击隐藏、显示导航栏、标签栏
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
        [_aboutImageView addGestureRecognizer:tap];
    }
    return _aboutImageView;

}

- (PersonSeeModel *)personModel {

    if (_personModel == nil) {
        _personModel = [[PersonSeeModel alloc] init];
    }
    return _personModel;

}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = _personModel.about_id;
    self.view.backgroundColor = [UIColor blackColor];
    self.navigationController.navigationBar.translucent = YES;
    
    
    // 时间戳转换时间
    NSDate *confromTimesp = [NSDate dateWithTimeIntervalSince1970:[_personModel.create_time integerValue]];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"YYYY年MM月dd日 HH:mm:ss"];
    NSString *confromTimespStr = [formatter stringFromDate:confromTimesp];
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 40)];
    title.text = confromTimespStr;
    title.textAlignment = NSTextAlignmentCenter;
    title.textColor = [UIColor whiteColor];
    self.navigationItem.titleView = title;
    
    [self _creatSubview];
    
    // 监听键盘弹出的通知
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyBoardShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    // 监听键盘收回
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(hideBoardShow:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

#pragma mark - 创建子视图
- (void)_creatSubview {

    [self.aboutImageView sd_setImageWithURL:[NSURL URLWithString:_personModel.about_img]];

    // 创建底部的按钮栏
    _tabView = [[UIView alloc] initWithFrame:CGRectMake(0, kScreenHeight - 49, kScreenWidth, 49)];
    _tabView.backgroundColor = [UIColor colorWithRed:15/255.0 green:15/255.0 blue:15/255.0 alpha:1];
    [self.view addSubview:_tabView];
    
    // 点赞按钮
    UIButton *proButton = [UIButton buttonWithType:UIButtonTypeCustom];
    proButton.frame = CGRectMake(kScreenWidth-114.5-18, 16.5, 18, 16);
    [proButton setImage:[UIImage imageNamed:@"icon_pro_gray"] forState:UIControlStateNormal];
    [_tabView addSubview:proButton];
    
    // 分割线
    UIImageView *line = [[UIImageView alloc] initWithFrame:CGRectMake(kScreenWidth - 72, 14.5, 1, 20)];
    line.backgroundColor = [UIColor colorWithRed:46/255.0 green:46/255.0 blue:46/255.0 alpha:.7];
    [_tabView addSubview:line];
    
    // 评论按钮
     UIButton *commentButton = [UIButton buttonWithType:UIButtonTypeCustom];
     commentButton.frame = CGRectMake(kScreenWidth-38.5-17.5, 16.5, 17.5, 16);
    [commentButton setImage:[UIImage imageNamed:@"icon_comment_gray"] forState:UIControlStateNormal];
    [_tabView addSubview:commentButton];
    
    // 评论输入框
    _inputField = [[UITextField alloc] initWithFrame:CGRectMake(12, 10, kScreenWidth-164.5-12, 29)];
    _inputField.textColor = [UIColor whiteColor];
    _inputField.returnKeyType = UIReturnKeySend;
    _inputField.borderStyle = UITextBorderStyleNone;
    _inputField.layer.borderWidth = .5;
    _inputField.layer.borderColor = [UIColor colorWithRed:46/255.0 green:46/255.0 blue:46/255.0 alpha:1].CGColor;
    _inputField.backgroundColor = [UIColor colorWithRed:33/255.0 green:33/255.0 blue:33/255.0 alpha:1];
    _inputField.delegate = self;
    [_tabView addSubview:_inputField];
  
}

#pragma mark - image的点击手势，显示/隐藏导航栏、标签栏
- (void)tapAction:(UITapGestureRecognizer *)tap {

    _isHideNav = !_isHideNav;
    if (_isHideNav == YES) {
        
        
        [UIView animateWithDuration:.35
                         animations:^{
                             self.navigationController.navigationBar.transform = CGAffineTransformMakeTranslation(0, -64);
                             _tabView.transform = CGAffineTransformMakeTranslation(0, 49);
                             
                             // 当键盘已经显示,要收起键盘
                             if (_isShowKeyBoard == YES) {
                                 
                                 [_inputField endEditing:YES];
                                 
                             }
                             
                         }];
        
        
    } else {
        
        [UIView animateWithDuration:.35
                         animations:^{
                             self.navigationController.navigationBar.transform = CGAffineTransformMakeTranslation(0, 0);
                             _tabView.transform = CGAffineTransformMakeTranslation(0, 0);
                         }];
    }

}

#pragma mark - 键盘弹出、收回
- (void)keyBoardShow:(NSNotification *)notification {

    _isShowKeyBoard = YES;
    
    CGRect rect = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    float height = rect.size.height;
    
    // 底部框上移
    [UIView animateWithDuration:.35
                     animations:^{
                         _tabView.transform = CGAffineTransformMakeTranslation(0, -height);
                     }];

}
- (void)hideBoardShow:(NSNotification *)notification {

    _isShowKeyBoard = NO;
    
    // 底部框下移
    [UIView animateWithDuration:.35
                     animations:^{
                         if (_isHideNav == YES) {
                             _tabView.transform = CGAffineTransformMakeTranslation(0, 49);
                         } else {
                             _tabView.transform = CGAffineTransformMakeTranslation(0, 0);
                         }
                     }];

}


#pragma mark - textfield的代理方法，点击return发送评论
- (BOOL)textFieldShouldReturn:(UITextField *)textField {

    // 发送评论
    textField.text = nil;
    [textField endEditing:YES];
    return YES;

}


























// 控制器销毁之前，将导航栏设置回不透明，不然会影响其他导航栏
- (void)dealloc {

    [[NSNotificationCenter defaultCenter] postNotificationName:NotigicationOfSelfTranslucent object:nil];

}


@end
