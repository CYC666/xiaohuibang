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
-(UITextView *)contentText {

    if (_contentText == nil) {
        _contentText = [[UITextView alloc] initWithFrame:CGRectZero];
        _contentText.font = [UIFont systemFontOfSize:14];
        [self.contentView addSubview:_contentText];
    }
    return _contentText;

}


#pragma mark -
- (void)setPersonSeeModelLayout:(PersonSeeLayout *)personSeeModelLayout {

    _personSeeModelLayout = personSeeModelLayout;
    
    // 设置时间
    self.timeLabel.frame = _personSeeModelLayout.timeLabelFrame;
    
    self.timeLabel.attributedText = _personSeeModelLayout.timeText;
    
    // 年份,传到tableView
    [self.delegate getYearToTableView:_personSeeModelLayout.timeTextYear];
    
    // 如果是图片动态
    if ([_personSeeModelLayout.personSeeModel.type isEqualToString:@"2"]) {
        
        for (int i = 0; i < _personSeeModelLayout.imageFrameArr.count; i++) {
            
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:[_personSeeModelLayout.imageFrameArr[i] CGRectValue]];
            NSString *urlStr = _personSeeModelLayout.personSeeModel.thumb_img[i];
            if ([urlStr characterAtIndex:0] == 'h') {
                [imageView sd_setImageWithURL:[NSURL URLWithString:urlStr]];
            } else {
                [imageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://%@", urlStr]]];
            }
            
            imageView.contentMode = UIViewContentModeScaleAspectFill;
            imageView.clipsToBounds = YES;
            [self.contentView addSubview:imageView];
            
        }
    } else if ([_personSeeModelLayout.personSeeModel.type isEqualToString:@"3"]) {
    
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:_personSeeModelLayout.movieThumbFrame];
        NSString *urlStr = _personSeeModelLayout.personSeeModel.movieThumb;
        if ([urlStr characterAtIndex:0] == 'h') {
            [imageView sd_setImageWithURL:[NSURL URLWithString:urlStr]];
        } else {
            [imageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://%@", urlStr]]];
        }
        
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;
        [self.contentView addSubview:imageView];
        UIImageView *playImage = [[UIImageView alloc] initWithFrame:CGRectMake((imageView.bounds.size.width - 40)/2.0, (imageView.bounds.size.width - 40)/2.0, 40, 40)];
        playImage.image = [UIImage imageNamed:@"icon_play"];
        [imageView addSubview:playImage];
    }
    
    if (_hideBackgroundColor == NO) {
        // 背景颜色框
        self.backgroundColor.frame = _personSeeModelLayout.backgroundColorFrame;
    }
    
    
    
    // 设置动态文本,设置行间距
    self.contentLabel.frame = _personSeeModelLayout.contentFrame;
    _contentLabel.text = _personSeeModelLayout.personSeeModel.content;
    
    // 长按删除动态
    if ([_personSeeModelLayout.personSeeModel.user_id isEqualToString:[USER_D objectForKey:@"user_id"]]) {
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                                                                action:@selector(deleteAction:)];
        longPress.minimumPressDuration = 3;
        [self addGestureRecognizer:longPress];
    }
    
}


- (void)deleteAction:(UILongPressGestureRecognizer *)longPress {

    if (longPress.state == UIGestureRecognizerStateBegan) {
        [SVProgressHUD dismiss];
        [SVProgressHUD showSuccessWithStatus:@"删除成功"];
    }
    

}














// -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


// #define JudgeTheSameTime @"JudgeTheSameTime"    // 创建一个标识，来确定当前动态是否跟上一个动态为同一天发布,当为0时，表示是第一个显示的第一个动态

//    // 获取当前时间，判断是否是今天
//    NSString *currentTime = [formatter stringFromDate:[NSDate date]];
//    if ([confromTimespStr isEqualToString:currentTime]) {
//
//        // 判断当前动态的创建时间是否跟上一个动态的创建时间一致，一致则不显示时间标签
//        NSString *tempStr = [USER_D objectForKey:JudgeTheSameTime];
//        if ([tempStr isEqualToString:@"0"]) {           // 若当前为显示的第一条动态，则修改状态标志为当前时间
//            _timeLabel.text = @"今天";
//        } else {                                        // 如果不是第一条动态，那么判断状态标志是否跟当前保持一致
//            if ([tempStr isEqualToString:@"今天"]) {     // 如果一致，那就没必要显示时间标签了
//                _timeLabel.text = nil;
//            } else {                                    // 如果不一致，那么要显示时间标签
//                _timeLabel.text = @"今天";
//            }
//        }
//        // 根据当前单元格的时间设定状态标志,刷新标志
//        [USER_D setObject:@"今天" forKey:JudgeTheSameTime];
//
//    } else {
//        // 富文本调节字体大小
//        NSString *monthStr = [confromTimespStr substringWithRange:NSMakeRange(5, 2)];
//        NSString *dayStr = [confromTimespStr substringWithRange:NSMakeRange(8, 2)];
//        NSMutableAttributedString *attribute = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@%@月", dayStr, monthStr]];
//        [attribute addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:24] range:NSMakeRange(0, 2)];
//        [attribute addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:10] range:NSMakeRange(2, 3)];
//
//        // 判断当前动态的创建时间是否跟上一个动态的创建时间一致，一致则不显示时间标签
//        NSString *tempStr = [USER_D objectForKey:JudgeTheSameTime];
//        if ([tempStr isEqualToString:@"0"]) {
//            _timeLabel.attributedText = attribute;
//        } else {
//            if ([tempStr isEqualToString:confromTimespStr]) {
//                _timeLabel.text = nil;
//            } else {
//                _timeLabel.attributedText = attribute;
//            }
//        }
//        [USER_D setObject:confromTimespStr forKey:JudgeTheSameTime];
//
//
//    }

//    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:_personSeeModelLayout.personSeeModel.content];
//    NSMutableParagraphStyle *paragrah = [[NSMutableParagraphStyle alloc] init];
//    if (_personSeeModelLayout.personSeeModel.about_img != nil) {
//        paragrah.lineSpacing = 13;
//    } else {
//        paragrah.lineSpacing = 5;
//    }
//    NSRange range = NSMakeRange(0, string.length);
//    [string addAttribute:NSParagraphStyleAttributeName value:paragrah range:range];
//    _contentLabel.attributedText = string;


//    // 时间戳转换时间
//    NSDate *confromTimesp = [NSDate dateWithTimeIntervalSince1970:[_personSeeModelLayout.personSeeModel.create_time integerValue]];
//    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
//    [formatter setDateStyle:NSDateFormatterMediumStyle];
//    [formatter setTimeStyle:NSDateFormatterShortStyle];
//    [formatter setDateFormat:@"YYYY-MM-dd"];
//    NSString *confromTimespStr = [formatter stringFromDate:confromTimesp];
//
//    // 年份,传到tableView
//    [self.delegate getYearToTableView:[confromTimespStr substringWithRange:NSMakeRange(0, 4)]];
//
//    // 获取当前时间，判断是否是今天
//    NSString *currentTime = [formatter stringFromDate:[NSDate date]];
//    if ([confromTimespStr isEqualToString:currentTime]) {
//
//        if (_personSeeModelLayout.isFirst == YES) {
//            _timeLabel.text = @"今天";
//            _timeLabel.font = [UIFont boldSystemFontOfSize:24];
//        }
//
//    } else {
//
//        if (_personSeeModelLayout.isFirst == YES) {
//            // 富文本调节字体大小
//            NSString *monthStr = [confromTimespStr substringWithRange:NSMakeRange(5, 2)];
//            NSString *dayStr = [confromTimespStr substringWithRange:NSMakeRange(8, 2)];
//            NSMutableAttributedString *attribute = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@%@月", dayStr, monthStr]];
//            [attribute addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:24] range:NSMakeRange(0, 2)];
//            [attribute addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:10] range:NSMakeRange(2, 3)];
//
//            _timeLabel.attributedText = attribute;
//        }
//
//    }











- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
