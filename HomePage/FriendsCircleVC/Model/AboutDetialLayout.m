//
//  AboutDetialLayout.m
//  XiaoHuiBang
//
//  Created by mac on 16/11/30.
//  Copyright © 2016年 消汇邦. All rights reserved.
//

// 单条动态界面的布局


#import "AboutDetialLayout.h"

#define kSpace 15   // 空隙
#define kHeadImageY 20.5    // 头像起点Y
#define kHeadImageSize 44   // 头像大小
#define kNicknameX 72       // 昵称起点X
#define kNicknameWidth 100  // 昵称长度
#define kNicknameHeight 12.5  // 昵称高度
#define kContentSize 15     // 动态文本字体的大小
#define kContentY 48        // 动态文本起点Y
#define kContentRight 29.5  // 动态文本右边的距离
#define kImageSize 79       // 图片的大小
#define kDeleteWidth 30     // 删除按钮宽度
#define kDeleteHeight 12.5  // 删除按钮高度
#define kTimeWidth 43.5     // 时间文本的宽度
#define kProRight 46        // 点赞按钮右边距离
#define kProWidth 30        // 点赞按钮宽度
#define kProHeight 14       // 点赞按钮高度
#define kCommentRight 12      // 评论按钮右边距离
#define kCommengWidth 30  // 评论按钮宽度
#define kCommentHeight 14.5 // 评论按钮高度

#define kScreenHeight [UIScreen mainScreen].bounds.size.height  // 屏高
#define kScreenWidth [UIScreen mainScreen].bounds.size.width    // 屏宽



@implementation AboutDetialLayout

- (NSMutableArray *)proImageFrameArray {

    if (_proImageFrameArray == nil) {
        _proImageFrameArray = [NSMutableArray array];
    }
    return _proImageFrameArray;

}

- (NSMutableArray *)commentFrameArray {

    if (_commentFrameArray == nil) {
        _commentFrameArray = [NSMutableArray array];
    }
    return _commentFrameArray;
    
}


- (void)setSeeModel:(SeeModel *)seeModel {

    _seeModel = seeModel;
    
    // 头像
    self.headImageFrame = CGRectMake(kSpace, kHeadImageY, kHeadImageSize, kHeadImageSize);
    
    // 昵称
    self.nicknameFrame = CGRectMake(kNicknameX, kHeadImageY, kNicknameWidth, kNicknameHeight);
    
    // 动态文本
    CGRect textRect = [seeModel.content boundingRectWithSize:CGSizeMake(kScreenWidth - kNicknameX - kContentRight, 99999)
                                                          options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin
                                                       attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:kContentSize]}
                                                          context:nil];
    self.contentFrame = CGRectMake(kNicknameX, kContentY, kScreenWidth - kNicknameX - kContentRight, textRect.size.height);
    
    self.viewHeight = kContentY + textRect.size.height;
    
    // 动态的图片
    if (![_seeModel.about_img isEqualToString:@"0"]) {
        self.imageFrame = CGRectMake(kNicknameX, self.viewHeight + 8.5, kImageSize, kImageSize);
        self.viewHeight += (kImageSize + 8.5);
    }
    
    // 删除按钮
    if ([_seeModel.user_id isEqualToString:[USER_D objectForKey:@"user_id"]]) {
        self.deleteButtonFrame = CGRectMake(kNicknameX, self.viewHeight + 11, kDeleteWidth, kDeleteHeight);
        self.timeLabelFrame = CGRectMake(kNicknameX + kDeleteWidth + 12, self.viewHeight + 11, kTimeWidth, kDeleteHeight);
    } else {
        self.timeLabelFrame = CGRectMake(kNicknameX, self.viewHeight + 11, kTimeWidth, kDeleteHeight);
    }
    
    // 将原始时间戳，转换成过去时间
    NSString *create_time = self.seeModel.create_time;
    NSInteger overTime = [[NSDate date] timeIntervalSince1970] - [create_time integerValue];
    NSInteger countTime = overTime / 60;
    if (countTime >= 0 && countTime < 60) {
        self.timeText = [NSString stringWithFormat:@"%ld分钟前", countTime];
    } else {
        countTime = countTime / 60;
        if (countTime >= 0 && countTime < 24) {
            self.timeText = [NSString stringWithFormat:@"%ld小时前", countTime];
        } else {
            countTime = countTime / 24;
            self.timeText = [NSString stringWithFormat:@"%ld天前", countTime];
        }
    }
    
    // 点赞按钮
    self.proButtonFrame = CGRectMake(kScreenWidth - kProRight - kProWidth, self.viewHeight + 11, kProWidth, kProHeight);
    
    // 评论按钮
    self.commentButtonFrame = CGRectMake(kScreenWidth - kCommentRight - kCommengWidth, self.viewHeight + 11, kCommengWidth, kCommentHeight);
    
    
    
    
    

}






































@end
