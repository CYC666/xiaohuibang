//
//  MyChatConversationViewController.m
//  XiaoHuiBang
//
//  Created by 消汇邦 on 2016/10/21.
//  Copyright © 2016年 消汇邦. All rights reserved.
//

#import "MyChatConversationViewController.h"

#import "RCDPrivateSettingsTableViewController.h"

#import "RCDGroupSettingsTableViewController.h"

#import "RCDPersonDetailViewController.h"
#import "RCDAddFriendViewController.h"

#import "RCDUtilities.h"
#import "RCDHttpTool.h"
#import "RCDataBaseManager.h"
#import "RCDUserInfoManager.h"

#import "RealTimeLocationEndCell.h"
#import "RealTimeLocationStartCell.h"
#import "RealTimeLocationStatusView.h"
#import "RealTimeLocationViewController.h"

#import "RCDTestMessage.h"
#import "RCDTestMessageCell.h"

@interface MyChatConversationViewController () <UIActionSheetDelegate, RCRealTimeLocationObserver, RealTimeLocationStatusViewDelegate, UIAlertViewDelegate,RCMessageCellDelegate>

@property(nonatomic, weak) id<RCRealTimeLocationProxy> realTimeLocation;
@property(nonatomic, strong) RealTimeLocationStatusView *realTimeLocationStatusView;

@property(nonatomic, strong) RCDGroupInfo *groupInfo;

@end

NSMutableDictionary *userInputStatus;

@implementation MyChatConversationViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSString *userInputStatusKey = [NSString stringWithFormat:@"%lu--%@",(unsigned long)self.conversationType,self.targetId];
    if (userInputStatus && [userInputStatus.allKeys containsObject:userInputStatusKey]) {
        KBottomBarStatus inputType = (KBottomBarStatus)[userInputStatus[userInputStatusKey] integerValue];
        //输入框记忆功能，如果退出时是语音输入，再次进入默认语音输入
        if (inputType == KBottomBarRecordStatus) {
            self.defaultInputType = RCChatSessionInputBarInputVoice;
        }else if (inputType == KBottomBarPluginStatus){
            //      self.defaultInputType = RCChatSessionInputBarInputExtention;
        }
    }
    [self refreshTitle];
}

//- (void)viewWillDisappear:(BOOL)animated {
//    [super viewWillDisappear:animated];
//    KBottomBarStatus inputType = self.chatSessionInputBarControl.currentBottomBarStatus;
//    if (!userInputStatus) {
//        userInputStatus = [NSMutableDictionary new];
//    }
//    NSString *userInputStatusKey = [NSString stringWithFormat:@"%lu--%@",(unsigned long)self.conversationType,self.targetId];
//    [userInputStatus setObject:[NSString stringWithFormat:@"%ld",(long)inputType]  forKey:userInputStatusKey];
//}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.delegate = nil;
    }
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(0, 6, 87, 23);
    UIImageView *backImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_back"]];
    backImg.frame = CGRectMake(-6, 4, 10, 17);
    [backBtn addSubview:backImg];
    UILabel *backText = [[UILabel alloc] initWithFrame:CGRectMake(9,4, 85, 17)];
    backText.text = @"消信";
    [backText setBackgroundColor:[UIColor clearColor]];
    [backText setTextColor:[UIColor whiteColor]];
    [backBtn addSubview:backText];
    [backBtn addTarget:self action:@selector(toBackButtonClickInfo:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    [self.navigationItem setLeftBarButtonItem:leftButton];
    
//    NSLog(@"%@",self.targetId);
    
    if (self.conversationType == ConversationType_PRIVATE) {
        UIButton *privateButton = [UIButton buttonWithType:UIButtonTypeCustom];
//        [releaseButton setTitle:@"确定" forState:UIControlStateNormal];
        privateButton.frame = CGRectMake(0, 0, 22, 22);
        [privateButton setBackgroundImage:[UIImage imageNamed:@"icon_profile"] forState:UIControlStateNormal];
        [privateButton addTarget:self action:@selector(privateButtonClickInfo:) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *privateButtonItem = [[UIBarButtonItem alloc] initWithCustomView:privateButton];
        self.navigationItem.rightBarButtonItem = privateButtonItem;
    } else if (self.conversationType == ConversationType_GROUP) {
        UIButton *groupButton = [UIButton buttonWithType:UIButtonTypeCustom];
        //        [releaseButton setTitle:@"确定" forState:UIControlStateNormal];
        groupButton.frame = CGRectMake(0, 0, 24, 20);
        [groupButton setBackgroundImage:[UIImage imageNamed:@"icon_groupdetails"] forState:UIControlStateNormal];
        [groupButton addTarget:self action:@selector(groupButtonClickInfo:) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *groupButtonItem = [[UIBarButtonItem alloc] initWithCustomView:groupButton];
        self.navigationItem.rightBarButtonItem = groupButtonItem;
    } else {
        
    }
    self.enableSaveNewPhotoToLocalSystem = YES;
    
    [self registerClass:[RealTimeLocationStartCell class]
        forMessageClass:[RCRealTimeLocationStartMessage class]];
    [self registerClass:[RealTimeLocationEndCell class]
        forMessageClass:[RCRealTimeLocationEndMessage class]];
    
    __weak typeof(&*self) weakSelf = self;
    [[RCRealTimeLocationManager sharedManager] getRealTimeLocationProxy:self.conversationType
                                                               targetId:self.targetId
                                                                success:^(id<RCRealTimeLocationProxy> realTimeLocation) {
                                                                    weakSelf.realTimeLocation = realTimeLocation;
                                                                    [weakSelf.realTimeLocation addRealTimeLocationObserver:self];
                                                                    [weakSelf updateRealTimeLocationStatus];
                                                                }
                                                                  error:^(RCRealTimeLocationErrorCode status) {
                                                                      NSLog(@"get location share failure with code %d", (int)status);
                                                                  }];
    
    ///注册自定义测试消息Cell
    [self registerClass:[RCDTestMessageCell class]
        forMessageClass:[RCDTestMessage class]];
    
    [self notifyUpdateUnreadMessageCount];
    
    //刷新个人或群组的信息
    [self refreshUserInfoOrGroupInfo];
    
    //群组改名之后，更新当前页面的Title
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(renameGroupName:)
                                                 name:@"renameGroupName"
                                               object:nil];
    
    //群组改名之后，更新当前页面的Title
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(clearHistoryMSG:)
                                                 name:@"ClearHistoryMsg"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(updateForSharedMessageInsertSuccess:)
     name:@"RCDSharedMessageInsertSuccess"
     object:nil];
}

- (void)updateForSharedMessageInsertSuccess:(NSNotification *)notification {
    RCMessage *message = notification.object;
    if (message.conversationType == self.conversationType &&
        [message.targetId isEqualToString:self.targetId]) {
        [self appendAndDisplayMessage:message];
    }
}

- (void)refreshUserInfoOrGroupInfo {
    //打开单聊强制从demo server 获取用户信息更新本地数据库
    if (self.conversationType == ConversationType_PRIVATE) {
        if (![self.targetId isEqualToString:[RCIM sharedRCIM].currentUserInfo.userId]) {
            __weak typeof(self) weakSelf = self;
            [[RCDRCIMDataSource shareInstance]
             getUserInfoWithUserId:self.targetId
             completion:^(RCUserInfo *userInfo) {
                 [[RCDHttpTool shareInstance] updateUserInfo:weakSelf.targetId
                                                     success:^(RCDUserInfo *user) {
                                                         RCUserInfo *updatedUserInfo = [[RCUserInfo alloc] init];
                                                         updatedUserInfo.userId = user.userId;
                                                         if (user.displayName.length > 0) {
                                                             updatedUserInfo.name = user.displayName;
                                                         } else {
                                                             updatedUserInfo.name = user.name;
                                                         }
                                                         updatedUserInfo.portraitUri = user.portraitUri;
                                                         weakSelf.navigationItem.title = updatedUserInfo.name;
                                                         [[RCIM sharedRCIM] refreshUserInfoCache:updatedUserInfo withUserId: updatedUserInfo.userId];
                                                     }
                                                     failure:^(NSError *err){
                                                         
                                                     }];
             }];
        }
    }
    //打开群聊强制从demo server 获取群组信息更新本地数据库
    if (self.conversationType == ConversationType_GROUP) {
        __weak typeof(self) weakSelf = self;
        [RCDHTTPTOOL getGroupByID:self.targetId
                successCompletion:^(RCDGroupInfo *group) {
                    RCGroup *Group = [[RCGroup alloc] initWithGroupId:weakSelf.targetId groupName:group.groupName portraitUri:group.portraitUri];
                    [[RCIM sharedRCIM] refreshGroupInfoCache:Group withGroupId:weakSelf.targetId];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        [weakSelf refreshTitle];
                    });
                }];
    }
    //更新群组成员用户信息的本地缓存
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSMutableArray *groupList = [[RCDataBaseManager shareInstance] getGroupMember:self.targetId];
        NSArray *resultList = [[RCDUserInfoManager shareInstance] getFriendInfoList:groupList];
        groupList = [[NSMutableArray alloc] initWithArray:resultList];
       for (RCUserInfo *user in groupList) {
            if ([user.portraitUri isEqualToString:@""]) {
                user.portraitUri = [RCDUtilities defaultUserPortrait:user];
            }
            if ([user.portraitUri hasPrefix:@"file:///"]) {
                NSString *filePath = [RCDUtilities getIconCachePath:[NSString
                                                                     stringWithFormat:@"user%@.png", user.userId]];
                if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
                    NSURL *portraitPath = [NSURL fileURLWithPath:filePath];
                    user.portraitUri = [portraitPath absoluteString];
                } else {
                    user.portraitUri = [RCDUtilities defaultUserPortrait:user];
                }
            }
            [[RCIM sharedRCIM] refreshUserInfoCache:user withUserId:user.userId];
        }
    });
}

- (void)toBackButtonClickInfo:(UIButton *)button {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)privateButtonClickInfo:(UIButton *)button {
    UIStoryboard *secondStroyBoard =
    [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    RCDPrivateSettingsTableViewController *settingsVC =
    [secondStroyBoard instantiateViewControllerWithIdentifier:
     @"RCDPrivateSettingsTableViewController"];
    
    settingsVC.userId = self.targetId;
    
    [self.navigationController pushViewController:settingsVC animated:YES];
}

- (void)groupButtonClickInfo:(UIButton *)button {
    RCDGroupSettingsTableViewController *settingsVC = [RCDGroupSettingsTableViewController groupSettingsTableViewController];
    
    NSLog(@"%@~!!!!!!~!~!~!~~~~~%@",_groupInfo,self.targetId);
    
    if (_groupInfo == nil) {
        settingsVC.Group = [[RCDataBaseManager shareInstance] getGroupByGroupId:self.targetId];
    } else {
        settingsVC.Group = _groupInfo;
    }
    [self.navigationController pushViewController:settingsVC animated:YES];
}

- (void)refreshTitle {
//    if (self.userName == nil) {
//        return;
//    }
    int count = [[[RCDataBaseManager shareInstance] getGroupByGroupId:self.targetId].number intValue];
    if (self.conversationType == ConversationType_GROUP && count > 0) {
        
        UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 40)];
        title.text = [NSString stringWithFormat:@"%@(%d)",[[RCDataBaseManager shareInstance] getGroupByGroupId:self.targetId].groupName,count];
        title.textAlignment = NSTextAlignmentCenter;
        title.textColor = [UIColor whiteColor];
        self.navigationItem.titleView = title;
        
    } else {
        UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 40)];
        title.text = [[RCDataBaseManager shareInstance] getGroupByGroupId:self.targetId].groupName;
        title.textAlignment = NSTextAlignmentCenter;
        title.textColor = [UIColor whiteColor];
        self.navigationItem.titleView = title;
    }
}

/**
 *  更新左上角未读消息数
 */
- (void)notifyUpdateUnreadMessageCount {
    __weak typeof(&*self) __weakself = self;
    int count = [[RCIMClient sharedRCIMClient] getUnreadCount:@[
                                                                @(ConversationType_PRIVATE),
                                                                @(ConversationType_DISCUSSION),
                                                                @(ConversationType_APPSERVICE),
                                                                @(ConversationType_PUBLICSERVICE),
                                                                @(ConversationType_GROUP)
                                                                ]];
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *backString = nil;
        if (count > 0 && count < 1000) {
            backString = [NSString stringWithFormat:@"消信(%d)", count];
        } else if (count >= 1000) {
            backString = @"消信(...)";
        } else {
            backString = @"消信";
        }
        UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        backBtn.frame = CGRectMake(0, 6, 87, 23);
        UIImageView *backImg = [[UIImageView alloc]
                                initWithImage:[UIImage imageNamed:@"icon_back"]];
        backImg.frame = CGRectMake(-6, 4, 10, 17);
        [backBtn addSubview:backImg];
        UILabel *backText =
        [[UILabel alloc] initWithFrame:CGRectMake(9, 4, 85, 17)];
        backText.text = backString; // NSLocalizedStringFromTable(@"Back",
        // @"RongCloudKit", nil);
        //   backText.font = [UIFont systemFontOfSize:17];
        [backText setBackgroundColor:[UIColor clearColor]];
        [backText setTextColor:[UIColor whiteColor]];
        [backBtn addSubview:backText];
        [backBtn addTarget:__weakself
                    action:@selector(toBackButtonClickInfo:)
          forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *leftButton =
        [[UIBarButtonItem alloc] initWithCustomView:backBtn];
        [__weakself.navigationItem setLeftBarButtonItem:leftButton];
    });
}

- (void)didTapCellPortrait:(NSString *)userId {
    
    if (self.conversationType == ConversationType_GROUP || self.conversationType == ConversationType_DISCUSSION) {
        
        NSLog(@"%@~~~~~~~~%@",userId,[RCIM sharedRCIM].currentUserInfo.userId);
        
        if (![userId isEqualToString:[RCIM sharedRCIM].currentUserInfo.userId]) {
            [[RCDUserInfoManager shareInstance] getFriendInfo:userId
                                                   completion:^(RCUserInfo *user) {
                                                       
                                                       [[RCIM sharedRCIM] refreshUserInfoCache:user
                                                                                    withUserId:user.userId];
                                                       
                                                       [self gotoNextPage:user];
                                                   }];
        } else {
            [[RCDUserInfoManager shareInstance] getUserInfo:userId
                                                 completion:^(RCUserInfo *user) {
                                                     [[RCIM sharedRCIM] refreshUserInfoCache:user
                                                                                  withUserId:user.userId];
                                                     
                                                     [self gotoNextPage:user];
                                                 }];
        }
    } if (self.conversationType == ConversationType_PRIVATE) {
        [[RCDUserInfoManager shareInstance] getUserInfo:userId
                                             completion:^(RCUserInfo *user) {
                                                 [[RCIM sharedRCIM]
                                                  refreshUserInfoCache:user
                                                  withUserId:user.userId];
                                                 [self gotoNextPage:user];
                                             }];
    }
}

- (void)gotoNextPage:(RCUserInfo *)user {
    
    NSArray *friendList = [[RCDataBaseManager shareInstance] getAllFriends];
    BOOL isGotoDetailView = NO;
    for (RCDUserInfo *friend in friendList) {
        if ([user.userId isEqualToString:friend.userId] && [friend.status isEqualToString:@"1"]) {
            
            isGotoDetailView = YES;
        } else if ([user.userId isEqualToString:[RCIM sharedRCIM].currentUserInfo.userId]) {
            isGotoDetailView = YES;
        }
        NSLog(@"%@~~~~%i~~~~~~%@",friend,isGotoDetailView,friend.status);
    }
    

    if (isGotoDetailView == YES) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        RCDPersonDetailViewController *detailViewController = [storyboard instantiateViewControllerWithIdentifier:@"RCDPersonDetailViewController"];
        detailViewController.userId = user.userId;
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self.navigationController pushViewController:detailViewController animated:YES];
        });
    } else {
        UIStoryboard *mainStoryboard =
        [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        RCDAddFriendViewController *addViewController = [mainStoryboard instantiateViewControllerWithIdentifier:@"RCDAddFriendViewController"];
        
        NSLog(@"%@",user.userId);
        
        addViewController.targetUserInfo = user;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.navigationController pushViewController:addViewController animated:YES];
        });
    }
}

- (void)setRealTimeLocation:(id<RCRealTimeLocationProxy>)realTimeLocation {
    _realTimeLocation = realTimeLocation;
}

- (void)pluginBoardView:(RCPluginBoardView *)pluginBoardView
     clickedItemWithTag:(NSInteger)tag {
    switch (tag) {
        case PLUGIN_BOARD_ITEM_LOCATION_TAG: {
            if (self.realTimeLocation) {
                UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                              initWithTitle:nil
                                              delegate:self
                                              cancelButtonTitle:@"取消"
                                              destructiveButtonTitle:nil
                                              otherButtonTitles:@"发送位置", @"位置实时共享", nil];
                [actionSheet showInView:self.view];
            } else {
                [super pluginBoardView:pluginBoardView clickedItemWithTag:tag];
            }
        } break;
        default:
            [super pluginBoardView:pluginBoardView clickedItemWithTag:tag];
            break;
    }
}

- (RealTimeLocationStatusView *)realTimeLocationStatusView {
    if (!_realTimeLocationStatusView) {
        _realTimeLocationStatusView = [[RealTimeLocationStatusView alloc]
                                       initWithFrame:CGRectMake(0, 62, self.view.frame.size.width, 0)];
        _realTimeLocationStatusView.delegate = self;
        [self.view addSubview:_realTimeLocationStatusView];
    }
    return _realTimeLocationStatusView;
}

#pragma mark - RealTimeLocationStatusViewDelegate
- (void)onJoin {
    [self showRealTimeLocationViewController];
}
- (RCRealTimeLocationStatus)getStatus {
    return [self.realTimeLocation getStatus];
}

- (void)onShowRealTimeLocationView {
    [self showRealTimeLocationViewController];
}
- (RCMessageContent *)willSendMessage:(RCMessageContent *)messageCotent {
    //可以在这里修改将要发送的消息
    if ([messageCotent isMemberOfClass:[RCTextMessage class]]) {
        // RCTextMessage *textMsg = (RCTextMessage *)messageCotent;
        // textMsg.extra = @"";
    }
    return messageCotent;
}
//      xkskskkxkdsjksdiwkl0292s-s-=zxslxslsx
/*******************实时地理位置共享***************/
- (void)showRealTimeLocationViewController {
    RealTimeLocationViewController *lsvc =
    [[RealTimeLocationViewController alloc] init];
    lsvc.realTimeLocationProxy = self.realTimeLocation;
    if ([self.realTimeLocation getStatus] ==
        RC_REAL_TIME_LOCATION_STATUS_INCOMING) {
        [self.realTimeLocation joinRealTimeLocation];
    } else if ([self.realTimeLocation getStatus] ==
               RC_REAL_TIME_LOCATION_STATUS_IDLE) {
        [self.realTimeLocation startRealTimeLocation];
    }
    [self.navigationController presentViewController:lsvc
                                            animated:YES
                                          completion:^{
                                              
                                          }];
}

- (void)updateRealTimeLocationStatus {
    if (self.realTimeLocation) {
        [self.realTimeLocationStatusView updateRealTimeLocationStatus];
        __weak typeof(&*self) weakSelf = self;
        NSArray *participants = nil;
        switch ([self.realTimeLocation getStatus]) {
            case RC_REAL_TIME_LOCATION_STATUS_OUTGOING:
                [self.realTimeLocationStatusView updateText:@"你正在共享位置"];
                break;
            case RC_REAL_TIME_LOCATION_STATUS_CONNECTED:
            case RC_REAL_TIME_LOCATION_STATUS_INCOMING:
                participants = [self.realTimeLocation getParticipants];
                if (participants.count == 1) {
                    NSString *userId = participants[0];
                    [weakSelf.realTimeLocationStatusView
                     updateText:[NSString
                                 stringWithFormat:@"user<%@>正在共享位置", userId]];
                    [[RCIM sharedRCIM]
                     .userInfoDataSource
                     getUserInfoWithUserId:userId
                     completion:^(RCUserInfo *userInfo) {
                         if (userInfo.name.length) {
                             dispatch_async(dispatch_get_main_queue(), ^{
                                 [weakSelf.realTimeLocationStatusView
                                  updateText:[NSString stringWithFormat:
                                              @"%@正在共享位置",
                                              userInfo.name]];
                             });
                         }
                     }];
                } else {
                    if (participants.count < 1)
                        [self.realTimeLocationStatusView removeFromSuperview];
                    else
                        [self.realTimeLocationStatusView
                         updateText:[NSString stringWithFormat:@"%d人正在共享地理位置",
                                     (int)participants.count]];
                }
                break;
            default:
                break;
        }
    }
}


#pragma mark override
- (void)didTapMessageCell:(RCMessageModel *)model {
    [super didTapMessageCell:model];
    if ([model.content isKindOfClass:[RCRealTimeLocationStartMessage class]]) {
        [self showRealTimeLocationViewController];
    }
}

- (NSArray<UIMenuItem *> *)getLongTouchMessageCellMenuList:(RCMessageModel *)model {
    NSMutableArray<UIMenuItem *> *menuList = [[super getLongTouchMessageCellMenuList:model] mutableCopy];
    /*
     在这里添加删除菜单。
     [menuList enumerateObjectsUsingBlock:^(UIMenuItem * _Nonnull obj, NSUInteger
     idx, BOOL * _Nonnull stop) {
     if ([obj.title isEqualToString:@"删除"] || [obj.title
     isEqualToString:@"delete"]) {
     [menuList removeObjectAtIndex:idx];
     *stop = YES;
     }
     }];
     UIMenuItem *forwardItem = [[UIMenuItem alloc] initWithTitle:@"转发"
     action:@selector(onForwardMessage:)];
     [menuList addObject:forwardItem];
     
     如果您不需要修改，不用重写此方法，或者直接return［super
     getLongTouchMessageCellMenuList:model]。
     */
    return menuList;
}

#pragma mark override
- (void)resendMessage:(RCMessageContent *)messageContent {
    if ([messageContent isKindOfClass:[RCRealTimeLocationStartMessage class]]) {
        [self showRealTimeLocationViewController];
    } else {
        [super resendMessage:messageContent];
    }
}
#pragma mark - UIActionSheet Delegate
- (void)actionSheet:(UIActionSheet *)actionSheet
clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0: {
            [super pluginBoardView:self.pluginBoardView clickedItemWithTag:PLUGIN_BOARD_ITEM_LOCATION_TAG];
        } break;
        case 1: {
            [self showRealTimeLocationViewController];
        } break;
    }
}

- (void)willPresentActionSheet:(UIActionSheet *)actionSheet {
    SEL selector = NSSelectorFromString(@"_alertController");
    
    if ([actionSheet respondsToSelector:selector]) {
        UIAlertController *alertController =
        [actionSheet valueForKey:@"_alertController"];
        if ([alertController isKindOfClass:[UIAlertController class]]) {
            alertController.view.tintColor = [UIColor blackColor];
        }
    } else {
        for (UIView *subView in actionSheet.subviews) {
            if ([subView isKindOfClass:[UIButton class]]) {
                UIButton *btn = (UIButton *)subView;
                [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            }
        }
    }
}

- (void)leftBarButtonItemPressed:(id)sender {
    if ([self.realTimeLocation getStatus] ==
        RC_REAL_TIME_LOCATION_STATUS_OUTGOING ||
        [self.realTimeLocation getStatus] ==
        RC_REAL_TIME_LOCATION_STATUS_CONNECTED) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                            message:@"离开聊天，位置共享也会结束，确认离开"
                                                           delegate:self
                                                  cancelButtonTitle:@"取消"
                                                  otherButtonTitles:@"确定", nil];
        [alertView show];
    } else {
        [self popupChatViewController];
    }
}

/**
 *  打开大图。开发者可以重写，自己下载并且展示图片。默认使用内置controller
 *
 *
 */
- (void)presentImagePreviewController:(RCMessageModel *)model {
    RCImageSlideController *previewController = [[RCImageSlideController alloc] init];
    previewController.messageModel = model;
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:previewController];
    [self.navigationController presentViewController:nav animated:YES completion:nil];
}

- (void)saveNewPhotoToLocalSystemAfterSendingSuccess:(UIImage *)newImage {
    //保存图片
    UIImage *image = newImage;
    UIImageWriteToSavedPhotosAlbum( image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    
}

- (void)didLongTouchMessageCell:(RCMessageModel *)model inView:(UIView *)view {
    [super didLongTouchMessageCell:model inView:view];
    NSLog(@"%s", __FUNCTION__);
}

- (void)popupChatViewController {
    [super leftBarButtonItemPressed:nil];
    [self.realTimeLocation removeRealTimeLocationObserver:self];
    if (_needPopToRootView == YES) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)renameGroupName:(NSNotification *)notification {
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 40)];
    title.text = [notification object];
    title.textAlignment = NSTextAlignmentCenter;
    title.textColor = [UIColor whiteColor];
    self.navigationItem.titleView = title;
}

- (void)clearHistoryMSG:(NSNotification *)notification {
    [self.conversationDataRepository removeAllObjects];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.conversationMessageCollectionView reloadData];
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
