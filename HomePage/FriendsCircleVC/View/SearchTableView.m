//
//  SearchTableView.m
//  XiaoHuiBang
//
//  Created by mac on 16/12/2.
//  Copyright © 2016年 消汇邦. All rights reserved.
//

// 显示搜索动态的结果的表视图


#import "SearchTableView.h"
#import "PersonSeeCell.h"
#import "AboutDetialController.h"
#import "AboutWithImageController.h"

#define kScreenHeight [UIScreen mainScreen].bounds.size.height  // 屏高
#define kScreenWidth [UIScreen mainScreen].bounds.size.width    // 屏宽

#define RemoveSearchBar @"RemoveSearchBar"  // 移除输入框的通知

@implementation SearchTableView

- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style controller:(UIViewController *)controller {
    
    self = [super initWithFrame:frame style:style];
    if (self != nil) {
        self.delegate = self;
        self.dataSource = self;
        self.controller = controller;
    }
    return self;
    
}

#pragma maek - 代理方法
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _seeLayoutList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    PersonSeeCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"PersonSeeCell" owner:nil options:nil] lastObject];
    PersonSeeLayout *layout = _seeLayoutList[indexPath.row];
    cell.personSeeModelLayout = layout;
    return cell;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    PersonSeeLayout *layout = _seeLayoutList[indexPath.row];
    return layout.cellHeight;
    
}

// 点击单元格跳转
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    PersonSeeLayout *modelLayout = _seeLayoutList[indexPath.row];
    
    // 如果没有图片
    if ([modelLayout.personSeeModel.about_img isEqualToString:@"0"]) {
        
        AboutDetialController *controller = [[AboutDetialController alloc] initWithUserID:modelLayout.personSeeModel.user_id
                                                                                  aboutID:modelLayout.personSeeModel.about_id];
        UINavigationController *selfNav = _controller.navigationController;
        
        [selfNav pushViewController:controller animated:YES];
        
    // 有图片
    } else {
        
        AboutWithImageController *controller = [[AboutWithImageController alloc] initWithUserID:modelLayout.personSeeModel.user_id
                                                                                        aboutID:modelLayout.personSeeModel.about_id];
        UINavigationController *selfNav = _controller.navigationController;
        [selfNav pushViewController:controller animated:YES];
        
    }
    
    // 发送通知移除搜索动态的UI
    [[NSNotificationCenter defaultCenter] postNotificationName:RemoveSearchBar object:nil];
    
}


#pragma mark - 懒加载
- (NSMutableArray *)seeLayoutList {
    
    if (_seeLayoutList == nil) {
        _seeLayoutList = [NSMutableArray array];
    }
    return _seeLayoutList;
    
}




































@end
