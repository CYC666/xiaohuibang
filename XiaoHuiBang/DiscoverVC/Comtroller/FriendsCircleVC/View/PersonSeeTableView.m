//
//  PersonSeeTableView.m
//  XiaoHuiBang
//
//  Created by mac on 16/11/22.
//  Copyright © 2016年 消汇邦. All rights reserved.
//

// 显示个人动态的表视图

#import "PersonSeeTableView.h"
#import "PersonSeeCell.h"
#import <UIImageView+WebCache.h>
#import "PersonSeeLayout.h"
#import "PersonSeeModel.h"
#import "RCDPersonDetailViewController.h"
#import "AboutWithImageController.h"
#import "AboutDetialController.h"
#import "CNetTool.h"

#define kHeadImageSize kScreenWidth*0.23                        // 头像大小
#define kScreenHeight [UIScreen mainScreen].bounds.size.height  // 屏高
#define kScreenWidth [UIScreen mainScreen].bounds.size.width    // 屏宽
#define RemoveYearLabel @"RemoveYearLabel"                      // 移除年份标签


@interface PersonSeeTableView () <PersonSeeCellDelegate> {

    UIImageView *_imageView;                    // 头视图的背景视图
    
}
@property (strong, nonatomic) UILabel *yearLabel;   // 导航栏下面显示年份的标签

@end

@implementation PersonSeeTableView


- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style {

    self = [super initWithFrame:frame style:style];
    if (self != nil) {
        self.delegate = self;
        self.dataSource = self;
        self.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        // 监听是否移除年份标签
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(removeYearLabel:)
                                                     name:RemoveYearLabel
                                                   object:nil];
        
        // 创建一个标识，来确定当前动态是否跟上一个动态为同一天发布,当为0时，表示是第一个显示的第一个动态
        [USER_D setObject:@"0" forKey:@"JudgeTheSameTime"];
    }
    return self;

}

- (void)removeYearLabel:(NSNotification *)noti {

    
     [_yearLabel removeFromSuperview];
     _yearLabel = nil;

    

}

- (UILabel *)yearLabel {

    if (_yearLabel == nil) {
        _yearLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 64, kScreenWidth, 20)];
        _yearLabel.backgroundColor = [UIColor colorWithRed:238/255.0 green:238/255.0 blue:238/255.0 alpha:1];
        _yearLabel.alpha = 0;
        _yearLabel.textColor = [UIColor colorWithWhite:.7 alpha:1];
        _yearLabel.font = [UIFont systemFontOfSize:12];
        [[UIApplication sharedApplication].keyWindow addSubview:_yearLabel];
    }
    return _yearLabel;

}

#pragma maek - 代理方法
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _seeLayoutList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    PersonSeeCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"PersonSeeCell" owner:nil options:nil] lastObject];
    // 必须在设置layout之前设置代理，不然代理方法不会走
    cell.delegate = self;
    PersonSeeLayout *layout = _seeLayoutList[indexPath.row];
    cell.personSeeModelLayout = layout;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    PersonSeeLayout *layout = _seeLayoutList[indexPath.row];
    return layout.cellHeight;

}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {

    return kScreenHeight*.42;

}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {

    // 背景视图
    UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight*.4)];
    headView.backgroundColor = [UIColor whiteColor];
    
    // 背景图片
    _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight*.37)];
    [_imageView sd_setImageWithURL:[NSURL URLWithString:_headImageUrl]];
    
    _imageView.contentMode = UIViewContentModeScaleAspectFill;
    _imageView.layer.masksToBounds = YES;
    [headView addSubview:_imageView];
    
    // 遮住背景图片和第一条分割线的白视图
    UIView *whiteView = [[UIView alloc] initWithFrame:CGRectMake(0, kScreenHeight*.37, kScreenWidth, kScreenHeight*0.06)];
    whiteView.backgroundColor = [UIColor whiteColor];
    [headView addSubview:whiteView];
    
    // 头像
    UIImageView *headImageView = [[UIImageView alloc] initWithFrame:CGRectMake((kScreenWidth - kHeadImageSize)/2.0,
                                                                               (kScreenHeight*.4 - kHeadImageSize)/2.0, kHeadImageSize, kHeadImageSize)];
    [headImageView sd_setImageWithURL:[NSURL URLWithString:_headImageUrl]];
    headImageView.layer.masksToBounds = YES;
    headImageView.layer.cornerRadius = kHeadImageSize/2.0;
    headImageView.layer.borderWidth = 2.0;
    headImageView.layer.borderColor = [UIColor whiteColor].CGColor;
    headImageView.userInteractionEnabled = YES;
    [headView addSubview:headImageView];
    // 给头像添加一个手势，跳转到个人信息界面
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(jumpToPersonDetail:)];
    [headImageView addGestureRecognizer:tap];
    
    /*
    // 昵称
    UILabel *nickName = [[UILabel alloc] initWithFrame:CGRectMake((kScreenWidth - 100)/2.0,
                                                                  (kScreenHeight*.4 - kHeadImageSize)/2.0 + kHeadImageSize,
                                                                  100, 30)];
    nickName.text = _nickname;
    nickName.textAlignment = NSTextAlignmentCenter;
    nickName.textColor = [UIColor whiteColor];
    nickName.font = [UIFont systemFontOfSize:17];
    [headView addSubview:nickName];
    */
    
    return headView;

}
// 点击单元格跳转
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    PersonSeeLayout *modelLayout = _seeLayoutList[indexPath.row];
    
    // 纯文本
    if ([modelLayout.personSeeModel.type isEqualToString:@"1"]) {
    
        AboutDetialController *controller = [[AboutDetialController alloc] initWithUserID:modelLayout.personSeeModel.user_id
                                                                                        aboutID:modelLayout.personSeeModel.about_id];
        UINavigationController *selfNav = (UINavigationController *)[self viewController];        
        
        [selfNav pushViewController:controller animated:YES];
        
    // 带图片或视频
    } else {
    
        AboutWithImageController *controller = [[AboutWithImageController alloc] initWithUserID:modelLayout.personSeeModel.user_id
                                                                                        aboutID:modelLayout.personSeeModel.about_id];
        UINavigationController *selfNav = (UINavigationController *)[self viewController];
        [selfNav pushViewController:controller animated:YES];
    
    }

}

#pragma mark - 单元格编辑模式，左滑删除
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // 如果当前动态是本人的，那么添加左滑删除
    if ([_user_id isEqualToString:[USER_D objectForKey:@"user_id"]] || [[USER_D objectForKey:@"nickname"] isEqualToString:@"曹老师"]) {
        return YES;
    }
    return NO;
}
- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"删除";
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"确定要删除此条动态？"
                                                                   message:@"删除后不可恢复"
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    
    // 确定删除动态按钮
    UIAlertAction *sureAction = [UIAlertAction actionWithTitle:@"确定"
                                                         style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction * _Nonnull action) {
                                                           // 网络请求删除动态，并且删除单元格  -- -- -- SeetableView
                                                           PersonSeeLayout *layout = _seeLayoutList[indexPath.row];
                                                           NSDictionary *param = @{@"id":layout.personSeeModel.about_id};
                                                           [CNetTool deleteAboutWithParameters:param
                                                                                       success:^(id response) {
                   // 刷新表视图,网络已经删除，本地删除一次刷新就好
                   // 先让cell做动画高度为0，然后再删除
                   UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
                   [UIView animateWithDuration:.35
                                    animations:^{
                                        cell.transform = CGAffineTransformMakeTranslation(kScreenWidth, 0);
                                    } completion:^(BOOL finished) {
                                        [_seeLayoutList removeObjectAtIndex:indexPath.row];
                                        [self reloadData];
                                    }];
                   
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
    [[self viewController] presentViewController:alert animated:YES completion:nil];
    
}

#pragma mark - 头视图下拉放大的效果
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {

    // 不使用缩放，使用计算frame，改变imageview的frame
    float offset = scrollView.contentOffset.y;
    float height = kScreenHeight*.37;
    if (offset < 0) {
        
        float newHeight = height + ABS(offset);
        float newWidth = newHeight * (kScreenWidth / height);
        _imageView.frame = CGRectMake(-(newWidth - kScreenWidth)/2.0, offset, newWidth, newHeight);
        
    } else if (offset < kScreenHeight * .42) {
    
        [UIView animateWithDuration:.35
                         animations:^{
                             _yearLabel.alpha = 0;
                         }];
    
    } if (offset > kScreenHeight * .42) {
    
        [UIView animateWithDuration:.35
                         animations:^{
                             _yearLabel.alpha = 1;
                         }];
    
    }

}


#pragma mark - 懒加载
- (NSMutableArray *)seeLayoutList {

    if (_seeLayoutList == nil) {
        _seeLayoutList = [NSMutableArray array];
    }
    return _seeLayoutList;

}

#pragma mark - 点击头像跳转
- (void)jumpToPersonDetail:(UITapGestureRecognizer *)tap {

    [UIView animateWithDuration:.35
                     animations:^{
                         tap.view.transform = CGAffineTransformMakeTranslation(0, -20);
                     } completion:^(BOOL finished) {
                         [UIView animateWithDuration:.35
                                          animations:^{
                                              tap.view.transform = CGAffineTransformMakeTranslation(0, 0);
                                          } completion:^(BOOL finished) {
                                              [UIView animateWithDuration:.35
                                                               animations:^{
                                                                   tap.view.transform = CGAffineTransformMakeTranslation(0, -20);
                                                               } completion:^(BOOL finished) {
                                                                   [UIView animateWithDuration:.35
                                                                                    animations:^{
                                                                                        tap.view.transform = CGAffineTransformMakeTranslation(0, 0);
                                                                                    } completion:^(BOOL finished) {
                                                                                        
                                                                                        
        // 跳转到个人信息界面
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        RCDPersonDetailViewController *detailViewController = [storyboard instantiateViewControllerWithIdentifier:@"RCDPersonDetailViewController"];
        detailViewController.userId = _user_id;
        dispatch_async(dispatch_get_main_queue(), ^{
            UINavigationController *nav = (UINavigationController *)[self viewController];
            [nav pushViewController:detailViewController animated:YES];
        });

                                                                                        
                                                                                        
                                                                                    }];
                                                               }];
                                          }];
                     }];
    
    

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

#pragma mark - cell的代理方法，把年份传过来
- (void)getYearToTableView:(NSString *)year {

    self.yearLabel.text = [NSString stringWithFormat:@"    %@年", year];

}














// -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


// #define JudgeTheSameTime @"JudgeTheSameTime"    // 创建一个标识，来确定当前动态是否跟上一个动态为同一天发布,当为0时，表示是第一个显示的第一个动态















@end
