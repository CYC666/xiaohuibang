//
//  CScrollImage.m
//  XiaoHuiBang
//
//  Created by mac on 16/12/9.
//  Copyright © 2016年 消汇邦. All rights reserved.
//

// 滑动显示大图控件


#import "CScrollImage.h"
#import <UIImageView+WebCache.h>

#define kScreenWidth [UIScreen mainScreen].bounds.size.width    // 屏宽
#define kScreenHeight [UIScreen mainScreen].bounds.size.height  // 屏高


@interface CScrollImage () <UIScrollViewDelegate> {
    
    NSArray *_imageArr;
    NSInteger _currentPage;
    float _lastScale;           // 上次缩放的倍数
    UIScrollView *_background;  // 底部滑动视图
    UIPageControl *_pageControl;// 分页控制小点点
    UILabel *_pageLabel;        // 显示页数
    UIScrollView *_scaleView;   // 被缩放的图
    
    
}

@end

@implementation CScrollImage


- (instancetype)initWithFrame:(CGRect)frame imageArray:(NSArray *)array currentPage:(NSInteger)page {

    self = [super initWithFrame:frame];
    if (self != nil) {
        _imageArr = array;
        _currentPage = page;
        
        // 创建子视图
        [self _creatSubviews];
        
    }
    return self;

}

- (void)_creatSubviews {

    CGRect rect = self.frame;
    _background = [[UIScrollView alloc] initWithFrame:self.frame];
    _background.contentSize = CGSizeMake(rect.size.width * _imageArr.count, rect.size.height);
    _background.alwaysBounceHorizontal = YES;
    _background.contentOffset = CGPointMake(rect.size.width * _currentPage, 0);
    _background.delegate = self;
    _background.pagingEnabled = YES;
    _background.backgroundColor = [UIColor blackColor];
    _background.showsHorizontalScrollIndicator = NO;
    [self addSubview:_background];
    
    for (int i = 0; i < _imageArr.count; i++) {
        
        // 把图片放在单独的滑动视图之上，就不会影响底下的主滑动视图了
        
        UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(self.frame.size.width * i, 0, self.frame.size.width, self.frame.size.height)];
        scrollView.delegate = self;
        scrollView.minimumZoomScale = 1;
        scrollView.maximumZoomScale = 3;
        scrollView.contentSize = CGSizeMake(self.frame.size.width, self.frame.size.height);
        [_background addSubview:scrollView];
        
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
    
//    _pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake((kScreenWidth - 100)/2.0, kScreenHeight - 40, 100, 40)];
//    _pageControl.numberOfPages = _imageArr.count;
//    _pageControl.currentPage = _currentPage;
//    [self addSubview:_pageControl];
    
    _pageLabel = [[UILabel alloc] initWithFrame:CGRectMake((kScreenWidth - 100)/2.0, kScreenHeight - 40, 100, 40)];
    _pageLabel.textColor = [UIColor lightGrayColor];
    _pageLabel.textAlignment = NSTextAlignmentCenter;
    _pageLabel.text = [NSString stringWithFormat:@"%ld / %ld", _currentPage+1, _imageArr.count];
    [self addSubview:_pageLabel];


}

#pragma mark - 缩放
- (nullable UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    
    // 暂存被缩放的图
    _scaleView = scrollView;
    
    // 指向imageView
    return scrollView.subviews.firstObject;
    
}

#pragma mark - 翻页监控
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    NSInteger lastPage = _currentPage;
    // 结束减速时调用，也就是停止瞬间
    _currentPage = _background.contentOffset.x / scrollView.frame.size.width;
    
    // 当滑动到其他页面时才做处理
    if (lastPage != _currentPage) {
        // 处理被缩放了的图
        [_scaleView setZoomScale:1];
        _scaleView = nil;
    }
    
//    _pageControl.currentPage = _currentPage;
    _pageLabel.text = [NSString stringWithFormat:@"%ld / %ld", _currentPage+1, _imageArr.count];
    
    
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





























@end
