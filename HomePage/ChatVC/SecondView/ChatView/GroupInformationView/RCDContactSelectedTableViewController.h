//
//  RCDContactSelectedTableViewController.h
//  RCloudMessage
//
//  Created by Jue on 16/3/17.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <RongIMLib/RongIMLib.h>

@interface RCDContactSelectedTableViewController : UITableViewController

@property(nonatomic, strong) NSArray *keys;

@property(nonatomic, strong) NSMutableDictionary *allFriends;

@property(nonatomic, strong) NSArray *allKeys;

@property(nonatomic, strong) NSArray *seletedUsers;

@property(nonatomic, strong) NSString *titleStr;

@property(nonatomic, strong) NSMutableArray *addGroupMembers;

@property(nonatomic, strong) NSMutableArray *delGroupMembers;

@property(nonatomic, strong) NSString *groupId;

@property (nonatomic, assign) BOOL forCreatingGroup;

@property (nonatomic, assign) BOOL forCreatingDiscussionGroup;

@property(nonatomic, strong) NSMutableArray *addDiscussionGroupMembers;

@property(nonatomic, strong) NSString *discussiongroupId;

@property(nonatomic, strong) void (^selectUserList)(NSArray<RCUserInfo *> *selectedUserList);

@property BOOL isAllowsMultipleSelection;

@property BOOL isHideSelectedIcon;

@end
