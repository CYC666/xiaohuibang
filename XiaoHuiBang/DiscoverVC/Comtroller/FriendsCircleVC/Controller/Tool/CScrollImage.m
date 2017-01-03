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
    NSArray *_thumbArr;
    NSInteger _currentPage;
    UIScrollView *_background;  // 底部滑动视图
    UIPageControl *_pageControl;// 分页控制小点点
    UILabel *_pageLabel;        // 显示页数
    UIScrollView *_scaleView;   // 被缩放的图
    
    
}

@end

@implementation CScrollImage


- (instancetype)initWithFrame:(CGRect)frame
                   imageArray:(NSArray *)array
              thumbImageArray:(NSArray *)thumbArray
                  currentPage:(NSInteger)page {

    self = [super initWithFrame:frame];
    if (self != nil) {
        _imageArr = array;
        _thumbArr = thumbArray;
        _currentPage = page;
        _allowHide = YES;
        
        // 创建子视图
        [self _creatSubviews];
        
        // 下滑隐藏
        UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeAction:)];
        swipe.direction = UISwipeGestureRecognizerDirectionDown;
        [self addGestureRecognizer:swipe];
        
    }
    return self;

}

- (void)_creatSubviews {

    CGRect rect = CGRectMake(-10, 0, kScreenWidth + 20, kScreenHeight);
    _background = [[UIScrollView alloc] initWithFrame:rect];
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
        UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(rect.size.width * i, 0, rect.size.width, rect.size.height)];
        scrollView.delegate = self;
        scrollView.minimumZoomScale = 1;
        scrollView.maximumZoomScale = 3;
        scrollView.contentSize = CGSizeMake(kScreenWidth, kScreenHeight);
        [_background addSubview:scrollView];
        // 双击将图返回原样
        UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                    action:@selector(resetImage:)];
        doubleTap.numberOfTapsRequired = 2;
        [scrollView addGestureRecognizer:doubleTap];
        
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 0, kScreenWidth, kScreenHeight)];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.userInteractionEnabled = YES;
        [scrollView addSubview:imageView];
        NSString *urlStr = _imageArr[i];
        __block UIActivityIndicatorView *indicatorView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake((rect.size.width - 100)/2.0, (rect.size.height - 100)/2.0, 100, 100)];
        indicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
        indicatorView.hidesWhenStopped = YES;
        [scrollView addSubview:indicatorView];
        [indicatorView startAnimating];
        if ([urlStr characterAtIndex:0] == 'h') {
            
            UIImage *image = [[[SDWebImageManager sharedManager] imageCache] imageFromDiskCacheForKey:_thumbArr[i]];
            [imageView sd_setImageWithURL:[NSURL URLWithString:urlStr]
                         placeholderImage:image
                                  options:SDWebImageRetryFailed
                                 progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                                     
                                 } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                     
                                     [indicatorView stopAnimating];
                                     
                                 }];
            // 当宽 < 高时，控制滑动视图的大小,防止缩放后偏移太多
//            CGSize imageSize = image.size;
//            float scale = imageSize.width / imageSize.height;
//            scrollView.contentSize = CGSizeMake(kScreenWidth, kScreenWidth / scale);
            
        } else {
            
            UIImage *image = [[[SDWebImageManager sharedManager] imageCache] imageFromDiskCacheForKey:[NSString stringWithFormat:@"https://%@", _thumbArr[i]]];
            [imageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://%@", urlStr]]
                         placeholderImage:image
                                  options:SDWebImageRetryFailed
                                 progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                                    
                                 } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                     [indicatorView stopAnimating];
                                     
                                 }];
            // 当宽 < 高时，控制滑动视图的大小,防止缩放后偏移太多
//            CGSize imageSize = image.size;
//            float scale = imageSize.width / imageSize.height;
//            scrollView.contentSize = CGSizeMake(kScreenWidth, kScreenWidth / scale);
            
        }
        
        
        
        
        
        
        // 长按保存
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                                                                action:@selector(saveAction:)];
        [imageView addGestureRecognizer:longPress];
        
    }
    
    _pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake((kScreenWidth - 100)/2.0, kScreenHeight - 40, 100, 40)];
    _pageControl.numberOfPages = _imageArr.count;
    _pageControl.currentPage = _currentPage;
    [self addSubview:_pageControl];
    
//    _pageLabel = [[UILabel alloc] initWithFrame:CGRectMake((kScreenWidth - 100)/2.0, kScreenHeight - 40, 100, 40)];
//    _pageLabel.textColor = [UIColor lightGrayColor];
//    _pageLabel.textAlignment = NSTextAlignmentCenter;
//    _pageLabel.text = [NSString stringWithFormat:@"%ld / %ld", _currentPage+1, _imageArr.count];
//    [self addSubview:_pageLabel];


}

#pragma mark - 缩放
- (nullable UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    
    // 暂存被缩放的图
    _scaleView = scrollView;
    
    // 指向imageView
    return scrollView.subviews.firstObject;
    
}


#pragma mark - 双击放大缩小
- (void)resetImage:(UITapGestureRecognizer *)tap {
    
    _allowHide = NO;
    UIScrollView *scview = (UIScrollView *)(tap.view);
    
    // 判断是否已经放大，如果放大了，那么恢复，如果没有放大，那么进行放大
    if (scview.zoomScale == 1) {
        [(UIScrollView *)(tap.view) setZoomScale:3 animated:YES];
    } else {
        [(UIScrollView *)(tap.view) setZoomScale:1 animated:YES];
    }

    
    // 缩放之后再允许单击操作
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        _allowHide = YES;
    });

}

#pragma mark - 翻页监控
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    NSInteger lastPage = _currentPage;
    // 结束减速时调用，也就是停止瞬间
    _currentPage = _background.contentOffset.x / _background.frame.size.width;
    
    // 当滑动到其他页面时才做处理
    if (lastPage != _currentPage) {
        // 处理被缩放了的图
        [_scaleView setZoomScale:1];
        _scaleView = nil;
    }
    
    _pageControl.currentPage = _currentPage;
//    _pageLabel.text = [NSString stringWithFormat:@"%ld / %ld", _currentPage+1, _imageArr.count];
    
    
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


#pragma mark - 设置图片
- (void)setImageView:(UIImageView *)imageView withImage:(UIImage *)image {

    // CGSize size = image.size;
    imageView.image = nil;
    imageView.image = image;

}


#pragma mark - 下滑隐藏
- (void)swipeAction:(UISwipeGestureRecognizer *)swipe {

    

}






















@end
