//
//  SeeCell.m
//  XiaoHuiBang
//
//  Created by mac on 16/11/14.
//  Copyright © 2016年 消汇邦. All rights reserved.
//

#import "SeeCell.h"
#import "PraiseModel.h"
#import "AveluateModel.h"
#import <UIImageView+WebCache.h>
#import "CNetTool.h"
#import "InputView.h"
#import "NSString+Extension.h"
#import "PersonAboutController.h"
#import "CButton.h"
#import "CLabel.h"

#define kHeight 53                                                          // 输入视图默认高度
#define kProListHeight 25                                                   // 点赞列表的高度
#define kScreenHeight [UIScreen mainScreen].bounds.size.height              // 屏高
#define kScreenWidth [UIScreen mainScreen].bounds.size.width                // 屏宽

#define DeleteRow @"DeleteRow"                                              // 删除单元格并刷新表视图的通知名
#define ScrollTableView @"ScrollTableView"                                  // 发送调节表视图偏移的通知
#define HideCellInputView @"HideCellInputView"                              // 接收隐藏单元格输入框的通知
#define CommentReloadTableView @"CommentReloadTableView"                    // 评论后刷新表视图通知
#define reloadTableViewDataNotification @"reloadTableViewDataNotification"  // 刷新表视图通知

@interface SeeCell () <UITextViewDelegate, UIScrollViewDelegate, CLabelDeletage>



@end

@implementation SeeCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.headImageView.layer.cornerRadius = 22;
    self.headImageView.layer.masksToBounds = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(hideCellInputView:)
                                                 name:HideCellInputView
                                               object:nil];
    
}


#pragma mark - 懒加载
// 动态的内容label
- (UILabel *)contentLabel {

    if (_contentLabel == nil) {
        _contentLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _contentLabel.font = [UIFont systemFontOfSize:15];
        _contentLabel.numberOfLines = 0;
        _contentLabel.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1];
        [self.contentView addSubview:_contentLabel];
    }
    return _contentLabel;

}

// 动态的图片视图（一张）
- (UIImageView *)aboutImageView {

    if (_aboutImageView == nil) {
        _aboutImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _aboutImageView.contentMode = UIViewContentModeScaleAspectFit;
        _aboutImageView.clipsToBounds = YES;
        _aboutImageView.userInteractionEnabled = YES;
        // 添加点击手势
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showBiggerImageView:)];
        [_aboutImageView addGestureRecognizer:tap];
        [self.contentView addSubview:_aboutImageView];
    }
    return _aboutImageView;

}

// 时间文本
- (UILabel *)timeLabel {

    if (_timeLabel == nil) {
        _timeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _timeLabel.textColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1];
        _timeLabel.font = [UIFont systemFontOfSize:13];
        [self.contentView addSubview:_timeLabel];
    }
    return _timeLabel;

}

// 删除按钮
- (UIButton *)deleteButton {

    if (_deleteButton == nil) {
        _deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_deleteButton setTitle:@"删除" forState:UIControlStateNormal];
        [_deleteButton setTitleColor:[UIColor colorWithRed:220/225.0 green:42/255.0 blue:63/255.0 alpha:1]
                            forState:UIControlStateNormal];
        [_deleteButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
        _deleteButton.titleLabel.font = [UIFont systemFontOfSize:13];
        [_deleteButton addTarget:self action:@selector(deleteAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_deleteButton];
    }
    return _deleteButton;

}

// 点赞按钮
- (UIButton *)proButton {

    if (_proButton == nil) {
        _proButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_proButton addTarget:self action:@selector(proAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_proButton];
    }
    return _proButton;

}

// 评论按钮
- (UIButton *)commentButton {

    if (_commentButton == nil) {
        _commentButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_commentButton setImage:[UIImage imageNamed:@"icon_comment_gray"] forState:UIControlStateNormal];
        [_commentButton addTarget:self action:@selector(commentAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_commentButton];
    }
    return _commentButton;

}

// 点赞跟评论的背景视图
- (UIView *)commentAndProView {

    if (_commentAndProView == nil) {
        _commentAndProView = [[UIView alloc] initWithFrame:CGRectZero];
        _commentAndProView.backgroundColor = [UIColor colorWithRed:238/255.0 green:238/255.0 blue:238/255.0 alpha:1];
        [self.contentView addSubview:_commentAndProView];
    }
    return _commentAndProView;

}

// 点赞详情icon
- (UIImageView *)proListIcon {

    if (_proListIcon == nil) {
        _proListIcon = [[UIImageView alloc] initWithFrame:CGRectZero];
        _proListIcon.image = [UIImage imageNamed:@"icon_pro_blue"];
        [self.contentView addSubview:_proListIcon];
    }
    return _proListIcon;

}

// 点赞详情标签
- (UILabel *)proListLabel {

    if (_proListLabel == nil) {
        _proListLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _proListLabel.font = [UIFont systemFontOfSize:13];
        _proListLabel.textColor = [UIColor colorWithRed:35/255.0 green:97/255.0 blue:185/255.0 alpha:1];
        [self.contentView addSubview:_proListLabel];
    }
    return _proListLabel;

}









#pragma mark - 数据传给cell的时候对cell的内容进行赋值
- (void)setSeeLayout:(SeeLayout *)seeLayout {
    _seeLayout = seeLayout;
    // 说说的头像
    [_headImageView sd_setImageWithURL:[NSURL URLWithString:_seeLayout.seeModel.head_img]
                      placeholderImage:[UIImage imageNamed:@"pic_loading"]];
    // 给头像添加点击手势
    UITapGestureRecognizer *headTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(jumpToPersonAboutController:)];
    [_headImageView addGestureRecognizer:headTap];
    
    // 设置昵称
    _nickNameLabel.text = _seeLayout.seeModel.nickname;

    // 设置动态内容label
    self.contentLabel.text = _seeLayout.seeModel.content;
    self.contentLabel.frame = _seeLayout.seeFrame;
    
    // 设置动态图片的frame,加载缩略图
    if (_seeLayout.seeModel.about_img != nil) {
       
        [self.aboutImageView sd_setImageWithURL:[NSURL URLWithString:_seeLayout.seeModel.thumb_img]];
        self.aboutImageView.frame = _seeLayout.imgFrame;
    }
    
    // 当微博是自己的时候，显示删除按钮
    if (_seeLayout.seeModel.user_id == [USER_D objectForKey:@"user_id"]) {
        self.deleteButton.frame = _seeLayout.deleteFrame;
    }
    
    // 设置动态发布的时间
    self.timeLabel.text = _seeLayout.timeText;
    self.timeLabel.frame = _seeLayout.timeFrame;
    
    
    
    
    // 设置点赞按钮
    self.proButton.frame = _seeLayout.proFrame;
    for (PraiseModel *praise in _seeLayout.seeModel.praise) {
        if (praise.user_id == [USER_D objectForKey:@"user_id"]) {
            _isLike = YES;
            break;
        }
    }
    if (_isLike == YES) {
        [self.proButton setImage:[UIImage imageNamed:@"icon_pro_blue"] forState:UIControlStateNormal];
    } else {
        [self.proButton setImage:[UIImage imageNamed:@"icon_pro_gray"] forState:UIControlStateNormal];
    }
    
    // 设置评论按钮
    self.commentButton.frame = _seeLayout.commentFrame;
    
    // 点赞+评论背景视图
    self.commentAndProView.frame = _seeLayout.proAndCommentFrame;
    
    // 点赞详情按钮icon
    self.proListIcon.frame = _seeLayout.proListIconFrame;
    
    // 点赞详情label
    self.proListLabel.frame = _seeLayout.proListLabelFrame;
    NSMutableString *mString = [NSMutableString string];
    for (int i = 0; i < _seeLayout.seeModel.praise.count; i++) {
        PraiseModel *praise = _seeLayout.seeModel.praise[i];
        if (i < 3) {
            if (i == 0) {
                [mString appendString:praise.nickname];
            } else {
                [mString appendFormat:@",%@", praise.nickname];
            }
        }
    }
    if (_seeLayout.seeModel.praise.count > 3) {
        [mString appendFormat:@"等%ld人", (unsigned long)_seeLayout.seeModel.praise.count];
    }
    self.proListLabel.text = mString;
    
    // 评论详情    
    for (int i = 0; i < _seeLayout.commentListFrameArr.count; i++) {
        AveluateModel *aveluate = _seeLayout.seeModel.aveluate[i];
        CGRect frame = [_seeLayout.commentListFrameArr[i] CGRectValue];
        CLabel *comment = [[CLabel alloc] initWithFrame:frame];
        comment.numberOfLines = 0;
        comment.font = [UIFont systemFontOfSize:14];
        comment.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1];
        comment.delegate = self;
        comment.labelID = aveluate.user_id;
        
        // 富文本
        NSMutableAttributedString *attribute = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@: %@", aveluate.nickname, aveluate.about_content]];
        [attribute addAttribute:NSForegroundColorAttributeName
                          value:[UIColor colorWithRed:25/255.0 green:97/255.0 blue:185/255.0 alpha:1]
                          range:NSMakeRange(0, aveluate.nickname.length+1)];
        comment.attributedText = attribute;
        
        [self.contentView addSubview:comment];
        
        // 添加点击昵称的按钮
        CGRect rect = [aveluate.nickname boundingRectWithSize:CGSizeMake(300, 999)
                                                      options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                                   attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:14]}
                                                      context:nil];
        frame.size.height = 20;
        frame.size.width = rect.size.width;
        CButton *nickButton = [CButton buttonWithType:UIButtonTypeCustom];
        nickButton.frame = frame;
        nickButton.user_id = aveluate.user_id;
        [nickButton setBackgroundColor:[UIColor clearColor]];
        [nickButton addTarget:self
                       action:@selector(jumpToPersonAboutControllerWithData:)
             forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:nickButton];
        
    }
}


#pragma mark - 点赞按钮响应
- (void)proAction:(UIButton *)button {


    _isLike = !_isLike;
    if (_isLike == YES) {
        
        // 网络请求点赞功能
        NSDictionary *param = @{
                                @"user_id":[USER_D objectForKey:@"user_id"],
                                @"about_id":_seeLayout.seeModel.about_id
                                };
        [CNetTool postProWithParameters:param
                                success:^(id response) {

                                    [SVProgressHUD dismiss];
                                    [SVProgressHUD showSuccessWithStatus:@"已经点赞"];
                                    // 刷新表视图 -- -- -- SeetableView
                                    [[NSNotificationCenter defaultCenter] postNotificationName:reloadTableViewDataNotification
                                                                                        object:[NSString stringWithFormat:@"%ld", (long)_indexpathRow]];
                                    [button setImage:[UIImage imageNamed:@"icon_pro_blue"] forState:UIControlStateNormal];
                                
                                } failure:^(NSError *err) {
                                    [SVProgressHUD dismiss];
                                    [SVProgressHUD showSuccessWithStatus:@"点赞失败"];
                                }];
        
    } else {
        
        // 网络请求取消赞功能
        NSDictionary *param = @{
                                @"user_id":[USER_D objectForKey:@"user_id"],
                                @"about_id":_seeLayout.seeModel.about_id
                                };
        [CNetTool postProWithParameters:param
                                success:^(id response) {
                                    
                                    [SVProgressHUD dismiss];
                                    [SVProgressHUD showSuccessWithStatus:@"已取消点赞"];
                                    // 刷新表视图 -- -- -- SeetableView
                                    [[NSNotificationCenter defaultCenter] postNotificationName:reloadTableViewDataNotification
                                                                                        object:[NSString stringWithFormat:@"%ld", (long)_indexpathRow]];
                                    [button setImage:[UIImage imageNamed:@"icon_pro_gray"] forState:UIControlStateNormal];
                                } failure:^(NSError *err) {
                                    [SVProgressHUD dismiss];
                                    [SVProgressHUD showSuccessWithStatus:@"取消点赞失败"];
                                }];
        
    }
    
    

}

#pragma mark - 评论按钮响应,弹出键盘和输入框
- (void)commentAction:(UIButton *)button {
    
    // 收起键盘
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
    
    // 创建输入框
    _inputView = [[[NSBundle mainBundle] loadNibNamed:@"InputView" owner:self options:nil] firstObject];
    _inputView.frame = CGRectMake(0, kScreenHeight, kScreenWidth, kHeight);
    [_inputView.input becomeFirstResponder];
    _inputView.input.delegate = self;
    _inputView.input.returnKeyType = UIReturnKeySend;
    _inputView.input.layer.cornerRadius = 5;
    _inputView.input.layer.borderColor = [UIColor colorWithRed:229/255.0
                                               green:229/255.0
                                                blue:229/255.0 alpha:1].CGColor;
    _inputView.input.layer.borderWidth = 0.5;
    _inputView.input.clipsToBounds = YES;
    _inputView.cellRow = _indexpathRow;

    [[UIApplication sharedApplication].keyWindow addSubview:_inputView];
    
    
}

#pragma mark - 删除按钮
- (void)deleteAction:(UIButton *)button {
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"确定要删除此条目？"
                                                                   message:@"删除后不可恢复"
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    
    // 确定删除动态按钮
    UIAlertAction *sureAction = [UIAlertAction actionWithTitle:@"确定"
                                                         style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction * _Nonnull action) {
// 网络请求删除动态，并且删除单元格  -- -- -- SeetableView
[[NSNotificationCenter defaultCenter] postNotificationName:DeleteRow
                                                    object:[NSString stringWithFormat:@"%ld", (long)_indexpathRow]];
NSDictionary *param = @{@"id":_seeLayout.seeModel.about_id};
[CNetTool deleteAboutWithParameters:param
                            success:^(id response) {
                                [SVProgressHUD dismiss];
                                [SVProgressHUD showSuccessWithStatus:@"删除动态成功"];
                            } failure:^(NSError *err) {
                                [SVProgressHUD dismiss];
                                [SVProgressHUD showSuccessWithStatus:@"删除动态失败"];
                            }];
                                                       }];
    
    // 取消删除动态按钮
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消"
                                                           style:UIAlertActionStyleDefault
                                                         handler:nil];
    [alert addAction:sureAction];
    [alert addAction:cancelAction];
    
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alert
                                                                                 animated:YES
                                                                               completion:nil];



}

#pragma mark - 监听输入消息，改变输入框高度
- (void)textViewDidChange:(UITextView *)textView {

    // 注意配置文本的宽度，以及字体大小
    CGRect textRect = [textView.text boundingRectWithSize:CGSizeMake(kScreenWidth - 62, 99999)
                                                  options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin
                                               attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:14]}
                                                  context:nil];
    // 获取原始高度
    CGRect frame = textView.superview.frame;
    float height = frame.size.height;
    frame.size.height = textRect.size.height + 10*2;
    frame.origin.y -= (frame.size.height - height);
    if (frame.size.height > textView.superview.frame.size.height && textView.superview.frame.size.height < 100) {   // 最高为100
        // 设置输入框的frame
        [UIView animateWithDuration:.35
                         animations:^{
            textView.superview.frame = frame;
        }];
        // 设置表视图的偏移(提供输入框的Y起点和单元格indexpath即可)
        [[NSNotificationCenter defaultCenter] postNotificationName:ScrollTableView
                                                            object:@{@"y" : [NSString stringWithFormat:@"%f", frame.origin.y],
                                                           @"indexpathRow":[NSString stringWithFormat:@"%ld", (long)_indexpathRow]}];
    }
    
}

#pragma mark - 点击return发送评论
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {

    
    // 当点下发送按钮
    if ([text isEqualToString:@"\n"]) {
        
        // 当评论为空的时候，不允许发送
        if ([textView.text isEmpty]) {
            [SVProgressHUD dismiss];
            [SVProgressHUD showSuccessWithStatus:@"评论不能为空"];
            return NO;
        }
        // 发送评论
        NSDictionary *param = @{@"user_id":[USER_D objectForKey:@"user_id"],
                                @"about_id":_seeLayout.seeModel.about_id,
                                @"about_content":textView.text};
        [CNetTool postCommentWithParameters:param
                                    success:^(id response) {
                                        [SVProgressHUD dismiss];
                                        [SVProgressHUD showSuccessWithStatus:@"评论成功"];
                                        // 发送通知，让表视图刷新
                                        [[NSNotificationCenter defaultCenter] postNotificationName:CommentReloadTableView object:@{@"about_content":textView.text,
                                                                                                                                   @"indexpathRow":[NSString stringWithFormat:@"%ld", (long)_indexpathRow]}];

                                    } failure:^(NSError *err) {
                                        [SVProgressHUD dismiss];
                                        [SVProgressHUD showSuccessWithStatus:@"请求失败"];
                                    }];
        
        
        // 收起键盘
        [textView resignFirstResponder];
        
    }
    return YES;

}

#pragma mark - 隐藏输入框的通知响应
- (void)hideCellInputView:(NSNotification *)notification {

    if ([_inputView.input isEditable]) {
        [_inputView.input endEditing:YES];
    }
    
    
}

#pragma mark - 点击头像、昵称，跳转到个人动态界面
- (void)jumpToPersonAboutController:(UITapGestureRecognizer *)tap {
    
    // 收起键盘
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
    
    // 添加动画
    [UIView animateWithDuration:.35
                     animations:^{
                         tap.view.transform = CGAffineTransformMakeRotation(M_PI_4);
                     } completion:^(BOOL finished) {
                         [UIView animateWithDuration:.35
                                          animations:^{
                                              tap.view.transform = CGAffineTransformIdentity;
                                          } completion:^(BOOL finished) {
                                              UINavigationController *nav = (UINavigationController *)[self viewController];
                                              PersonAboutController *controller = [[PersonAboutController alloc] initWithUserID:_seeLayout.seeModel.user_id];
                                              controller.hidesBottomBarWhenPushed = YES;
                                              [nav pushViewController:controller animated:YES];
                                          }];
                     }];
    
}
- (void)jumpToPersonAboutControllerWithData:(CButton *)button {
    
    // 收起键盘
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
    
    UINavigationController *nav = (UINavigationController *)[self viewController];
    PersonAboutController *controller = [[PersonAboutController alloc] initWithUserID:button.user_id];
    controller.hidesBottomBarWhenPushed = YES;
    [nav pushViewController:controller animated:YES];
}



#pragma mark - 移除通知
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:HideCellInputView object:nil];
}

#pragma mark - 获取某视图所在的导航控制器
- (UIViewController *)viewController {
    for (UIView *next = [self superview]; next; next = next.superview) {
        UIResponder* nextResponder = [next nextResponder];
        if ([nextResponder isKindOfClass:[UINavigationController class]]) {
            return (UIViewController*)nextResponder;
        }
    }
    return nil;
}

#pragma mark - 点击动态图片查看大图
- (void)showBiggerImageView:(UITapGestureRecognizer *)tap {

    // 创建滑动视图
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    scrollView.contentSize = CGSizeMake(kScreenWidth, kScreenHeight);
    scrollView.backgroundColor = [UIColor blackColor];
    scrollView.delegate = self;
    // 先设置为透明，然后再用动画显示出来
    scrollView.alpha = 0;
    // 允许内容尺寸小于bounds时滑动
    scrollView.alwaysBounceHorizontal = YES;
    scrollView.alwaysBounceVertical = YES;
    // 设置最大最小缩放倍数
    scrollView.minimumZoomScale = 1;
    scrollView.maximumZoomScale = 2.5;
    // 添加单击手势，隐藏查看原图
    UITapGestureRecognizer *newTap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                             action:@selector(hideBiggerImageView:)];
    [scrollView addGestureRecognizer:newTap];
    // 添加图片
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    imageView.tag = 123;
    // 设置imageview的内容模式，必须在设置图片之前设置，不然会出错
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.userInteractionEnabled = YES;
    // [imageView sd_setImageWithURL:[NSURL URLWithString:_seeLayout.seeModel.about_img]];
    // 先显示缩略图，一边加载高清图，实时显示进度
    [imageView sd_setImageWithURL:[NSURL URLWithString:_seeLayout.seeModel.about_img]
                 placeholderImage:_aboutImageView.image
                          options:SDWebImageRetryFailed
                         progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                             [SVProgressHUD showProgress:receivedSize / (expectedSize * 1.0)];
                         } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                             [SVProgressHUD dismiss];
                         }];
    
    // 添加长按手势，保存到本地
    UILongPressGestureRecognizer *longPre = [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                                                          action:@selector(longPressAction:)];
    longPre.minimumPressDuration = 1.5;
    [imageView addGestureRecognizer:longPre];
    [scrollView addSubview:imageView];
    
    [[[UIApplication sharedApplication] keyWindow] addSubview:scrollView];
    [UIView animateWithDuration:.35
                     animations:^{
                         scrollView.alpha = 1;
                     } completion:^(BOOL finished) {
                         // 提示怎么保存图片
                         NSString *result = [USER_D objectForKey:@"长按自动将图片保存到本地"];
                         if (result == nil) {
                             [SVProgressHUD dismiss];
                             [SVProgressHUD showSuccessWithStatus:@"长按自动将图片保存到本地"];
                             [USER_D setObject:@"已经提示过" forKey:@"长按自动将图片保存到本地"];
                         }

                     }];
    

}
// 隐藏查看原图
- (void)hideBiggerImageView:(UITapGestureRecognizer *)tap {

    [UIView animateWithDuration:.35
                     animations:^{
                        tap.view.alpha = 0;
                     } completion:^(BOOL finished) {
                        [tap.view removeFromSuperview];
                     }];
    

}
// 长按手势响应
- (void)longPressAction:(UILongPressGestureRecognizer *)longPre {
    
    // 长按手势会调用两次（开始、结束）
    if (longPre.state == UIGestureRecognizerStateBegan) {
        UIImageWriteToSavedPhotosAlbum([(UIImageView *)(longPre.view) image], self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
        // 直接将图片保存到本地
        [SVProgressHUD dismiss];
        [SVProgressHUD showSuccessWithStatus:@"已经将图片保存到本地"];
    } 
    
    
}
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    
}

// 滑动视图的代理方法，缩放时让图片也缩放
- (nullable UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {

    return [scrollView viewWithTag:123];

}

#pragma maek - 点击评论响应代理方法，在这里可以做回复评论
- (void)cLabelTouch:(CLabel *)cLabel {

    NSLog(@"%@", cLabel.text);

}







/*
 
被丢弃的代码
 
self.commentsListView.frame = _seeLayout.commentsListViewFrame;
 
 
// 评论详情列表
- (UIView *)commentsListView {

if (_commentsListView == nil) {
_commentsListView = [[UIView alloc] initWithFrame:CGRectZero];
_commentsListView.backgroundColor = [UIColor clearColor];
[self.contentView addSubview:_commentsListView];

}
return _commentsListView;

}
 
 //// 头像的图片
 //- (void)setHeadImage:(UIImage *)headImage {
 //
 //    _headImage = headImage;
 //    _headImageView.image = headImage;
 //
 //}
 //
 //// 动态的图片
 //- (void)setAboutImage:(UIImage *)aboutImage {
 //
 //    _aboutImage = aboutImage;
 //    self.aboutImageView.image = aboutImage;
 //
 //}

 
*/










- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
