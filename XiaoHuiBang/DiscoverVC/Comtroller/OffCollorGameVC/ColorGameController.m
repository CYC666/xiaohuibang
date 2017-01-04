//
//  ColorGameController.m
//  XiaoHuiBang
//
//  Created by mac on 2017/1/4.
//  Copyright © 2017年 消汇邦. All rights reserved.
//

// 记录每高5分给1秒时间？
// 限时模式 + 分值模式？

#import "ColorGameController.h"
#import "ColorGameView.h"

@interface ColorGameController ()

@property (weak, nonatomic) IBOutlet UILabel *score;
@property (weak, nonatomic) IBOutlet UILabel *time;
@property (weak, nonatomic) IBOutlet UILabel *bestScore;

@property (strong, nonatomic) ColorGameView *colorView;

@end

@implementation ColorGameController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 40)];
    title.text = @"ColorGame";
    title.font = [UIFont boldSystemFontOfSize:19];
    title.textAlignment = NSTextAlignmentCenter;
    title.textColor = [UIColor whiteColor];
    self.navigationItem.titleView = title;

    
    _colorView = [[ColorGameView alloc] initWithFrame:CGRectZero];
    //游戏还未开始，不能点击
    _colorView.userInteractionEnabled = NO;
    [self.view addSubview:_colorView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveNotification:)
                                                 name:@"count"
                                               object:nil];
    
    // 最佳记录
    NSString *best = [USER_D objectForKey:@"bestScore"];
    if (best == nil) {
        _bestScore.text = @"0";
    } else {
        _bestScore.text = best;
    }
    
    
}


- (IBAction)start:(UIButton *)sender {
    
    //开始计时，按钮不能再按下
    sender.enabled = NO;
    //能点击了
    _colorView.userInteractionEnabled = YES;
    //发送通知，刷新一下集合视图，使其初始为四个单元
    [[NSNotificationCenter defaultCenter] postNotificationName:@"start" object:nil];
    sender.tag = 4980;
    //时间重置60秒
    _time.text = @"30";
    //得分重置0分
    _score.text = @"0";
    [NSTimer scheduledTimerWithTimeInterval:1
                                     target:self
                                   selector:@selector(timerAction:)
                                   userInfo:nil
                                    repeats:YES];

    
}

- (void)timerAction:(NSTimer *)timer {
    
    _time.text = [NSString stringWithFormat:@"%ld", [_time.text integerValue] - 1];
    if ([_time.text integerValue] < 0) {
        //关闭定时器，防止与下一个定时器重复
        [timer invalidate];
        _time.text = @"0";
        UIButton *button = [self.view viewWithTag:4980];
        //恢复按钮可按状态
        button.enabled = YES;
        //不能再点击了
        _colorView.userInteractionEnabled = NO;
        
        // 跟本地记录作比较
        NSString *best = [USER_D objectForKey:@"bestScore"];
        if ([best integerValue] < [_score.text integerValue]) {
            [USER_D setObject:_score.text forKey:@"bestScore"];
            _bestScore.text = _score.text;
        }
        
        //游戏结束,弹出提示
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"游戏结束"
                                                                       message:_score.text
                                                                preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"继续游戏"
                                                  style:UIAlertActionStyleDefault
                                                handler:^(UIAlertAction * _Nonnull action) {
                                                    
                                                }]];
        [self presentViewController:alert animated:YES completion:nil];
        
    }
    
}



- (void)receiveNotification:(NSNotification *)notification {
    _score.text = notification.object;
}






























@end
