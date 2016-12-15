//
//  PersonSeeLayout.m
//  XiaoHuiBang
//
//  Created by mac on 16/11/22.
//  Copyright © 2016年 消汇邦. All rights reserved.
//

// 个人动态单元格的布局

#import "PersonSeeLayout.h"
#import "NSString+CEmojChange.h"

#define kScreenHeight [UIScreen mainScreen].bounds.size.height  // 屏高
#define kScreenWidth [UIScreen mainScreen].bounds.size.width    // 屏宽

#define kSpace 15                                               // 控件之间的空隙
#define kCellHeight 80                                          // 单元格的默认高度
#define kTimeWidth 85.5                                         // 时间框框的宽度
#define kTimeLabelX 16                                          // 时间文本的起点X
#define kTimeLabelHeight 23.5                                   // 时间文本的高度
#define kTimeFontSize 14                                        // 时间文本字体大小
#define kImgSize 70                                             // 动态的图片的大小
#define kIsFirstSize 20                                         // 当cell是组开始的cell时的偏移
#define kEdge 5                                                 // 内容与边缘的边距离





@implementation PersonSeeLayout

- (NSMutableArray *)imageFrameArr {

    if (_imageFrameArr == nil) {
        _imageFrameArr = [NSMutableArray array];
    }
    return _imageFrameArr;
    
}


- (void)setPersonSeeModel:(PersonSeeModel *)personSeeModel {

    _personSeeModel = personSeeModel;
    
    // 这个有必要判断吗？时间标签是在第一组cell才有的
    if (_isFirst == YES) {
        _timeLabelFrame = CGRectMake(0, kIsFirstSize + kEdge, kTimeWidth, kTimeLabelHeight);
    } else {
        _timeLabelFrame = CGRectMake(0, kEdge, kTimeWidth, kTimeLabelHeight);
    }
    
    // 处理表情
    self.personSeeModel.content = [self.personSeeModel.content changeToEmoj];
    
    // 如果有照片
    // Y起点
    float startY;
    if (personSeeModel.about_img.count != 0) {
        
        // 当cell是一组的开头时，添加垂直位移
        if (_isFirst == YES) {
            startY = kIsFirstSize + kEdge;
            _cellHeight = kCellHeight + kIsFirstSize;
        } else {
            startY = kEdge;
            _cellHeight = kCellHeight;
        }
        
        if (personSeeModel.about_img.count == 1) {
            CGRect rect = CGRectMake(kTimeWidth, startY, kImgSize, kImgSize);
            NSValue *rectValue = [NSValue valueWithCGRect:rect];
            [self.imageFrameArr addObject:rectValue];
            
        } else if (personSeeModel.about_img.count == 2) {
            CGRect rectA = CGRectMake(kTimeWidth, startY, kImgSize/2.0-0.5, kImgSize);
            NSValue *rectValueA = [NSValue valueWithCGRect:rectA];
            [self.imageFrameArr addObject:rectValueA];
            CGRect rectB = CGRectMake(kTimeWidth + kImgSize/2.0+0.5, startY, kImgSize/2.0-0.5, kImgSize);
            NSValue *rectValueB = [NSValue valueWithCGRect:rectB];
            [self.imageFrameArr addObject:rectValueB];
            
        } else if (personSeeModel.about_img.count == 3) {
            CGRect rectA = CGRectMake(kTimeWidth, startY, kImgSize/2.0-0.5, kImgSize);
            NSValue *rectValueA = [NSValue valueWithCGRect:rectA];
            [self.imageFrameArr addObject:rectValueA];
            CGRect rectB = CGRectMake(kTimeWidth + kImgSize/2.0+0.5, startY, kImgSize/2.0-0.5, kImgSize/2.0-0.5);
            NSValue *rectValueB = [NSValue valueWithCGRect:rectB];
            [self.imageFrameArr addObject:rectValueB];
            CGRect rectC = CGRectMake(kTimeWidth + kImgSize/2.0+0.5, startY + kImgSize/2.0+0.5, kImgSize/2.0-0.5, kImgSize/2.0-0.5);
            NSValue *rectValueC = [NSValue valueWithCGRect:rectC];
            [self.imageFrameArr addObject:rectValueC];
            
        } else {
            CGRect rectA = CGRectMake(kTimeWidth, startY, kImgSize/2.0-0.5, kImgSize/2.0-0.5);
            NSValue *rectValueA = [NSValue valueWithCGRect:rectA];
            [self.imageFrameArr addObject:rectValueA];
            CGRect rectB = CGRectMake(kTimeWidth + kImgSize/2.0+0.5, startY, kImgSize/2.0-0.5, kImgSize/2.0-0.5);
            NSValue *rectValueB = [NSValue valueWithCGRect:rectB];
            [self.imageFrameArr addObject:rectValueB];
            CGRect rectC = CGRectMake(kTimeWidth + kImgSize/2.0+0.5, startY + kImgSize/2.0+0.5, kImgSize/2.0-0.5, kImgSize/2.0-0.5);
            NSValue *rectValueC = [NSValue valueWithCGRect:rectC];
            [self.imageFrameArr addObject:rectValueC];
            CGRect rectD = CGRectMake(kTimeWidth, startY + kImgSize/2.0+0.5, kImgSize/2.0-0.5, kImgSize/2.0-0.5);
            NSValue *rectValueD = [NSValue valueWithCGRect:rectD];
            [self.imageFrameArr addObject:rectValueD];
        }
        
        // 文字底部的颜色区
        _backgroundColorFrame = CGRectZero;
        
        // 文本
        NSString *string = _personSeeModel.content;
        CGRect rect = [string boundingRectWithSize:CGSizeMake(kScreenWidth - (kTimeWidth + kImgSize + 11.9 + kSpace), 99999)
                                           options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin
                                        attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:kTimeFontSize]}
                                           context:nil];

        if (rect.size.height > kImgSize) {
            _contentFrame = CGRectMake(kTimeWidth + kImgSize + 11.9,
                                       startY,
                                       kScreenWidth - (kTimeWidth + kImgSize + 11.9 + kSpace),
                                       kImgSize);
        } else {
            _contentFrame = CGRectMake(kTimeWidth + kImgSize + 11.9,
                                       startY,
                                       kScreenWidth - (kTimeWidth + kImgSize + 11.9 + kSpace),
                                       rect.size.height);
        }
        
        
    // 如果没有照片
    } else {
        NSString *string = _personSeeModel.content;
        CGRect rect = [string boundingRectWithSize:CGSizeMake(kScreenWidth - kTimeWidth - kSpace - 10, 99999)
                                        options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin
                                     attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:kTimeFontSize]}
                                        context:nil];
        
        // 没有图片的话，文本底部还会有灰色的框，为了使灰色的框与文字存在边距，也应该让cell高提升10,也就不至于灰色的框超出cell
        
        if (rect.size.height > kImgSize) {
            if (_isFirst == YES) {
                startY = kIsFirstSize + kEdge;
                _cellHeight = kIsFirstSize + kCellHeight + 10;
            } else {
                startY = kEdge;
                _cellHeight = kCellHeight + 10;
            }
            _contentFrame = CGRectMake(kTimeWidth + 5,
                                       startY,
                                       kScreenWidth - (kTimeWidth + kSpace) - 10,
                                       kImgSize);
            _backgroundColorFrame = CGRectMake(kTimeWidth,
                                       startY,
                                       kScreenWidth - (kTimeWidth + kSpace),
                                       kImgSize);

        } else {
            if (_isFirst == YES) {
                startY = kIsFirstSize + kEdge;
                _cellHeight = kIsFirstSize + rect.size.height + kEdge*2 + 10;
            } else {
                startY = kEdge;
                _cellHeight = rect.size.height + kEdge*2 + 10;
            }
            _contentFrame = CGRectMake(kTimeWidth + 5,
                                       startY + 5,
                                       kScreenWidth - (kTimeWidth + kSpace) - 10,
                                       rect.size.height);
            _backgroundColorFrame = CGRectMake(kTimeWidth,
                                               startY,
                                               kScreenWidth - (kTimeWidth + kSpace),
                                               rect.size.height + 10);
        }
    
    }
    
    // 时间戳转换时间
    NSDate *confromTimesp = [NSDate dateWithTimeIntervalSince1970:[_personSeeModel.create_time integerValue]];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"YYYY-MM-dd"];
    NSString *confromTimespStr = [formatter stringFromDate:confromTimesp];
    
    // 年份
    self.timeTextYear = [confromTimespStr substringWithRange:NSMakeRange(0, 4)];
    
    // 获取当前时间，判断是否是今天
    NSString *currentTime = [formatter stringFromDate:[NSDate date]];
    if ([confromTimespStr isEqualToString:currentTime]) {
        
        if (self.isFirst == YES) {
            NSMutableAttributedString *attribute = [[NSMutableAttributedString alloc] initWithString:@"今天"];
            [attribute addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:24] range:NSMakeRange(0, 2)];
            self.timeText = attribute;
            
        }
        
    } else {
        
        if (self.isFirst == YES) {
            // 富文本调节字体大小
            NSString *monthStr = [confromTimespStr substringWithRange:NSMakeRange(5, 2)];
            NSString *dayStr = [confromTimespStr substringWithRange:NSMakeRange(8, 2)];
            NSMutableAttributedString *attribute = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@%@月", dayStr, monthStr]];
            [attribute addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:24] range:NSMakeRange(0, 2)];
            [attribute addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:10] range:NSMakeRange(2, 3)];
            
            self.timeText = attribute;
        }
        
    }
    
    
    
    

}


/*
 //        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
 //        // 行间距
 //        style.lineSpacing = 13;
 // NSParagraphStyleAttributeName : style
 
 //        // 三行或三行以上
 //        if (rect.size.height+kSpace*2 > kCellHeight) {
 //            _cellHeight = kCellHeight;
 //            _contentFrame = CGRectMake(kTimeWidth,
 //                                       kSpace,
 //                                       kScreenWidth - (kTimeWidth + kSpace),
 //                                       kImgSize + kSpace);
 //            _backgroundColorFrame = CGRectMake(kTimeWidth,
 //                                       kSpace,
 //                                       kScreenWidth - (kTimeWidth + kSpace),
 //                                       kImgSize + kSpace);
 //        // 一行
 //        } else if (rect.size.height + kSpace*2 < 60) {
 //            _cellHeight = rect.size.height + kSpace*2;
 //            _contentFrame = CGRectMake(kTimeWidth,
 //                                       kSpace,
 //                                       kScreenWidth - (kTimeWidth + kSpace),
 //                                       rect.size.height + kSpace);
 //            _backgroundColorFrame = CGRectMake(kTimeWidth,
 //                                       kSpace,
 //                                       kScreenWidth - (kTimeWidth + kSpace),
 //                                       30);
 //        // 两行
 //        } else {
 //            _cellHeight = rect.size.height + kSpace*2;
 //            _contentFrame = CGRectMake(kTimeWidth,
 //                                       kSpace,
 //                                       kScreenWidth - (kTimeWidth + kSpace),
 //                                       rect.size.height + kSpace);
 //            _backgroundColorFrame = CGRectMake(kTimeWidth,
 //                                               kSpace,
 //                                               kScreenWidth - (kTimeWidth + kSpace),
 //                                               rect.size.height + kSpace);
 //            
 //        }
 
 
 */

@end
