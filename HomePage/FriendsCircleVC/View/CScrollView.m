//
//  CScrollView.m
//  XiaoHuiBang
//
//  Created by mac on 16/12/6.
//  Copyright © 2016年 消汇邦. All rights reserved.
//

#import "CScrollView.h"
#import <UIImageView+WebCache.h>


@interface CScrollView () {

    NSArray *_imageArr;
    NSInteger _currentPage;

}

@end


@implementation CScrollView




- (instancetype)initWithFrame:(CGRect)frame imageArray:(NSArray *)array currentPage:(NSInteger)page {

    self = [super initWithFrame:frame];
    if (self != nil) {
        _imageArr = array;
        _currentPage = page;
        self.contentSize = CGSizeMake(frame.size.width * array.count, frame.size.height);
        self.alwaysBounceHorizontal = YES;
        // 创建子视图
        [self _creatSubviews];
    }
    return self;

}


- (void)_creatSubviews {

    for (int i = 0; i < _imageArr.count; i++) {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.frame.size.width * i, 0, self.frame.size.width, self.frame.size.height)];
        [imageView sd_setImageWithURL:_imageArr[i]];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:imageView];
    }

}

































@end
