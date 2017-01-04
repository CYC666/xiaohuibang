//
//  XHBController.m
//  XiaoHuiBang
//
//  Created by mac on 2017/1/4.
//  Copyright © 2017年 消汇邦. All rights reserved.
//

#import "XHBController.h"

#define kScreenHeight [UIScreen mainScreen].bounds.size.height                          // 屏高
#define kScreenWidth [UIScreen mainScreen].bounds.size.width                            // 屏宽


@interface XHBController () <UIWebViewDelegate>

@property (strong, nonatomic) UIWebView *webView;

@end

@implementation XHBController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.view.backgroundColor = [UIColor whiteColor];
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 40)];
    title.text = @"消汇邦";
    title.font = [UIFont boldSystemFontOfSize:19];
    title.textAlignment = NSTextAlignmentCenter;
    title.textColor = [UIColor whiteColor];
    self.navigationItem.titleView = title;

    // 创建网页视图
    // 打开网页
    _webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight - 64)];
    NSURL *url = [NSURL URLWithString:@"http://wap.xiaohuibang.com/nass/index.html?from=timeline&isappinstalled=0#/home"];
    NSURLRequest *requst = [NSURLRequest requestWithURL:url];
    [_webView loadRequest:requst];
    _webView.delegate = self;
    [self.view addSubview:_webView];

}




































@end
