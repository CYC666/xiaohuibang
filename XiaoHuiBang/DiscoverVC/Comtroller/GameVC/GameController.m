//
//  GameController.m
//  XiaoHuiBang
//
//  Created by mac on 2017/1/9.
//  Copyright © 2017年 消汇邦. All rights reserved.
//

#import "GameController.h"
#import "DiscoverCell.h"
#import "F3HNumberTileGameViewController.h"
#import "ColorGameController.h"
#import "CWebController.h"

#define kScreenHeight [UIScreen mainScreen].bounds.size.height                          // 屏高
#define kScreenWidth [UIScreen mainScreen].bounds.size.width                            // 屏宽


@interface GameController () <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) UITableView *enumTable;

@end

@implementation GameController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.view.backgroundColor = [UIColor colorWithRed:238/255.0 green:238/255.0 blue:238/255.0 alpha:1];
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 40)];
    title.text = @"探索";
    title.font = [UIFont boldSystemFontOfSize:19];
    title.textAlignment = NSTextAlignmentCenter;
    title.textColor = [UIColor whiteColor];
    self.navigationItem.titleView = title;
    
    // 创建子视图表视图
    _enumTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight-64)
                                              style:UITableViewStyleGrouped];
    _enumTable.backgroundColor = [UIColor clearColor];
    _enumTable.delegate = self;
    _enumTable.dataSource = self;
    [self.view addSubview:_enumTable];
    
}



#pragma mark - 表视图代理方法
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    DiscoverCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"DiscoverCell" owner:self options:nil] firstObject];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    if (indexPath.row == 0) {
        cell.title.text = @"2048";
        cell.leftImage.image = [UIImage imageNamed:@"icon_discover_game"];
    } else if (indexPath.row == 1) {
        cell.title.text = @"找邦币";
        cell.leftImage.image = [UIImage imageNamed:@"ColorGame"];
    } else {
        cell.title.text = @"更多游戏";
    }
    return cell;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 15;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 5;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    if (indexPath.row == 0) {
        F3HNumberTileGameViewController *game2048controller = [F3HNumberTileGameViewController numberTileGameWithDimension:4     // 行列数目
                                                                              winThreshold:512  // 目标得分
                                                                           backgroundColor:[UIColor whiteColor]
                                                                             swipeControls:YES];
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:game2048controller];
        nav.navigationBar.barTintColor = [UIColor colorWithRed:254/255.0 green:127/255.0 blue:47/255.0 alpha:1];
        nav.navigationBar.tintColor = [UIColor whiteColor];
        nav.navigationBar.translucent = NO;
        [self presentViewController:nav animated:YES completion:nil];
        
    } else if (indexPath.row == 1) {
        ColorGameController *controller = [[ColorGameController alloc] init];
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:controller];
        nav.navigationBar.barTintColor = [UIColor colorWithRed:254/255.0 green:127/255.0 blue:47/255.0 alpha:1];
        nav.navigationBar.tintColor = [UIColor whiteColor];
        nav.navigationBar.translucent = NO;
        [self presentViewController:nav animated:YES completion:nil];
    } else {
        CWebController *controller = [[CWebController alloc] initWithModelName:@"小游戏" url:@"http://www.meiriq.com/list/302da1ab"];
        controller.allowGesture = YES;
        controller.allowRightItem = YES;
        controller.isModel = YES;
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:controller];
        [self presentViewController:nav animated:YES completion:nil];
        
    }
    
    
    
    // 选中之后，让单元格处于取消选中的状态，比较好看
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.selected = NO;

}

































@end
