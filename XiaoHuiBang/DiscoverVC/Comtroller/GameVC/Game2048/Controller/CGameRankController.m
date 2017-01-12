//
//  CGameRankController.m
//  XiaoHuiBang
//
//  Created by mac on 2017/1/12.
//  Copyright © 2017年 消汇邦. All rights reserved.
//

#import "CGameRankController.h"
#import "CNetTool.h"
#import "CGameRankModel.h"

@interface CGameRankController ()

@end

@implementation CGameRankController

- (void)viewDidLoad {

    self.view.backgroundColor = [UIColor orangeColor];
    // 请求排行榜数据
    NSDictionary *params = @{@"type" : @1};
    [CNetTool loadBestRankWithParameters:params
                                 success:^(id response) {
                                     if ([response[@"msg"] isEqual:@1]) {
                                         NSDictionary *data = response[@"data"];
                                     }
                                 } failure:^(NSError *err) {
                                     [SVProgressHUD dismiss];
                                     [SVProgressHUD showErrorWithStatus:@"获取排行榜失败"];
                                     [self.navigationController popViewControllerAnimated:YES];
                                 }];

}






































@end
