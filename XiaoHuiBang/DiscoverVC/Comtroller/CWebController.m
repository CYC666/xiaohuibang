//
//  CWebController.m
//  XiaoHuiBang
//
//  Created by mac on 2017/1/4.
//  Copyright © 2017年 消汇邦. All rights reserved.
//

#import "CWebController.h"

#define kScreenHeight [UIScreen mainScreen].bounds.size.height                          // 屏高
#define kScreenWidth [UIScreen mainScreen].bounds.size.width                            // 屏宽


@interface CWebController () <UIWebViewDelegate>

@property (copy, nonatomic) NSString *name;
@property (copy, nonatomic) NSString *urlStr;
@property (strong, nonatomic) UIWebView *webView;
@end

@implementation CWebController

- (instancetype)initWithName:(NSString *)controllerName
                         url:(NSString *)controllerUrl {

    if (self = [super init]) {
        _name = controllerName;
        _urlStr = controllerUrl;
    }
    return self;

}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.view.backgroundColor = [UIColor whiteColor];
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 40)];
    title.text = _name;
    title.font = [UIFont boldSystemFontOfSize:19];
    title.textAlignment = NSTextAlignmentCenter;
    title.textColor = [UIColor whiteColor];
    self.navigationItem.titleView = title;
    
    // 打开网页
    _webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight - 64)];
    NSURL *url = [NSURL URLWithString:_urlStr];
    NSURLRequest *requst = [NSURLRequest requestWithURL:url];
    [_webView loadRequest:requst];
    _webView.delegate = self;
    [self.view addSubview:_webView];
    
    // 添加手势
    UISwipeGestureRecognizer *backSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(backSwipeAction:)];
    backSwipe.direction = UISwipeGestureRecognizerDirectionRight;
    [_webView addGestureRecognizer:backSwipe];
    UISwipeGestureRecognizer *forwardSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(forwardSwipeAction:)];
    forwardSwipe.direction = UISwipeGestureRecognizerDirectionLeft;
    [_webView addGestureRecognizer:forwardSwipe];
    
}
- (void)backSwipeAction:(UISwipeGestureRecognizer *)swipe {
    
    if (_webView.canGoBack) {
        [_webView goBack];
    }
    
}
- (void)forwardSwipeAction:(UISwipeGestureRecognizer *)swipe {
    
    if (_webView.canGoForward) {
        [_webView goForward];
    }
    
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
}





































@end
