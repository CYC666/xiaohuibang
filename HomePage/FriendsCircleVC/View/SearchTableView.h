//
//  SearchTableView.h
//  XiaoHuiBang
//
//  Created by mac on 16/12/2.
//  Copyright © 2016年 消汇邦. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchTableView : UITableView <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) NSMutableArray *seeLayoutList;    // 储存动态和布局的数组
@property (strong, nonatomic) UIViewController *controller;     // 所在控制器之上

- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style controller:(UIViewController *)controller;


@end
