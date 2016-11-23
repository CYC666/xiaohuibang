//
//  PersonSeeTableView.m
//  XiaoHuiBang
//
//  Created by mac on 16/11/22.
//  Copyright © 2016年 消汇邦. All rights reserved.
//

#import "PersonSeeTableView.h"
#import "PersonSeeCell.h"
#import <UIImageView+WebCache.h>
#import "PersonSeeLayout.h"
#import "PersonSeeModel.h"

#define kScreenHeight [UIScreen mainScreen].bounds.size.height  // 屏高
#define kScreenWidth [UIScreen mainScreen].bounds.size.width    // 屏宽


@implementation PersonSeeTableView


- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style {

    self = [super initWithFrame:frame style:style];
    if (self != nil) {
        self.delegate = self;
        self.dataSource = self;
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
    PersonSeeModel *model = layout.personSeeModel;
    cell.textLabel.numberOfLines = 0;
    cell.textLabel.text = model.content;
    return cell;

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    return 100;

}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {

    return kScreenHeight*.42;

}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {

    // 背景视图
    UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight*.4)];
    headView.backgroundColor = [UIColor whiteColor];
    
    // 背景图片
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight*.37)];
    [imageView sd_setImageWithURL:[NSURL URLWithString:_headImageUrl]];
    
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.layer.masksToBounds = YES;
    [headView addSubview:imageView];
    
    // 头像
    UIImageView *headImageView = [[UIImageView alloc] initWithFrame:CGRectMake(kScreenWidth - kScreenWidth*.192 - 13, kScreenHeight*.4 - kScreenWidth*.192, kScreenWidth*.192, kScreenWidth*.192)];
    [headImageView sd_setImageWithURL:[NSURL URLWithString:_headImageUrl]];
    headImageView.layer.masksToBounds = YES;
    headImageView.layer.cornerRadius = kScreenWidth*.192/2.0;
    headImageView.layer.borderWidth = 2.0;
    headImageView.layer.borderColor = [UIColor whiteColor].CGColor;
    [headView addSubview:headImageView];
    // 给头像添加一个手势，跳转到个人信息界面
    
    // 昵称
    UILabel *nickName = [[UILabel alloc] initWithFrame:CGRectMake(kScreenWidth - kScreenWidth*.192 - 13 - 100, kScreenHeight*.4 - kScreenWidth*.192/2.0 - 15, 100, 30)];
    nickName.text = _nickname;
    nickName.textColor = [UIColor whiteColor];
    nickName.font = [UIFont systemFontOfSize:17];
    [headView addSubview:nickName];
    
    return headView;

}


#pragma mark - 懒加载
- (NSMutableArray *)seeLayoutList {

    if (_seeLayoutList == nil) {
        _seeLayoutList = [NSMutableArray array];
    }
    return _seeLayoutList;

}




































@end
