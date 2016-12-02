//
//  PersonSeeCell.m
//  XiaoHuiBang
//
//  Created by mac on 16/11/22.
//  Copyright © 2016年 消汇邦. All rights reserved.
//

#import "PersonSeeCell.h"
#import <UIImageView+WebCache.h>

@implementation PersonSeeCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

#pragma mark - 懒加载
- (UILabel *)timeLabel {

    if (_timeLabel == nil) {
        _timeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _timeLabel.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:_timeLabel];
    }
    return _timeLabel;

}
- (UIImageView *)aboutImageView {

    if (_aboutImageView == nil) {
        _aboutImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _aboutImageView.clipsToBounds = YES;
        _aboutImageView.contentMode = UIViewContentModeScaleAspectFill;
        [self.contentView addSubview:_aboutImageView];
    }
    return _aboutImageView;

}
- (UIView *)backgroundColor {
    
    if (_backgroundColor == nil) {
        _backgroundColor = [[UIView alloc] initWithFrame:CGRectZero];
        _backgroundColor.backgroundColor = [UIColor colorWithRed:238/255.0 green:238/255.0 blue:238/255.0 alpha:1];
        [self.contentView addSubview:_backgroundColor];
    }
    return _backgroundColor;

}
- (UILabel *)contentLabel {

    if (_contentLabel == nil) {
        _contentLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _contentLabel.numberOfLines = 0;
        _contentLabel.font = [UIFont systemFontOfSize:14];
        [self.contentView addSubview:_contentLabel];
    }
    return _contentLabel;

}


#pragma mark -
- (void)setPersonSeeModelLayout:(PersonSeeLayout *)personSeeModelLayout {

    _personSeeModelLayout = personSeeModelLayout;
    
    // 设置时间
    self.timeLabel.frame = _personSeeModelLayout.timeLabelFrame;
    NSInteger time = [[NSDate date] timeIntervalSince1970] - [_personSeeModelLayout.personSeeModel.create_time integerValue];
    NSInteger countTime = time / (60*60);
    if (countTime < 24) {
        _timeLabel.text = @"今天";
        _timeLabel.font = [UIFont boldSystemFontOfSize:20];
    } else {
        // 时间戳转换时间
        NSDate *confromTimesp = [NSDate dateWithTimeIntervalSince1970:[_personSeeModelLayout.personSeeModel.create_time integerValue]];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateStyle:NSDateFormatterMediumStyle];
        [formatter setTimeStyle:NSDateFormatterShortStyle];
        [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
        NSString *confromTimespStr = [formatter stringFromDate:confromTimesp];
        // 富文本调节字体大小
        NSString *monthStr = [confromTimespStr substringWithRange:NSMakeRange(5, 2)];
        NSString *dayStr = [confromTimespStr substringWithRange:NSMakeRange(8, 2)];
        NSMutableAttributedString *attribute = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@%@月", dayStr, monthStr]];
        [attribute addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:24] range:NSMakeRange(0, 2)];
        [attribute addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:10] range:NSMakeRange(2, 3)];
        _timeLabel.attributedText = attribute;
    }
    
    // 设置图片（如果有的话）
    if (![_personSeeModelLayout.personSeeModel.about_img isEqualToString:@"0"]) {
        self.aboutImageView.frame = _personSeeModelLayout.aboutImageFrame;
        [_aboutImageView sd_setImageWithURL:[NSURL URLWithString:_personSeeModelLayout.personSeeModel.thumb_img]];
    }
    
    if (_hideBackgroundColor == NO) {
        // 背景颜色框
        self.backgroundColor.frame = _personSeeModelLayout.backgroundColorFrame;
    }
    
    
    
    // 设置动态文本,设置行间距
    self.contentLabel.frame = _personSeeModelLayout.contentFrame;
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:_personSeeModelLayout.personSeeModel.content];
    NSMutableParagraphStyle *paragrah = [[NSMutableParagraphStyle alloc] init];
    if ([_personSeeModelLayout.personSeeModel.about_img isEqualToString:@"0"]) {
        paragrah.lineSpacing = 13;
    } else {
        paragrah.lineSpacing = 5;
    }
    NSRange range = NSMakeRange(0, string.length);
    [string addAttribute:NSParagraphStyleAttributeName value:paragrah range:range];
    _contentLabel.attributedText = string;
    
    
    
}






































- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
