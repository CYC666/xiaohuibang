//
//  CContentLabel.h
//  XiaoHuiBang
//
//  Created by mac on 2017/1/5.
//  Copyright © 2017年 消汇邦. All rights reserved.
//

// 用在显示动态内容的label


#import <UIKit/UIKit.h>
@class CContentLabel;

@protocol CContentLabelDeletage <NSObject>

@optional

- (void)cContentLabelTouch:(CContentLabel *)cContentLabel;
- (void)cContentLabelLongTouch:(CContentLabel *)cContentLabel;

@end


@interface CContentLabel : UILabel

@property (weak, nonatomic) id<CContentLabelDeletage> delegate;



@end
