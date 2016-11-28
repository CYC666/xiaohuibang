//
//  PersonSeeLayout.m
//  XiaoHuiBang
//
//  Created by mac on 16/11/22.
//  Copyright © 2016年 消汇邦. All rights reserved.
//

#import "PersonSeeLayout.h"

#define kScreenHeight [UIScreen mainScreen].bounds.size.height  // 屏高
#define kScreenWidth [UIScreen mainScreen].bounds.size.width    // 屏宽

#define kSpace 15               // 控件之间的空隙
#define kCellHeight 100          // 单元格的默认高度
#define kTimeWidth 85.5         // 时间框框的宽度
#define kTimeLabelX 16          // 时间文本的起点X
#define kTimeLabelHeight 23.5   // 时间文本的高度
#define kTimeFontSize 14        // 时间文本字体大小

#define kImgSize 64             // 动态的图片的大小





@implementation PersonSeeLayout


- (void)setPersonSeeModel:(PersonSeeModel *)personSeeModel {

    _personSeeModel = personSeeModel;
    
    _timeLabelFrame = CGRectMake(0, kSpace, kTimeWidth, kTimeLabelHeight);
    
    // 如果有照片
    if (![personSeeModel.about_img isEqualToString:@"0"]) {
        _cellHeight = kCellHeight;
        _aboutImageFrame = CGRectMake(kTimeWidth, kSpace, kImgSize, kImgSize);
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
        // 当文本高度加空隙大于默认单元格高度
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
