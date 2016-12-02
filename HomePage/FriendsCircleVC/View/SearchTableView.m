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

#define kScreenHeight [UIScreen mainScreen].bounds.size.height  // 屏高
#define kScreenWidth [UIScreen mainScreen].bounds.size.width    // 屏宽


@implementation SearchTableView

- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style {
    
    self = [super initWithFrame:frame style:style];
    if (self != nil) {
        self.delegate = self;
        self.dataSource = self;
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

#pragma mark - 懒加载
- (NSMutableArray *)seeLayoutList {
    
    if (_seeLayoutList == nil) {
        _seeLayoutList = [NSMutableArray array];
    }
    return _seeLayoutList;
    
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



































@end
