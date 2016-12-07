//
//  CScrollView.m
//  XiaoHuiBang
//
//  Created by mac on 16/12/6.
//  Copyright © 2016年 消汇邦. All rights reserved.
//

#import "CScrollView.h"
#import <UIImageView+WebCache.h>


@interface CScrollView () <UIScrollViewDelegate> {

    NSArray *_imageArr;
    NSInteger _currentPage;
    float _lastScale;           // 上次缩放的倍数

}

@end


@implementation CScrollView




- (instancetype)initWithFrame:(CGRect)frame imageArray:(NSArray *)array currentPage:(NSInteger)page {

    self = [super initWithFrame:frame];
    if (self != nil) {
        _imageArr = array;
        _currentPage = page;
        _lastScale = 1;
        self.delegate = self;
        self.pagingEnabled = YES;
        self.backgroundColor = [UIColor blackColor];
        self.contentSize = CGSizeMake(frame.size.width * array.count, frame.size.height);
        self.alwaysBounceHorizontal = YES;
        self.contentOffset = CGPointMake(frame.size.width * page, 0);
        // 创建子视图
        [self _creatSubviews];
        
    }
    return self;

}


- (void)_creatSubviews {

    for (int i = 0; i < _imageArr.count; i++) {
        
        // 把图片放在单独的滑动视图之上，就不会影响底下的主滑动视图了
        
        UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(self.frame.size.width * i, 0, self.frame.size.width, self.frame.size.height)];
        scrollView.delegate = self;
        scrollView.minimumZoomScale = 1;
        scrollView.maximumZoomScale = 3;
        scrollView.contentSize = CGSizeMake(self.frame.size.width, self.frame.size.height);
        [self addSubview:scrollView];
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        [imageView sd_setImageWithURL:[NSURL URLWithString:_imageArr[i]]
                     placeholderImage:nil
                              options:SDWebImageProgressiveDownload];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.userInteractionEnabled = YES;
        [scrollView addSubview:imageView];
        
        // 长按保存
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                                                                action:@selector(saveAction:)];
        [imageView addGestureRecognizer:longPress];
    }

}

#pragma mark - 缩放
- (nullable UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {

    return scrollView.subviews.firstObject;

}


#pragma mark - 翻页监控
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    // 结束减速时调用，也就是停止瞬间
    _currentPage = self.contentOffset.x / scrollView.frame.size.width;
    
    
}

#pragma mark - 保存图片
- (void)saveAction:(UILongPressGestureRecognizer *)longPress {

    
    // 长按手势会调用两次（开始、结束）
    if (longPress.state == UIGestureRecognizerStateBegan) {
        UIImageWriteToSavedPhotosAlbum([(UIImageView *)(longPress.view) image], self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
    }

}
// 保存图片
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    if (error == nil) {
        // 直接将图片保存到本地
        [SVProgressHUD dismiss];
        [SVProgressHUD showSuccessWithStatus:@"已经将图片保存到本地"];
    } else {
        [SVProgressHUD dismiss];
        [SVProgressHUD showSuccessWithStatus:@"保存失败了哟"];
    }
}



// 查看self是否已经销毁


















/*
 //        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"是否保存图片?"
 //                                                                       message:nil
 //                                                                preferredStyle:UIAlertControllerStyleActionSheet];
 //        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"拒绝"
 //                                                               style:UIAlertActionStyleCancel
 //                                                             handler:nil];
 //        UIAlertAction *sureAction = [UIAlertAction actionWithTitle:@"好的"
 //                                                             style:UIAlertActionStyleDefault
 //                                                           handler:^(UIAlertAction * _Nonnull action) {
 //
 //                                                           }];
 //        [alert addAction:cancelAction];
 //        [alert addAction:sureAction];
 //        [[self viewController] presentViewController:alert animated:YES completion:nil];
 */











@end
