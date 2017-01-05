//
//  SeeLayout.m
//  XiaoHuiBang
//
//  Created by mac on 16/11/14.
//  Copyright © 2016年 消汇邦. All rights reserved.
//

#import "SeeLayout.h"
#import "AveluateModel.h"
#import "NSString+CEmojChange.h"
#import <UIImageView+WebCache.h>

#define kScreenHeight [UIScreen mainScreen].bounds.size.height  // 屏高
#define kScreenWidth [UIScreen mainScreen].bounds.size.width    // 屏宽
#define kSpace 12.3                                             // 控件之间的Y空隙
#define kNickLabelHight 33.3                                    // 昵称高度，昵称下面就是动态正文
#define kContentX 66.0                                          // 正文的开始X
#define kContentY 35                                            // 正文的开始Y
#define kFontSzie 15                                            // 正文字体大小
#define kCommentFontSize 14                                     // 评论文本字体大小
#define kImgSize (kScreenWidth - 66 - 66 - 3 - 3)/3             // 图片大小
#define kDeleteButtonWidth 30                                   // 删除按钮长度
#define kTimeLabelWidth 70                                      // 时间文本的长度
#define kLocationLabelWidth (kScreenWidth - kContentY - kSpace) // 定位文本的长度
#define kTimeLabelHeight 12                                     // 时间文本的高度
#define kCommentWidth 30                                        // 评论按钮长度
#define kCommentHeight 30                                       // 评论按钮高度
#define kProWidth 30                                            // 点赞按钮的宽度
#define kProHeight 30                                           // 点赞按钮的高度

#define kProListHeight 23                                       // 点赞列表的高度
#define kCommentX 77                                            // 评论的起点X


@implementation SeeLayout


- (void)setSeeModel:(SeeModel *)seeModel {
    _seeModel = seeModel;
    
    // 单元格的高度 = 昵称文本框高度 + 空隙
    self.cellHeight = kNickLabelHight + kSpace;
    
    // 处理文本中包含有表情的情况
    self.seeModel.content = [self.seeModel.content changeToEmoj];
    
    CGRect textRect = [self.seeModel.content boundingRectWithSize:CGSizeMake(kScreenWidth - 97, 99999)
                                                          options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin
                                                       attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:kFontSzie]}
                                                          context:nil];
    // 获取动态内容文本的高度
    CGFloat contentHeight = textRect.size.height;
    // 计算动态内容文本的frame
    // 当只有一行，就根据文本宽度设置标签宽度
    if (textRect.size.height < 20) {
        self.seeFrame = CGRectMake(kContentX, kContentY, textRect.size.width, contentHeight);
    } else {
        self.seeFrame = CGRectMake(kContentX, kContentY, kScreenWidth - 97, contentHeight);
    }
    
    
    //  更新单元格的高度(不加空隙，挤一点好看)
    self.cellHeight += CGRectGetHeight(self.seeFrame);
    
    // 当携带图片
    if ([self.seeModel.type isEqualToString:@"2"]) {
        // 当动态携带一张图片时
        if (self.seeModel.about_img.count == 1) {
            SDWebImageManager *manager = [SDWebImageManager sharedManager];
            //判断是否有缓存(不要使用原图的路径判断，因为不点开查看大图就不会缓存原图)
            BOOL isExist = [manager diskImageExistsForURL:[NSURL URLWithString:_seeModel.thumb_img.firstObject]];
            if (isExist) {
                UIImage *image = [[manager imageCache] imageFromDiskCacheForKey:_seeModel.thumb_img.firstObject];
                CGSize size = image.size;
                float scale = size.width / size.height;
                // 当宽比高大
                if (scale > 1) {
                    CGRect rect = CGRectMake(kContentX, self.cellHeight, 104*scale, 104);
                    NSValue *rectValue = [NSValue valueWithCGRect:rect];
                    [self.imgFrameArr addObject:rectValue];
                    self.cellHeight += (104 + kSpace);
                } else {
                    CGRect rect = CGRectMake(kContentX, self.cellHeight, 104, 104 / scale);
                    NSValue *rectValue = [NSValue valueWithCGRect:rect];
                    [self.imgFrameArr addObject:rectValue];
                    self.cellHeight += (104 / scale + kSpace);
                }
            } else {
                CGRect rect = CGRectMake(kContentX, self.cellHeight, 104, 180);
                NSValue *rectValue = [NSValue valueWithCGRect:rect];
                [self.imgFrameArr addObject:rectValue];
                self.cellHeight += (180 + kSpace);
            }
            
            
            // 当动态携带多张图片时
        } else if (self.seeModel.about_img.count > 1 && self.seeModel.about_img.count <= 9){
            for (int i = 0; i < self.seeModel.about_img.count; i++) {
                CGRect rect = CGRectMake( kContentX + (kImgSize + 3) * (i % 3),
                                         self.cellHeight + (kImgSize + 3) * (i / 3), kImgSize, kImgSize);
                NSValue *rectValue = [NSValue valueWithCGRect:rect];
                [self.imgFrameArr addObject:rectValue];
            }
            
            // 最后确定单元格高度
            self.cellHeight += (kImgSize + 5)*((self.seeModel.about_img.count - 1) / 3 + 1) + kSpace;
        }
    }
    
    // 当携带视频
    if ([self.seeModel.type isEqualToString:@"3"]) {
        SDWebImageManager *manager = [SDWebImageManager sharedManager];
        //判断是否有缓存
        BOOL isExist = [manager diskImageExistsForURL:[NSURL URLWithString:_seeModel.movieThumb]];
        if (isExist) {
            UIImage *image = [[manager imageCache] imageFromDiskCacheForKey:_seeModel.movieThumb];
            CGSize size = image.size;
            float scale = size.width / size.height;
            // 当宽 > 高
            if (scale > 1) {
                // 当宽 >> 高
                if (scale > 2) {
                    self.movieFrame = CGRectMake(kContentX, self.cellHeight, 220, 220 / scale);
                    // 修改单元格高度
                    self.cellHeight += (220 / scale + kSpace);
                } else {
                    self.movieFrame = CGRectMake(kContentX, self.cellHeight, 104*scale, 104);
                    // 修改单元格高度
                    self.cellHeight += (104 + kSpace);
                }
            } else {
                self.movieFrame = CGRectMake(kContentX, self.cellHeight, 104, 180);
                // 修改单元格高度
                self.cellHeight += (180 + kSpace);
            }
        } else {
            self.movieFrame = CGRectMake(kContentX, self.cellHeight, 104, 180);
            // 修改单元格高度
            self.cellHeight += (180 + kSpace);
        }
    }
    
    // 定位标签
    if (_seeModel.address != nil) {
        self.locationFrame = CGRectMake(kContentX, self.cellHeight, kLocationLabelWidth, kTimeLabelHeight);
        self.cellHeight += (kTimeLabelHeight + 10);
    }
    
    
    // 删除按钮
    self.deleteFrame = CGRectMake(kContentX, self.cellHeight-5, kDeleteButtonWidth, kTimeLabelHeight);
    
    // 时间标签
    if (_seeModel.user_id == [USER_D objectForKey:@"user_id"]) {
        self.timeFrame = CGRectMake(kContentX + kDeleteButtonWidth + kSpace, self.cellHeight-5, kTimeLabelWidth, kTimeLabelHeight);
    } else {
        self.timeFrame = CGRectMake(kContentX, self.cellHeight-5, kTimeLabelWidth, kTimeLabelHeight);
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
    
    // 转换定位信息
    if (self.seeModel.address != nil) {
        NSMutableString *mStr = [NSMutableString stringWithString:self.seeModel.address];
        // 将"市"字更改为@" · "
        [mStr replaceOccurrencesOfString:@"市" withString:@" · " options:NSCaseInsensitiveSearch range:NSMakeRange(0, mStr.length)];
        self.locationText = [mStr copy];
    }
    
    
    // 评论按钮
    self.commentFrame = CGRectMake(kScreenWidth - kCommentWidth - 13, self.cellHeight - 5, kCommentWidth, kCommentHeight);
    
    // 点赞按钮
    self.proFrame = CGRectMake(kScreenWidth - kCommentWidth - 13 - kProWidth, self.cellHeight - 5, kProWidth, kProHeight);

    // 这行的内容尺寸求好了，更新单元格高度
    self.cellHeight += (12 + kSpace);

    // 点赞列表
    if (_seeModel.praise.count != 0) {
        self.proListIconFrame = CGRectMake(kContentX + 5, self.cellHeight + 5, 14.5, 13);
        self.proListLabelFrame = CGRectMake(kContentX + 5 + 20, self.cellHeight + 5, kScreenWidth - kContentX - 12.5 - 20, 13);
        self.proAndCommentFrame = CGRectMake(kContentX, self.cellHeight, kScreenWidth - kContentX - 12.5, kProListHeight);
        self.lineFrame = CGRectMake(kContentX, self.cellHeight + kProListHeight - 3, kScreenWidth - kContentX - 12.5, .5);
        if (_seeModel.aveluate.count != 0) {
            self.cellHeight += (kProListHeight + 5);
        } else {
            self.cellHeight += (kProListHeight + kSpace);
        }
        
    } else {
        self.proAndCommentFrame = CGRectMake(kContentX, self.cellHeight, kScreenWidth - kContentX - 12.5, 0);
        self.cellHeight += 5;
    }
    
    
    // 评论列表
    if (_seeModel.aveluate.count != 0) {
        
        CGFloat tempHeight = 0;
        for (int i = 0; i < _seeModel.aveluate.count; i++) {
            
            AveluateModel *aveluate = _seeModel.aveluate[i];
            // 根据评论内容来获取区域大小
            NSString *str = [NSString stringWithFormat:@"%@: %@", aveluate.nickname, aveluate.about_content];
            NSString *comment = [str changeToEmoj];
            CGRect rect = [comment boundingRectWithSize:CGSizeMake(kScreenWidth - 90, 99999)
                                                options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin
                                             attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:kCommentFontSize]}
                                                context:nil];
            // 设置这条评论的frame
            CGFloat commentHeight = rect.size.height;
            CGRect commentFrame = CGRectMake(kContentX + 5 , self.cellHeight - 3, kScreenWidth - 90, commentHeight);
            // 将计算好的frame转换成value对象，存入数组
            [self.commentListFrameArr addObject:[NSValue valueWithCGRect:commentFrame]];
            // 累计评论的高度
            tempHeight += (commentHeight + 5);
            // 重新获取单元格的高度
            self.cellHeight += (commentHeight + 5);
            
        }
        
        // 点赞+评论
        CGRect tempRect = self.proAndCommentFrame;
        tempRect.size.height += tempHeight;
        self.proAndCommentFrame = tempRect;
        
        self.cellHeight += kSpace;
        
    } else {
        self.commentListFrameArr = nil;
    }

}



#pragma mark - 储存各条评论frame的数组
- (NSMutableArray *)commentListFrameArr {

    if (_commentListFrameArr == nil) {
        _commentListFrameArr = [NSMutableArray array];
    }
    return _commentListFrameArr;

}

- (NSMutableArray *)imgFrameArr {

    if (_imgFrameArr == nil) {
        _imgFrameArr = [NSMutableArray array];
    }
    return _imgFrameArr;

}























/*
 
被丢弃的代码
 
//        self.commentsListViewFrame = CGRectMake(kCommentX, self.cellHeight, kScreenWidth - 100, 0);
 
// 评论区的frame
CGRect tempRect = self.commentsListViewFrame;
tempRect.size.height = tempHeight;
self.commentsListViewFrame = tempRect;

 
 
*/






@end
