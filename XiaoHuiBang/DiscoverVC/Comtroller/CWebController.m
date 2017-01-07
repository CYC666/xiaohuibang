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
@property (assign, nonatomic) float webViewHeight;

@end

@implementation CWebController

- (instancetype)initWithName:(NSString *)controllerName
                         url:(NSString *)controllerUrl {

    if (self = [super init]) {
        _name = controllerName;
        _urlStr = controllerUrl;
        _webViewHeight = kScreenHeight-64;
    }
    return self;

}
- (instancetype)initWithModelName:(NSString *)controllerName
                              url:(NSString *)controllerUrl {
    
    if (self = [super init]) {
        _name = controllerName;
        _urlStr = controllerUrl;
        _webViewHeight = kScreenHeight;
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
    _webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, _webViewHeight)];
    NSURL *url = [NSURL URLWithString:_urlStr];
    NSURLRequest *requst = [NSURLRequest requestWithURL:url];
    [_webView loadRequest:requst];
    _webView.delegate = self;
    [self.view addSubview:_webView];
    
    
}

#pragma mark - 主页按钮
- (void)setAllowRightItem:(BOOL)allowRightItem {

    _allowRightItem = allowRightItem;
    if (_allowRightItem) {
        // 右边的按钮
        UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:@"主页"
                                                                      style:UIBarButtonItemStylePlain
                                                                     target:self
                                                                     action:@selector(rightItemAction:)];
        [self.navigationItem setRightBarButtonItem:rightItem];
    }

}

- (void)rightItemAction:(UIBarButtonItem *)item {
    
    if ([_webView canGoBack]) {
        [_webView goBack];
    }
    
}

#pragma mark - 模态进入，返回按钮
- (void)setIsModel:(BOOL)isModel {

    _isModel = isModel;
    if (_isModel) {
        UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithTitle:@"退出"
                                                                      style:UIBarButtonItemStylePlain
                                                                     target:self
                                                                     action:@selector(leftItemAction:)];
        [self.navigationItem setLeftBarButtonItem:leftItem];
    }

}

- (void)leftItemAction:(UIBarButtonItem *)item {

    [self dismissViewControllerAnimated:YES completion:nil];

}

#pragma mark - 左滑右滑手势响应
- (void)setAllowGesture:(BOOL)allowGesture {

    _allowGesture = allowGesture;
    if (_allowGesture) {
        // 添加手势
        UISwipeGestureRecognizer *backSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(backSwipeAction:)];
        backSwipe.direction = UISwipeGestureRecognizerDirectionRight;
        [_webView addGestureRecognizer:backSwipe];
        UISwipeGestureRecognizer *forwardSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(forwardSwipeAction:)];
        forwardSwipe.direction = UISwipeGestureRecognizerDirectionLeft;
        [_webView addGestureRecognizer:forwardSwipe];

    }

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

#pragma mark - 网页代理方法
- (void)webViewDidStartLoad:(UIWebView *)webView {
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
}



































@end
