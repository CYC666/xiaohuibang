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

#define kHeadImageSize kScreenWidth*0.23                        // 头像大小
#define kScreenHeight [UIScreen mainScreen].bounds.size.height  // 屏高
#define kScreenWidth [UIScreen mainScreen].bounds.size.width    // 屏宽



@interface PersonSeeTableView () {

    UIImageView *_imageView;                    // 头视图的背景视图

}

@end

@implementation PersonSeeTableView


- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style {

    self = [super initWithFrame:frame style:style];
    if (self != nil) {
        self.delegate = self;
        self.dataSource = self;
        self.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        // 创建一个标识，来确定当前动态是否跟上一个动态为同一天发布,当为0时，表示是第一个显示的第一个动态
        [USER_D setObject:@"0" forKey:@"JudgeTheSameTime"];
    }
    return self;

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
    
    // 如果没有图片
    if (modelLayout.personSeeModel.about_img.count == 0) {
    
        AboutDetialController *controller = [[AboutDetialController alloc] initWithUserID:modelLayout.personSeeModel.user_id
                                                                                        aboutID:modelLayout.personSeeModel.about_id];
        UINavigationController *selfNav = (UINavigationController *)[self viewController];        
        
        [selfNav pushViewController:controller animated:YES];
        
    // 有图片
    } else {
    
        AboutWithImageController *controller = [[AboutWithImageController alloc] initWithUserID:modelLayout.personSeeModel.user_id
                                                                                        aboutID:modelLayout.personSeeModel.about_id];
        UINavigationController *selfNav = (UINavigationController *)[self viewController];
        [selfNav pushViewController:controller animated:YES];
    
    }

}

// 头视图下拉放大的效果
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {

    // 不使用缩放，使用计算frame，改变imageview的frame
    float offset = scrollView.contentOffset.y;
    float height = kScreenHeight*.37;
    
    if (offset < 0) {
        
        float newHeight = height + ABS(offset);
        float newWidth = newHeight * (kScreenWidth / height);
        _imageView.frame = CGRectMake(-(newWidth - kScreenWidth)/2.0, offset, newWidth, newHeight);
        
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













// -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


// #define JudgeTheSameTime @"JudgeTheSameTime"    // 创建一个标识，来确定当前动态是否跟上一个动态为同一天发布,当为0时，表示是第一个显示的第一个动态















@end
