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
#define kCellHeight 100                                         // 单元格的默认高度
#define kTimeWidth 85.5                                         // 时间框框的宽度
#define kTimeLabelX 16                                          // 时间文本的起点X
#define kTimeLabelHeight 23.5                                   // 时间文本的高度
#define kTimeFontSize 14                                        // 时间文本字体大小
#define kImgSize 64                                             // 动态的图片的大小






@implementation PersonSeeLayout

- (NSMutableArray *)imageFrameArr {

    if (_imageFrameArr == nil) {
        _imageFrameArr = [NSMutableArray array];
    }
    return _imageFrameArr;

}


- (void)setPersonSeeModel:(PersonSeeModel *)personSeeModel {

    _personSeeModel = personSeeModel;
    
    _timeLabelFrame = CGRectMake(0, kSpace, kTimeWidth, kTimeLabelHeight);
    // 处理表情
    self.personSeeModel.content = [self.personSeeModel.content changeToEmoj];
    
    // 如果有照片
    if (personSeeModel.about_img.count != 0) {
        _cellHeight = kCellHeight;
        // _aboutImageFrame = CGRectMake(kTimeWidth, kSpace, kImgSize, kImgSize);
        
        if (personSeeModel.about_img.count == 1) {
            CGRect rect = CGRectMake(kTimeWidth, kSpace, kImgSize, kImgSize);
            NSValue *rectValue = [NSValue valueWithCGRect:rect];
            [self.imageFrameArr addObject:rectValue];
            
        } else if (personSeeModel.about_img.count == 2) {
            CGRect rectA = CGRectMake(kTimeWidth, kSpace, kImgSize/2.0-0.5, kImgSize);
            NSValue *rectValueA = [NSValue valueWithCGRect:rectA];
            [self.imageFrameArr addObject:rectValueA];
            CGRect rectB = CGRectMake(kTimeWidth + kImgSize/2.0+0.5, kSpace, kImgSize/2.0-0.5, kImgSize);
            NSValue *rectValueB = [NSValue valueWithCGRect:rectB];
            [self.imageFrameArr addObject:rectValueB];
            
        } else if (personSeeModel.about_img.count == 3) {
            CGRect rectA = CGRectMake(kTimeWidth, kSpace, kImgSize/2.0-0.5, kImgSize);
            NSValue *rectValueA = [NSValue valueWithCGRect:rectA];
            [self.imageFrameArr addObject:rectValueA];
            CGRect rectB = CGRectMake(kTimeWidth + kImgSize/2.0+0.5, kSpace, kImgSize/2.0-0.5, kImgSize/2.0-0.5);
            NSValue *rectValueB = [NSValue valueWithCGRect:rectB];
            [self.imageFrameArr addObject:rectValueB];
            CGRect rectC = CGRectMake(kTimeWidth + kImgSize/2.0+0.5, kSpace + kImgSize/2.0+0.5, kImgSize/2.0-0.5, kImgSize/2.0-0.5);
            NSValue *rectValueC = [NSValue valueWithCGRect:rectC];
            [self.imageFrameArr addObject:rectValueC];
            
        } else {
            CGRect rectA = CGRectMake(kTimeWidth, kSpace, kImgSize/2.0-0.5, kImgSize/2.0-0.5);
            NSValue *rectValueA = [NSValue valueWithCGRect:rectA];
            [self.imageFrameArr addObject:rectValueA];
            CGRect rectB = CGRectMake(kTimeWidth + kImgSize/2.0+0.5, kSpace, kImgSize/2.0-0.5, kImgSize/2.0-0.5);
            NSValue *rectValueB = [NSValue valueWithCGRect:rectB];
            [self.imageFrameArr addObject:rectValueB];
            CGRect rectC = CGRectMake(kTimeWidth + kImgSize/2.0+0.5, kSpace + kImgSize/2.0+0.5, kImgSize/2.0-0.5, kImgSize/2.0-0.5);
            NSValue *rectValueC = [NSValue valueWithCGRect:rectC];
            [self.imageFrameArr addObject:rectValueC];
            CGRect rectD = CGRectMake(kTimeWidth, kSpace + kImgSize/2.0+0.5, kImgSize/2.0-0.5, kImgSize/2.0-0.5);
            NSValue *rectValueD = [NSValue valueWithCGRect:rectD];
            [self.imageFrameArr addObject:rectValueD];
        }
        
        
        
        
        _contentFrame = CGRectMake(kTimeWidth + kImgSize + 11.9,
                                   kSpace/2,
                                   kScreenWidth - (kTimeWidth + kImgSize + 11.9 + kSpace),
                                   kImgSize + kSpace);
//        _backgroundColorFrame = CGRectMake(kTimeWidth + kImgSize + 11.9,
//                                   kSpace,
//                                   kScreenWidth - (kTimeWidth + kImgSize + 11.9 + kSpace),
//                                   kImgSize);
        _backgroundColorFrame = CGRectZero;
        
    // 如果没有照片
    } else {
        NSString *string = _personSeeModel.content;
        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
        // 行间距
        style.lineSpacing = 13;
        CGRect rect = [string boundingRectWithSize:CGSizeMake(kScreenWidth - kTimeWidth - kSpace, 99999)
                                        options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin
                                     attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:kTimeFontSize],
                                                  NSParagraphStyleAttributeName : style}
                                        context:nil];
        // 三行或三行以上
        if (rect.size.height+kSpace*2 > kCellHeight) {
            _cellHeight = kCellHeight;
            _contentFrame = CGRectMake(kTimeWidth,
                                       kSpace,
                                       kScreenWidth - (kTimeWidth + kSpace),
                                       kImgSize + kSpace);
            _backgroundColorFrame = CGRectMake(kTimeWidth,
                                       kSpace,
                                       kScreenWidth - (kTimeWidth + kSpace),
                                       kImgSize + kSpace);
        // 一行
        } else if (rect.size.height + kSpace*2 < 60) {
            _cellHeight = rect.size.height + kSpace*2;
            _contentFrame = CGRectMake(kTimeWidth,
                                       kSpace,
                                       kScreenWidth - (kTimeWidth + kSpace),
                                       rect.size.height + kSpace);
            _backgroundColorFrame = CGRectMake(kTimeWidth,
                                       kSpace,
                                       kScreenWidth - (kTimeWidth + kSpace),
                                       30);
        // 两行
        } else {
            _cellHeight = rect.size.height + kSpace*2;
            _contentFrame = CGRectMake(kTimeWidth,
                                       kSpace,
                                       kScreenWidth - (kTimeWidth + kSpace),
                                       rect.size.height + kSpace);
            _backgroundColorFrame = CGRectMake(kTimeWidth,
                                               kSpace,
                                               kScreenWidth - (kTimeWidth + kSpace),
                                               rect.size.height + kSpace);
            
        }
    
    }
    
    
    
    
    

}


@end
