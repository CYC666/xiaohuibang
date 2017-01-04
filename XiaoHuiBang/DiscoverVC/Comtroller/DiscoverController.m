//
//  DiscoverController.m
//  XiaoHuiBang
//
//  Created by mac on 16/12/27.
//  Copyright © 2016年 消汇邦. All rights reserved.
//



#import "DiscoverController.h"
#import "DiscoverCell.h"
#import "FriendsCircleViewController.h"
#import "ColorGameController.h"
#import "ExpressHumanController.h"
#import "XHBController.h"
#import "ZhangYueController.h"
#import "CWebController.h"




#define kScreenHeight [UIScreen mainScreen].bounds.size.height                          // 屏高
#define kScreenWidth [UIScreen mainScreen].bounds.size.width                            // 屏宽



@interface DiscoverController () <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) UITableView *enumTable;
@property (strong, nonatomic) FriendsCircleViewController *friendsCycleController;  // 全局的朋友圈控制器

@end

@implementation DiscoverController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.translucent = NO;
    
    //push子界面后的返回按钮
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
    backItem.title = @"探索";
    self.navigationItem.backBarButtonItem = backItem;
    
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
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 2) {
        return 3;
    } else if (section == 1) {
        return 2;
    } else {
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    DiscoverCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"DiscoverCell" owner:self options:nil] firstObject];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    if (indexPath.section == 0) {
        cell.title.text = @"邦友圈";
        cell.leftImage.image = [UIImage imageNamed:@"icon_moments_unselected"];
    } else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            cell.title.text = @"ColorGame";
            cell.leftImage.image = [UIImage imageNamed:@"ColorGame"];
        } else {
            cell.title.text = @"告白小人";
            cell.leftImage.image = [UIImage imageNamed:@"ExpressHuman"];
        }
    } else if (indexPath.section == 2) {
        if (indexPath.row == 0) {
            cell.title.text = @"掌阅书城";
        } else if (indexPath.row == 1) {
            cell.title.text = @"京东商城";
        } else if (indexPath.row == 2) {
            cell.title.text = @"邦富金";
        }
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

    if (indexPath.section == 0) {
        if (_friendsCycleController == nil) {
            _friendsCycleController = [[FriendsCircleViewController alloc] init];
            _friendsCycleController.hidesBottomBarWhenPushed = YES;
        }
        [self.navigationController pushViewController:_friendsCycleController animated:YES];
        
    } else if (indexPath.section == 1 && indexPath.row == 0) {
        ColorGameController *controller = [[ColorGameController alloc] initWithNibName:@"ColorGameController"
                                                                                bundle:[NSBundle mainBundle]];
        controller.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:controller animated:YES];
    } else if (indexPath.section == 1 && indexPath.row == 1) {
        ExpressHumanController *controller = [[ExpressHumanController alloc] init];
        controller.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:controller animated:YES];
    } else if (indexPath.section == 2 && indexPath.row == 0) {
        CWebController *controller = [[CWebController alloc] initWithName:@"掌阅书城" url:@"http://m2.ireader.com/"];
        controller.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:controller animated:YES];
    } else if (indexPath.section == 2 && indexPath.row == 1) {
        CWebController *controller = [[CWebController alloc] initWithName:@"京东商城" url:@"https://wqs.jd.com/portal/wx/portal_indexV4.shtml?PTAG=17007.13.1&ptype=1"];
        controller.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:controller animated:YES];
    }
    
    // 选中之后，让单元格处于取消选中的状态，比较好看
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.selected = NO;

}






































@end
