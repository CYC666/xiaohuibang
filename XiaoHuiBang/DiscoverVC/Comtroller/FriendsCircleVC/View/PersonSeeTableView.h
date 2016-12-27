//
//  PersonSeeTableView.h
//  XiaoHuiBang
//
//  Created by mac on 16/11/22.
//  Copyright © 2016年 消汇邦. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface PersonSeeTableView : UITableView <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) NSMutableArray *seeLayoutList;    // 储存动态和布局的数组
@property (copy, nonatomic) NSString *user_id;                  // 此人的id
@property (copy, nonatomic) NSString *headImageUrl;             // 此人头像URL
@property (copy, nonatomic) NSString *nickname;                 // 此人的头像




@end
