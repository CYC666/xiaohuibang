//
//  CYCOWN.m
//  XiaoHuiBang
//
//  Created by mac on 16/11/24.
//  Copyright © 2016年 消汇邦. All rights reserved.
//

#import "CYCOWN.h"
#import "AFHttpTool.h"
#import <SVProgressHUD.h>

@interface CYCOWN ()

@property (weak, nonatomic) IBOutlet UITextField *input;
@property (weak, nonatomic) IBOutlet UITextView *show;


@end

@implementation CYCOWN

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    
    
}

- (IBAction)seek:(id)sender {
    
    [AFHttpTool getUserInfo:_input.text
                    success:^(id response) {
                        if ([response[@"msg"] isEqual:@1]) {
                            [self loadData:response[@"data"]];
                        }
                    } failure:^(NSError *err) {
                        [SVProgressHUD showSuccessWithStatus:@"FALSE"];
                    }];
}

- (void)loadData:(NSDictionary *)data {

    NSString *string = [NSString stringWithFormat:@"id = %@\n name = %@\n nickname = %@\n token = %@\n mobile = %@\n sex = %@", data[@"id"], data[@"name"], data[@"nickname"], data[@"token"], data[@"mobile"], data[@"sex"]];
    
    _show.text = string;

}



































- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
