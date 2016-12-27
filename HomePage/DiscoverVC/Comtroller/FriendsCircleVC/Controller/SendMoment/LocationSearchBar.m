//
//  LocationSearchBar.m
//  XiaoHuiBang
//
//  Created by mac on 16/12/26.
//  Copyright © 2016年 消汇邦. All rights reserved.
//

#import "LocationSearchBar.h"

#define kScreenWidth [UIScreen mainScreen].bounds.size.width    // 屏宽
#define kScreenHeight [UIScreen mainScreen].bounds.size.height  // 屏高

@interface LocationSearchBar () <UITextFieldDelegate> {

    CALayer *_layer;

}

@property (strong, nonatomic) UITextField *searchField;
@property (strong, nonatomic) UIImageView *searchImage;
@property (strong, nonatomic) UILabel *holder;
@property (strong, nonatomic) UIButton *cancelButton;

@end


@implementation LocationSearchBar

- (instancetype)initWithFrame:(CGRect)frame {

    CGRect rect = CGRectMake(0, 0, kScreenWidth, 45);
    if (self = [super initWithFrame:rect]) {
        
        self.backgroundColor = [UIColor colorWithRed:238/255.0 green:238/255.0 blue:238/255.0 alpha:1];
        [self _creatSubviews];
        
    }
    return self;

}

- (UIButton *)cancelButton {

    if (!_cancelButton) {
        _cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _cancelButton.frame = CGRectMake(kScreenWidth - 50, 8, 40, 29);
        [_cancelButton setTitle:@"取消" forState:UIControlStateNormal];
        [_cancelButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        _cancelButton.alpha = 0;
        [_cancelButton addTarget:self action:@selector(cancelButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_cancelButton];
    }
    return _cancelButton;

}

#pragma mark - 创建子视图
- (void)_creatSubviews {
    
    _layer = [[CALayer alloc] init];
    _layer.frame = CGRectMake(8, 8, kScreenWidth - 8*2, 45 - 8*2);
    _layer.backgroundColor = [UIColor whiteColor].CGColor;
    _layer.cornerRadius = 9;
    _layer.borderWidth = 0.5;
    _layer.borderColor = [UIColor lightGrayColor].CGColor;
    [self.layer addSublayer:_layer];

    _searchField = [[UITextField alloc] initWithFrame:CGRectMake(37, 8, kScreenWidth - 8*2 - 37, 45 - 8*2)];
    _searchField.borderStyle = UITextBorderStyleNone;
    _searchField.backgroundColor = [UIColor clearColor];
    _searchField.textAlignment = NSTextAlignmentLeft;
    _searchField.tintColor = [UIColor blueColor];
    _searchField.returnKeyType = UIReturnKeySearch;
    _searchField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _searchField.delegate = self;
    [self addSubview:_searchField];
    
    _searchImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_search_image"]];
    _searchImage.frame = CGRectMake((kScreenWidth - 18 - 110)/2, 14, 18, 16);
    [self addSubview:_searchImage];
    
    _holder = [[UILabel alloc] initWithFrame:CGRectMake((kScreenWidth - 18 - 110)/2 + 18, 14, 110, 16)];
    _holder.text = @"搜索附近位置";
    _holder.font = [UIFont systemFontOfSize:15];
    _holder.textAlignment = NSTextAlignmentCenter;
    _holder.textColor = [UIColor grayColor];
    [self addSubview:_holder];

}

#pragma mark - textField代理方法
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    
    self.searchBarEditBeginBlock();

    [UIView animateWithDuration:.35
                     animations:^{
                         _searchImage.transform = CGAffineTransformMakeTranslation(-(_searchImage.frame.origin.x - 6 - 8), 0);
                         _holder.transform = CGAffineTransformMakeTranslation(-(_holder.frame.origin.x - (6 + 8 + 18)), 0);
                         _layer.frame = CGRectMake(8, 8, kScreenWidth - 8*2 - 50, 45 - 8*2);
                         _searchField.frame = CGRectMake(37, 8, kScreenWidth - 8*2 - 37 - 50, 45 - 8*2);
                         
                     } completion:^(BOOL finished) {
                         [UIView animateWithDuration:.35
                                          animations:^{
                                              _holder.alpha = 0;
                                          }];
                         self.cancelButton.alpha = 1;
                     }];

}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {

    __block NSString *text = textField.text;
    self.searchBarReturnBlock(text);
    
    return YES;
    
}

#pragma mark - 取消按钮
- (void)cancelButtonAction:(UIButton *)button {
    
    _searchField.text = nil;
    [_searchField endEditing:YES];
    [self cancelAction];
    self.searchBarCancelBlock();

}

#pragma mark - 还原动画

- (void)cancelAction {

    _cancelButton.alpha = 0;
    [UIView animateWithDuration:.35
                     animations:^{
                         _searchImage.transform = CGAffineTransformIdentity;
                         _holder.transform = CGAffineTransformIdentity;
                         _layer.frame = CGRectMake(8, 8, kScreenWidth - 8*2, 45 - 8*2);
                         _searchField.frame = CGRectMake(37, 8, kScreenWidth - 8*2 - 37, 45 - 8*2);
                         _holder.alpha = 1;
                     }];

}
































@end
