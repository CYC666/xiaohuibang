//
//  AboutDetialLayout.m
//  XiaoHuiBang
//
//  Created by mac on 16/11/30.
//  Copyright © 2016年 消汇邦. All rights reserved.
//

// 单条动态界面的布局


#import "AboutDetialLayout.h"
#import "AveluateModel.h"
#import "NSString+CEmojChange.h"
#import <UIImageView+WebCache.h>

#define kSpace 15           // 空隙
#define kHeadImageY 20.5    // 头像起点Y
#define kHeadImageSize 44   // 头像大小
#define kNicknameX 72       // 昵称起点X
#define kNicknameWidth 100  // 昵称长度
#define kNicknameHeight 12.5// 昵称高度
#define kContentSize 15     // 动态文本字体的大小
#define kContentY 48        // 动态文本起点Y
#define kContentRight 29.5  // 动态文本右边的距离
#define kImageSize (kScreenWidth - kNicknameX - 20 - 5 - 5)/3       // 图片的大小
#define kDeleteWidth 30     // 删除按钮宽度
#define kDeleteHeight 12.5  // 删除按钮高度
#define kTimeWidth 70      // 时间文本的宽度
#define kLocationWidth 250  // 定位标签的宽度
#define kProRight 46        // 点赞按钮右边距离
#define kProWidth 30        // 点赞按钮宽度
#define kProHeight 14       // 点赞按钮高度
#define kCommentRight 12    // 评论按钮右边距离
#define kCommengWidth 30    // 评论按钮宽度
#define kCommentHeight 14.5 // 评论按钮高度
#define kProDetialImageWidth 29     // 点赞列表图标的宽度
#define kProDetialImageHeight 29    // 点赞列表图标的高度
#define kProDetialImageSize 29      // 点赞列表头像的大小
#define kCommentDetialImageWidth 14.5   // 评论列表图标的宽度
#define kCommentDetialImageHeight 12.5  // 评论列表图标的高度
#define kCommentFontSize 14             // 评论文字的大小

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

- (NSMutableArray *)imageFrameArr {

    if (_imageFrameArr == nil) {
        _imageFrameArr = [NSMutableArray array];
    }
    return _imageFrameArr;

}


- (void)setSeeModel:(SeeModel *)seeModel {

    _seeModel = seeModel;
    
    // 头像
    self.headImageFrame = CGRectMake(kSpace, kHeadImageY, kHeadImageSize, kHeadImageSize);
    
    // 昵称
    self.nicknameFrame = CGRectMake(kNicknameX, kHeadImageY, kNicknameWidth, kNicknameHeight);
    
    // 处理文本携带表情的情况
    self.seeModel.content = [self.seeModel.content changeToEmoj];
    
    // 动态文本
    CGRect textRect = [seeModel.content boundingRectWithSize:CGSizeMake(kScreenWidth - kNicknameX - kContentRight, 99999)
                                                          options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin
                                                       attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:kContentSize]}
                                                          context:nil];
    // 当只有一行,就调整文本标签长度,适应文字长度
    if (textRect.size.height < 20) {
        self.contentFrame = CGRectMake(kNicknameX, kContentY, textRect.size.width, textRect.size.height);
    } else {
        self.contentFrame = CGRectMake(kNicknameX, kContentY, kScreenWidth - kNicknameX - kContentRight, textRect.size.height);
    }
    
    
    self.viewHeight = kContentY + textRect.size.height;
    
    // 携带图片
    if ([_seeModel.type isEqualToString:@"2"]) {
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
                    if (104*scale < (kScreenWidth - kNicknameX - kProRight)) {
                        CGRect rect = CGRectMake(kNicknameX, self.viewHeight + 5, 104*scale, 104);
                        NSValue *rectValue = [NSValue valueWithCGRect:rect];
                        [self.imageFrameArr addObject:rectValue];
                        self.viewHeight += (104+10);
                    } else {
                        CGRect rect = CGRectMake(kNicknameX, self.viewHeight + 5, kScreenWidth - kNicknameX - kProRight, 104);
                        NSValue *rectValue = [NSValue valueWithCGRect:rect];
                        [self.imageFrameArr addObject:rectValue];
                        self.viewHeight += (104+10);
                    }
                    
                } else {
                    CGRect rect = CGRectMake(kNicknameX, self.viewHeight + 5, 104, 104 / scale);
                    NSValue *rectValue = [NSValue valueWithCGRect:rect];
                    [self.imageFrameArr addObject:rectValue];
                    self.viewHeight += ((104/scale) + 10);
                }
            } else {
                CGRect rect = CGRectMake(kNicknameX, self.viewHeight + 10, 104, 180);
                NSValue *rectValue = [NSValue valueWithCGRect:rect];
                [self.imageFrameArr addObject:rectValue];
                self.viewHeight += (180 + kSpace);
            }
            
            // 当动态携带多张图片时
        } else if (self.seeModel.about_img.count > 1 && self.seeModel.about_img.count <= 9){
            for (int i = 0; i < self.seeModel.about_img.count; i++) {
                CGRect rect = CGRectMake( kNicknameX + (kImageSize + 5) * (i % 3),
                                         self.viewHeight + 10 + (kImageSize + 5) * (i / 3), kImageSize, kImageSize);
                NSValue *rectValue = [NSValue valueWithCGRect:rect];
                [self.imageFrameArr addObject:rectValue];
            }
            
            // 最后确定单元格高度
            self.viewHeight += (kImageSize + 5)*((self.seeModel.about_img.count - 1) / 3 + 1) + 10;
        }
        
    // 携带电影
    } else if ([_seeModel.type isEqualToString:@"3"]) {
        
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
                    self.movieFrame = CGRectMake(kNicknameX, self.viewHeight + 5, 220, 220 / scale);
                    // 修改单元格高度
                    self.viewHeight += (220 / scale + 10);
                } else {
                    self.movieFrame = CGRectMake(kNicknameX, self.viewHeight + 5, 104*scale, 104);
                    // 修改单元格高度
                    self.viewHeight += (104 + 10);
                }
            } else {
                self.movieFrame = CGRectMake(kNicknameX, self.viewHeight + 5, 104, 180);
                // 修改单元格高度
                self.viewHeight += (180 + 10);
            }
        } else {
            self.movieFrame = CGRectMake(kNicknameX, self.viewHeight + 5, 104, 180);
            // 修改单元格高度
            self.viewHeight += (180 + 10);
        }
        
    }
    
    
    
    // 定位标签
    if (_seeModel.address != nil) {
        self.locationLabelFrame = CGRectMake(kNicknameX, self.viewHeight + 10, kLocationWidth, kDeleteHeight);
        self.viewHeight += (kDeleteHeight + 10);
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
    
    // 转换定位信息
    if (self.seeModel.address != nil) {
        NSMutableString *mStr = [NSMutableString stringWithString:self.seeModel.address];
        // 将"市"字更改为@" · "
        [mStr replaceOccurrencesOfString:@"市" withString:@" · " options:NSCaseInsensitiveSearch range:NSMakeRange(0, mStr.length)];
        self.locationText = [mStr copy];
    }
    
    // 点赞按钮
    self.proButtonFrame = CGRectMake(kScreenWidth - kProRight - kProWidth + 6, self.viewHeight + 11, kProWidth, kProHeight);
    
    // 评论按钮
    self.commentButtonFrame = CGRectMake(kScreenWidth - kCommentRight - kCommengWidth + 6, self.viewHeight + 11, kCommengWidth, kCommentHeight);
    self.viewHeight += 39;
    // 设一个值来记录当前的高度
    float tempHeight = self.viewHeight;
    
    // 计算每行应该放多少个点赞人的头像
    NSInteger headImageCount = (kScreenWidth - kNicknameX - 53 - kCommentRight) / (kProDetialImageSize + 7.7);
    self.headImageCount = headImageCount;
    if (_seeModel.praise.count > 0) {
        // 点赞详情的图标
        self.proDetialImageFrame = CGRectMake(kNicknameX + 12, self.viewHeight + 6.5, kProDetialImageWidth, kProDetialImageHeight);
        // 点赞人数列表的frame
        for (int i = 0; i < _seeModel.praise.count; i++) {
            CGRect rect = CGRectMake(kNicknameX + 53 + (kProDetialImageSize + 7.7)*(i % headImageCount),
                                     self.viewHeight + 6.5 + (kProDetialImageSize + 7.7)*(i / headImageCount),
                                     kProDetialImageSize,
                                     kProDetialImageSize);
            NSValue *value = [NSValue valueWithCGRect:rect];
            [self.proImageFrameArray addObject:value];
        }
        self.viewHeight += (kProDetialImageSize + 7.7)*(_seeModel.praise.count/headImageCount + 1) + 7.7;
        // 评论与点赞的分割线
        self.proLineFrame = CGRectMake(kNicknameX, self.viewHeight, kScreenWidth - kNicknameX - kCommentRight, .7);
    }
    
    if (_seeModel.aveluate.count > 0) {
        // 评论列表
        for (int i = 0; i < _seeModel.aveluate.count; i++) {
            // 根据评论内容计算高度
            AveluateModel *aveluateModel = _seeModel.aveluate[i];
            
            NSString *comment = [aveluateModel.about_content changeToEmoj];
            CGRect rect = [comment boundingRectWithSize:CGSizeMake(kScreenWidth - (kNicknameX + 52.5 + kCommentRight) - 5, 99999)
                                                options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin
                                             attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:kCommentFontSize]}
                                            context:nil];
            CGRect imageRect = CGRectMake(kNicknameX + 12,
                                          self.viewHeight + 11.5,
                                          kProDetialImageSize,
                                          kProDetialImageSize);
            CGRect nicknameRect = CGRectMake(kNicknameX + 53,
                                             self.viewHeight + 8,
                                             kNicknameWidth,
                                             kNicknameHeight);
            CGRect contentRect = CGRectMake(kNicknameX + 53,
                                            self.viewHeight + 29.5,
                                            kScreenWidth - (kNicknameX + 53 + kCommentRight) - 5,
                                            rect.size.height);
            CGRect lineRect = CGRectMake(kNicknameX + 37.5,
                                         self.viewHeight + 29.5 + rect.size.height + 5,
                                         kScreenWidth - (kNicknameX + 37.5 + kCommentRight),
                                         .7);
            // 将frame封装成对象，再存入字典，最后把字典存到数组中
            NSValue *imageValue = [NSValue valueWithCGRect:imageRect];
            NSValue *nicknameValue = [NSValue valueWithCGRect:nicknameRect];
            NSValue *contentValue = [NSValue valueWithCGRect:contentRect];
            NSValue *lineValue = [NSValue valueWithCGRect:lineRect];
            NSDictionary *dic = @{@"image":imageValue,
                                  @"nickname":nicknameValue,
                                  @"content":contentValue,
                                  @"line":lineValue};
            [self.commentFrameArray addObject:dic];
            
            // 刷新高度
            self.viewHeight += (29.5 + rect.size.height + 8);
        }
//        self.viewHeight += kSpace;
        
    }
    
    self.proAndCommentBackgroundFrame = CGRectMake(kNicknameX, tempHeight, kScreenWidth - kNicknameX - kCommentRight, self.viewHeight - tempHeight);
    

}






































@end
