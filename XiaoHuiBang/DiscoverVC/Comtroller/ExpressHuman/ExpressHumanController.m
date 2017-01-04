//
//  ExpressHumanController.m
//  XiaoHuiBang
//
//  Created by mac on 2017/1/4.
//  Copyright © 2017年 消汇邦. All rights reserved.
//

#import "ExpressHumanController.h"

#define kScreenHeight [UIScreen mainScreen].bounds.size.height                          // 屏高
#define kScreenWidth [UIScreen mainScreen].bounds.size.width                            // 屏宽


@interface ExpressHumanController () <UIWebViewDelegate, NSURLSessionDelegate>

@property (strong, nonatomic) UIWebView *webView;
@property (strong, nonatomic) UIView *layer;

@end

@implementation ExpressHumanController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 40)];
    title.text = @"告白小人";
    title.font = [UIFont boldSystemFontOfSize:19];
    title.textAlignment = NSTextAlignmentCenter;
    title.textColor = [UIColor whiteColor];
    self.navigationItem.titleView = title;

    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    // 打开网页
    _webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight - 64)];
    NSURL *url = [NSURL URLWithString:@"http://test.dayukeji.com/xiaoren/index.html"];
    NSURLRequest *requst = [NSURLRequest requestWithURL:url];
    [_webView loadRequest:requst];
    _webView.delegate = self;
    [self.view addSubview:_webView];
    
    // 添加双指长按手势
    UILongPressGestureRecognizer *longPressed = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressed:)];
    longPressed.numberOfTouchesRequired = 2;
    [_webView addGestureRecognizer:longPressed];
    
}


- (void)longPressed:(UILongPressGestureRecognizer*)recognizer {
    if (recognizer.state != UIGestureRecognizerStateBegan) {
        return;
    }
    
    CGPoint touchPoint = [recognizer locationInView:self.webView];
    
    NSString *imgURL = [NSString stringWithFormat:@"document.elementFromPoint(%f, %f).src", touchPoint.x, touchPoint.y];
    NSString *urlToSave = [self.webView stringByEvaluatingJavaScriptFromString:imgURL];
    
    if (urlToSave.length == 0) {
        return;
    }
    
    [self showImageOptionsWithUrl:urlToSave];
}

- (void)showImageOptionsWithUrl:(NSString *)imageUrl {

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil
                                                                   message:@"保存图片？"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *sureAction = [UIAlertAction actionWithTitle:@"确定"
                                                         style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction * _Nonnull action) {
                                                           [self saveImageToDiskWithUrl:imageUrl];
                                                       }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消"
                                                           style:UIAlertActionStyleDefault
                                                         handler:nil];
    
    [alert addAction:sureAction];
    [alert addAction:cancelAction];
    [self presentViewController:alert animated:YES completion:nil];

}

- (void)saveImageToDiskWithUrl:(NSString *)imageUrl {
    NSURL *url = [NSURL URLWithString:imageUrl];
    
    NSURLSessionConfiguration * configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:[NSOperationQueue new]];
    
    NSURLRequest *imgRequest = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:30.0];
    
    NSURLSessionDownloadTask  *task = [session downloadTaskWithRequest:imgRequest completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            return ;
        }
        
        NSData * imageData = [NSData dataWithContentsOfURL:location];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            UIImage * image = [UIImage imageWithData:imageData];
            
            UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
        });
    }];
    
    [task resume];
}

#pragma mark - 保存图片
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    if (error) {
        
    }else{
        
    }
}


#pragma mark - 取消自带长按响应
-(void)webViewDidFinishLoad:(UIWebView *)webView {
    [self.webView stringByEvaluatingJavaScriptFromString:@"document.documentElement.style.webkitTouchCallout = 'none';"];
    [self.webView stringByEvaluatingJavaScriptFromString:@"document.documentElement.style.webkitUserSelect = 'none';"];
    
    if (_layer == nil) {
        // 遮罩
        _layer = [[UIView alloc] initWithFrame:CGRectMake(25, _webView.scrollView.contentSize.height - kScreenHeight*0.27 - 25, kScreenWidth - 50, kScreenHeight*0.27)];
        _layer.backgroundColor = [UIColor colorWithRed:239/255.0 green:153/255.0 blue:53/255.0 alpha:1];
        [_webView.scrollView addSubview:_layer];
        _layer.layer.cornerRadius = 10;
        _layer.alpha = 0;
        
        // 提示双指长按
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 40, kScreenWidth - 50, 50)];
        label.text = @"双指长按可保存图片";
        label.font = [UIFont boldSystemFontOfSize:30];
        label.textAlignment = NSTextAlignmentCenter;
        [_layer addSubview:label];
        
        // 显示
        [UIView animateWithDuration:.35
                         animations:^{
                             _layer.alpha = 1;
                         }];
            
        // 添加观察者
        [_webView.scrollView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:nil];
    
    }
    
    
}

#pragma mark - 观察者响应
- (void)observeValueForKeyPath:(nullable NSString *)keyPath ofObject:(nullable id)object change:(nullable NSDictionary<NSKeyValueChangeKey, id> *)change context:(nullable void *)context {

    if ([keyPath isEqualToString:@"contentSize"]) {
        _layer.frame = CGRectMake(25, _webView.scrollView.contentSize.height - kScreenHeight*0.27 - 25, kScreenWidth - 50, kScreenHeight*0.27);
    }

}


- (void)dealloc {

    [_webView.scrollView removeObserver:self forKeyPath:@"contentSize"];

}























@end
