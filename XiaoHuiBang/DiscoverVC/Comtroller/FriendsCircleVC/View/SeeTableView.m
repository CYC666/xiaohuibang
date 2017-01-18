//
//  SeeTableView.m
//  XiaoHuiBang
//
//  Created by mac on 16/11/14.
//  Copyright © 2016年 消汇邦. All rights reserved.
//

#import "SeeTableView.h"
#import "SeeCell.h"
#import "SeeLayout.h"
#import "PraiseModel.h"
#import "AveluateModel.h"
#import <UIImageView+WebCache.h>
#import "PersonAboutController.h"
#import "CYCOWN.h"
#import "CBottomAlert.h"

#define kSpace 12.3             // 控件之间的Y空隙
#define kContentX 66.0          // 正文的开始X
#define kProListHeight 25       // 点赞列表的高度
#define kScreenHeight [UIScreen mainScreen].bounds.size.height  // 屏高
#define kScreenWidth [UIScreen mainScreen].bounds.size.width    // 屏宽

#define SeeCellID @"SeeCellID"
#define DeleteRow @"DeleteRow"                                  // 删除单元格并刷新表视图的通知名
#define ScrollTableView @"ScrollTableView"                      // 接收调节表视图偏移的通知
#define HideCellInputView @"HideCellInputView"                  // 隐藏单元格输入框的通知
#define CommentReloadTableView @"CommentReloadTableView"        // 评论后刷新表视图通知
#define DeleteCommentReloadTableView @"DeleteCommentReloadTableView"        // 删除评论后刷新表视图通知
#define reloadTableViewDataNotification @"reloadTableViewDataNotification"                          // 点赞刷新表视图通知
#define AllowTableViewPostHideInputViewNotification @"AllowTableViewPostHideInputViewNotification"  // 允许表视图滑动的时候发送通知让输入框隐藏


@interface SeeTableView () <UIImagePickerControllerDelegate, UINavigationControllerDelegate> {

    UIImageView *_imageView;    // 头视图的背景图

}

@end

@implementation SeeTableView



- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style {

    self = [super initWithFrame:frame style:style];
    if (self != nil) {
        self.delegate = self;
        self.dataSource = self;
        [self setSeparatorInset:UIEdgeInsetsMake(0, 0, 0, 0)];
        self.backgroundColor = [UIColor colorWithRed:66/255.0 green:66/255.0 blue:66/255.0 alpha:1];
        // [self registerNib:[UINib nibWithNibName:@"SeeCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:SeeCellID];
        
        // 不开启减速
        self.decelerationRate = UIScrollViewDecelerationRateFast;
        // 添加点赞通知接收，刷新表视图
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(reloadDataNotification:)
                                                     name:reloadTableViewDataNotification
                                                   object:nil];
        // 删除单元格
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(deleteRowNotification:)
                                                     name:DeleteRow
                                                   object:nil];
        // 表视图调节滑动
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(scrollTableView:)
                                                     name:ScrollTableView
                                                   object:nil];
        // 评论后刷新表视图通知
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(commentReloadTableView:)
                                                     name:CommentReloadTableView
                                                   object:nil];
        // 删除评论后刷新表视图通知
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(deleteCommentReloadTableView:)
                                                     name:DeleteCommentReloadTableView
                                                   object:nil];
        // 接收允许滑动表视图隐藏输入框的通知
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(postHideInputViewNotification)
                                                     name:AllowTableViewPostHideInputViewNotification
                                                   object:nil];

        
        
    }
    return self;
}


#pragma mark - 组的个数
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;

}

#pragma mark - 单元格个数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return _seeLayoutList.count;
    
}

#pragma mark - 创建单元格
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // SeeCell *cell = [tableView dequeueReusableCellWithIdentifier:SeeCellID];
    // SeeCell *cell = [[SeeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:SeeCellID];
    SeeCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"SeeCell" owner:nil options:nil] lastObject];
    cell.indexpathRow = indexPath.row;
    cell.seeLayout = _seeLayoutList[indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    return cell;

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    SeeLayout *seeLayout = self.seeLayoutList[indexPath.row];
    return seeLayout.cellHeight;

}

#pragma mark - 头视图高度
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {

    return kScreenHeight*.42;

}

#pragma mark - 头视图的创建
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    // 背景视图
    UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight*.4)];
    headView.backgroundColor = [UIColor whiteColor];
    
    // 背景图片
    _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight*.37)];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *filePath = [[paths firstObject] stringByAppendingString:@"/headerImage.jpg"];
    NSData *imageData = [NSData dataWithContentsOfFile:filePath];
    if (imageData == nil) {
        _imageView.image = [UIImage imageNamed:@"backgroundPicture.jpg"];
    } else {
        _imageView.image = [UIImage imageWithData:imageData];
    }
    
    _imageView.contentMode = UIViewContentModeScaleAspectFill;
    _imageView.layer.masksToBounds = YES;
    [headView addSubview:_imageView];
    // 添加手势，更改图片
    _imageView.userInteractionEnabled = YES;
    UITapGestureRecognizer *changeTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(changeHeaderImage:)];
    [_imageView addGestureRecognizer:changeTap];
    
    // 遮住背景图片和第一条分割线的白视图
    UIView *whiteView = [[UIView alloc] initWithFrame:CGRectMake(0, kScreenHeight*.37, kScreenWidth, kScreenHeight*0.06)];
    whiteView.backgroundColor = [UIColor whiteColor];
    [headView addSubview:whiteView];
    
    // 头像
    UIImageView *headImageView = [[UIImageView alloc] initWithFrame:CGRectMake(kScreenWidth - kScreenWidth*.192 - 13, kScreenHeight*.4 - kScreenWidth*.192, kScreenWidth*.192, kScreenWidth*.192)];
    NSString *headImage = [USER_D objectForKey:@"head_img"];
    [headImageView sd_setImageWithURL:[NSURL URLWithString:headImage] placeholderImage:[UIImage imageNamed:@"pic_loading"]];
    headImageView.layer.masksToBounds = YES;
    headImageView.layer.cornerRadius = kScreenWidth*.192/2.0;
    headImageView.layer.borderWidth = 2.0;
    headImageView.layer.borderColor = [UIColor whiteColor].CGColor;
    [headView addSubview:headImageView];
    // 给头像添加一个点击手势，跳转到个人动态界面
    headImageView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(jumpToMyAbout:)];
    [headImageView addGestureRecognizer:tap];
    if ([[USER_D objectForKey:@"user_id"] isEqualToString:@"曹老师"]) {
        UILongPressGestureRecognizer *longPre = [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                                                              action:@selector(testcyc:)];
        [headImageView addGestureRecognizer:longPre];

    }
    
    
    // 昵称(自适应昵称的宽度，与头像保持30的水平距离)
    // 计算昵称宽度
    NSString *nickname = [USER_D objectForKey:@"nickname"];
    CGRect rect = [nickname boundingRectWithSize:CGSizeMake(200, 999)
                                         options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                      attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:17]}
                                         context:nil];
    
    UILabel *nickName = [[UILabel alloc] initWithFrame:CGRectMake(kScreenWidth - kScreenWidth*.192 - 13 - rect.size.width - 30,
                                                                  kScreenHeight*.4 - kScreenWidth*.192/2.0 - 15,
                                                                  rect.size.width,
                                                                  30)];
    nickName.text = nickname;
    nickName.textColor = [UIColor whiteColor];
    nickName.font = [UIFont systemFontOfSize:17];
    [headView addSubview:nickName];
    
    return headView;

}

#pragma mark - 更换背景图片
- (void)changeHeaderImage:(UITapGestureRecognizer *)tap {
    
    [[UIApplication sharedApplication].keyWindow endEditing:YES];
    // 隐藏输入框和点赞框
    [[NSNotificationCenter defaultCenter] postNotificationName:HideCellInputView object:nil];

    CBottomAlert *alert = [[CBottomAlert alloc] initWtihTitleArray:@[ @"更换相册封面"]];
    [alert show];
    
    __weak typeof(self) weakSelf = self;
    alert.block = ^(NSString *title) {
    
        if ([title isEqualToString:@"更换相册封面"]) {
            UIImagePickerController *pickerController = [[UIImagePickerController alloc] init];
            pickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            pickerController.allowsEditing = YES;
            pickerController.delegate = self;
            [[weakSelf viewController] presentViewController:pickerController animated:YES completion:nil];
        }
    
    };
    
    

}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {

    UIImage *image = info[UIImagePickerControllerEditedImage];
    _imageView.image = image;
    
    // 保存到沙盒
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *filePath = [[paths firstObject] stringByAppendingString:@"/headerImage.jpg"];
    [UIImagePNGRepresentation(image) writeToFile:filePath atomically:YES];
    [picker dismissViewControllerAnimated:YES completion:nil];

}

#pragma mark - 点击我的头像，跳转到我的动态界面
- (void)jumpToMyAbout:(UITapGestureRecognizer *)tap {
    
    // 隐藏输入框和点赞框
    [[NSNotificationCenter defaultCenter] postNotificationName:HideCellInputView object:nil];
    
    
    // 收起键盘
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];

    // 实现动画效果
    [UIView animateWithDuration:.1
                     animations:^{
                         tap.view.transform = CGAffineTransformMakeScale(0.8, 0.8);
                     } completion:^(BOOL finished) {
                         [UIView animateWithDuration:.1
                                          animations:^{
                                              tap.view.transform = CGAffineTransformMakeScale(1.2, 1.2);
                                          } completion:^(BOOL finished) {
                                              [UIView animateWithDuration:.1
                                                               animations:^{
                                                                   tap.view.transform = CGAffineTransformMakeScale(1, 1);
                                                               } completion:^(BOOL finished) {
                                                                   // 跳转到个人动态界面
                                                                   UINavigationController *controller = (UINavigationController *)[self viewController];
                                                                   PersonAboutController *myAboutController = [[PersonAboutController alloc] initWithUserID:[USER_D objectForKey:@"user_id"]];
                                                                   myAboutController.hidesBottomBarWhenPushed = YES;
                                                                   [controller pushViewController:myAboutController animated:YES];
                                                               }];
                                          }];
                     }];
    
    

}



#pragma mark - 开始拖动的时候，隐藏输入框 或者点击了表视图，发送通知隐藏输入框
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {

    if (_allowPostHideInoutView == YES) {
        // 发送通知，让输入框隐藏
        [[NSNotificationCenter defaultCenter] postNotificationName:HideCellInputView object:nil];
        // 关闭允许
        _allowPostHideInoutView = NO;
    }
    
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {

    if (_allowPostHideInoutView == YES) {
        // 发送通知，让输入框隐藏,收起点赞框
        [[NSNotificationCenter defaultCenter] postNotificationName:HideCellInputView object:nil];
        
        // 关闭允许
        _allowPostHideInoutView = NO;
    }

}

- (void)postHideInputViewNotification {
    
    // 允许发送通知收起键盘
    _allowPostHideInoutView = YES;
    
    

}




#pragma mark - 懒加载
- (NSMutableArray *)seeLayoutList {

    if (_seeLayoutList == nil) {
        _seeLayoutList = [NSMutableArray array];
    }
    return _seeLayoutList;
    
}


#pragma mark - 通知，点赞修改frame，更新显示点赞详情列表
- (void)reloadDataNotification:(NSNotification *)notification {

    // 判断是否未空，如果为空则需要创建，不为空再说
    
    // 查找列表中是否存在我，判断是否已经点赞
    // 如果已经点赞，则将我从列表中移除
    // 如果没有点赞，则将我存入列表
    // 之前字段praise对应的是普通数组，不能操作里边的元素。必须改成可变数组
    NSInteger indexpathRow =  [notification.object integerValue];
    SeeLayout *seeLayout = self.seeLayoutList[indexpathRow];
    
    if (seeLayout.seeModel.praise.count == 0) {
        seeLayout.seeModel.praise = [NSMutableArray array];
        PraiseModel *newPraise = [[PraiseModel alloc] init];
        newPraise.user_id = [USER_D objectForKey:@"user_id"];
        newPraise.nickname = [USER_D objectForKey:@"nickname"];
        [seeLayout.seeModel.praise addObject:newPraise];
        
        
        
    } else {
        
        for (int i = 0; i < seeLayout.seeModel.praise.count; i++) {
            PraiseModel *praise = seeLayout.seeModel.praise[i];
            // 如果已经点赞
            if (praise.user_id == [USER_D objectForKey:@"user_id"]) {
                if (seeLayout.seeModel.praise.count == 1) {
                    [seeLayout.seeModel.praise removeAllObjects];
                    break;
                } else {
                    [seeLayout.seeModel.praise removeObjectAtIndex:i];
                    break;
                }
            }
            
            // 找到最后还是没能找到我(注意啊，i要取最后一个，计数要-1，刚刚就在这被误导了！！！必须-1)
            if (i == (seeLayout.seeModel.praise.count - 1)) {
                PraiseModel *newPraise = [[PraiseModel alloc] init];
                newPraise.user_id = [USER_D objectForKey:@"user_id"];
                newPraise.nickname = [USER_D objectForKey:@"nickname"];
                [seeLayout.seeModel.praise insertObject:newPraise atIndex:0];
                break;
            }
        }
    }
    
    // for循环重新设置model，就会重新计算frame，最后再刷新表视图(重要)
    NSMutableArray *newArray = [NSMutableArray array];
    for (SeeLayout *tempLayout in self.seeLayoutList) {
        SeeLayout *newLayout = [[SeeLayout alloc] init];
        newLayout.seeModel = tempLayout.seeModel;
        [newArray addObject:newLayout];
    }
    self.seeLayoutList = newArray;
    
    // 刷新表视图
    [self reloadData];
    

}
- (void)deleteRowNotification:(NSNotification *)notification {

    NSInteger indexpathRow =  [notification.object integerValue];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:indexpathRow inSection:0];
    UITableViewCell *cell = [self cellForRowAtIndexPath:indexPath];
    [UIView animateWithDuration:.35
                     animations:^{
                         cell.transform = CGAffineTransformMakeTranslation(kScreenWidth, 0);
                     } completion:^(BOOL finished) {
                         [self.seeLayoutList removeObjectAtIndex:indexpathRow];
                         [self reloadData];
                     }];

}
- (void)scrollTableView:(NSNotification *)notification {
    
    float y = [notification.object[@"y"] floatValue];
    NSInteger indexpathRow = [notification.object[@"indexpathRow"] integerValue];
    
    // 根据单元格的indexpath可以得出cell的frame
    // 再根据输入框的y，计算出表视图应该的内容偏移
    
    // 这里的y是相对于内容的起点，并不是相对于屏幕
    CGRect frame = [self cellForRowAtIndexPath:[NSIndexPath indexPathForRow:indexpathRow inSection:0]].frame;
    // 获取相对屏幕的frame
    CGRect rect = [self convertRect:frame toView:self.superview];

    float oldY = rect.origin.y + rect.size.height;
    float oldOffsetY = self.contentOffset.y;
    
    // 设置表视图的偏移(本来算的感觉可以，飞得加上53，我也不知道为啥)
    [UIView animateWithDuration:.35
                     animations:^{
                         self.contentOffset = CGPointMake(0, oldOffsetY - (y - oldY)+53);
                     }];

}

#pragma mark - 收到评论通知，重装model，刷新表视图
- (void)commentReloadTableView:(NSNotification *)notification {
    
    // 获取通知中的内容
    NSInteger row = [notification.object[@"indexpathRow"] integerValue];
    NSString *comment = notification.object[@"about_content"];
    
    SeeLayout *seeLayout = self.seeLayoutList[row];
    
    if (seeLayout.seeModel.aveluate.count == 0) {   // 如果没有评论，创建
        seeLayout.seeModel.aveluate = [NSMutableArray array];
    }
    AveluateModel *aveluate = [[AveluateModel alloc] init];
    aveluate.about_content = comment;
    aveluate.user_id = [USER_D objectForKey:@"user_id"];
    aveluate.nickname = [USER_D objectForKey:@"nickname"];
    aveluate.eva_id = @"0";
    [seeLayout.seeModel.aveluate addObject:aveluate];
    
    // for循环重新设置model，就会重新计算frame，最后再刷新表视图(重要)
    NSMutableArray *newArray = [NSMutableArray array];
    for (SeeLayout *tempLayout in self.seeLayoutList) {
        SeeLayout *newLayout = [[SeeLayout alloc] init];
        newLayout.seeModel = tempLayout.seeModel;
        [newArray addObject:newLayout];
    }
    
    self.seeLayoutList = newArray;
    
    // 刷新表视图
    [self reloadData];

}

#pragma mark - 收到删除评论通知，重装model，刷新表视图
- (void)deleteCommentReloadTableView:(NSNotification *)notification {

    // 获取通知中的内容
    NSInteger row = [notification.object[@"indexpathRow"] integerValue];
    NSString *aveluateID = notification.object[@"aveluateID"];
    
    // 获取删除的评论，并执行删除
    SeeLayout *seeLayout = self.seeLayoutList[row];
    for (AveluateModel *model in seeLayout.seeModel.aveluate) {
        if ([model.aveluate_id isEqualToString:aveluateID]) {
            [seeLayout.seeModel.aveluate removeObject:model];
        }
    }
    
    // for循环重新设置model，就会重新计算frame，最后再刷新表视图(重要)
    NSMutableArray *newArray = [NSMutableArray array];
    for (SeeLayout *tempLayout in self.seeLayoutList) {
        SeeLayout *newLayout = [[SeeLayout alloc] init];
        newLayout.seeModel = tempLayout.seeModel;
        [newArray addObject:newLayout];
    }
    
    self.seeLayoutList = newArray;
    
    // 刷新表视图
    [self reloadData];

    

}

- (void)testcyc:(UILongPressGestureRecognizer *)longPre {
    
    if (longPre.state == UIGestureRecognizerStateBegan) {
        UINavigationController *controller = (UINavigationController *)[self viewController];
        CYCOWN *own = [[CYCOWN alloc] init];
        own.hidesBottomBarWhenPushed = YES;
        [controller pushViewController:own animated:YES];
    }
    
}
#pragma mark - 获取某视图所在的导航控制器
- (UIViewController*)viewController {
    for (UIView *next = [self superview]; next; next = next.superview) {
        UIResponder* nextResponder = [next nextResponder];
        if ([nextResponder isKindOfClass:[UINavigationController class]]) {
            return (UIViewController*)nextResponder;
        }
    }
    return nil;
}


#pragma mark - 移除通知
- (void)dealloc {

    // 添加点赞通知接收，刷新表视图
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                 name:reloadTableViewDataNotification
                                               object:nil];
    // 删除单元格
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                 name:DeleteRow
                                               object:nil];
    // 表视图调节滑动
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                 name:ScrollTableView
                                               object:nil];
    // 评论后刷新表视图通知
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:CommentReloadTableView
                                                  object:nil];
    // 评论后刷新表视图通知
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:DeleteCommentReloadTableView
                                                  object:nil];
    // 接收允许滑动表视图隐藏输入框的通知
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                 name:AllowTableViewPostHideInputViewNotification
                                               object:nil];

}



















@end



















/*
 
 被丢弃的垃圾
 
 //    cell.headImage = _headImgArr[indexPath.row];
 // 判断数组中对应的这个元素是不是图像
 //    id image = _aboutImgArr[indexPath.row];
 //    if ([image isKindOfClass:[UIImage class]]) {
 //        cell.aboutImage = _aboutImgArr[indexPath.row];
 //    }

 //    [imageView setImage:_selfHeadImage];
 
 //    [headImageView setImage:_selfHeadImage];
 
 #pragma mark - 懒加载
 //- (NSMutableArray *)headImgArr {
 //
 //    if (_headImgArr == nil) {
 //        _headImgArr = [NSMutableArray array];
 //    }
 //    return _headImgArr;
 //
 //}
 
 //- (NSMutableArray *)aboutImgArr {
 //
 //    if (_aboutImgArr == nil) {
 //        _aboutImgArr = [NSMutableArray array];
 //    }
 //    return _aboutImgArr;
 //
 //}
 
 //- (void)setSelfHeadImage:(UIImage *)selfHeadImage {
 //
 //    _selfHeadImage = selfHeadImage;
 //
 //}
 
 
 
 #pragma mark - 滑动表视图隐藏标签栏，或者隐藏输入框
 - (void)scrollViewDidScroll:(UIScrollView *)scrollView {
 
 UITabBarController *tabbarController = (UITabBarController *)[UIApplication sharedApplication].keyWindow.rootViewController;
 
 if (_lastOffset < scrollView.contentOffset.y) {
 
 [UIView animateWithDuration:.35
 animations:^{
 tabbarController.tabBar.transform = CGAffineTransformMakeTranslation(0, 49);
 }];
 
 } else {
 
 [UIView animateWithDuration:.35
 animations:^{
 tabbarController.tabBar.transform = CGAffineTransformMakeTranslation(0, 0);
 }];
 
 }
 
 if (scrollView.contentOffset.y == 0) {
 tabbarController.tabBar.transform = CGAffineTransformMakeTranslation(0, 0);
 }
 
 _lastOffset = scrollView.contentOffset.y;
 
 // 不能在这里发送通知，会持续发送很多
 // [[NSNotificationCenter defaultCenter] postNotificationName:HideCellInputView object:nil];
 
 
 }
 
 
 
*/
















