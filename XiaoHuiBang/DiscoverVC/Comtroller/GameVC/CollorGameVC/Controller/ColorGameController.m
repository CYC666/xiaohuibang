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
@property (weak, nonatomic) IBOutlet UILabel *ranking;
@property (weak, nonatomic) IBOutlet UILabel *bangBi;
@property (weak, nonatomic) IBOutlet UIProgressView *progressLine;
@property (weak, nonatomic) IBOutlet UIButton *startButton;


@property (strong, nonatomic) ColorGameView *colorView;

@end

@implementation ColorGameController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 40)];
    title.text = @"找邦币";
    title.font = [UIFont boldSystemFontOfSize:19];
    title.textAlignment = NSTextAlignmentCenter;
    title.textColor = [UIColor whiteColor];
    self.navigationItem.titleView = title;
    
    // 返回按钮
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_game2048_back"]
                                                                 style:UIBarButtonItemStylePlain
                                                                target:self
                                                                action:@selector(backButtonAction:)];
    [self.navigationItem setLeftBarButtonItem:backItem];

    _colorView = [[ColorGameView alloc] initWithFrame:CGRectMake(20, _progressLine.frame.origin.y + 10, 0, 0)];
    //游戏还未开始，不能点击
    _colorView.userInteractionEnabled = NO;
    [self.view addSubview:_colorView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveNotification:)
                                                 name:@"count"
                                               object:nil];
    if ([UIScreen mainScreen].bounds.size.width == 320) {
        _startButton.transform = CGAffineTransformMakeTranslation(0, 20);
    }

    // 最佳记录
    NSString *best = [USER_D objectForKey:@"colorGame_bestScore"];
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
    _bangBi.text = @"0";
    [NSTimer scheduledTimerWithTimeInterval:1
                                     target:self
                                   selector:@selector(timerAction:)
                                   userInfo:nil
                                    repeats:YES];

    
}

- (void)timerAction:(NSTimer *)timer {
    
    _time.text = [NSString stringWithFormat:@"%ld", [_time.text integerValue] - 1];
    _progressLine.progress = ([_time.text integerValue]) / 30.0;
    
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
        NSString *best = [USER_D objectForKey:@"colorGame_bestScore"];
        if ([best integerValue] < [_score.text integerValue]) {
            [USER_D setObject:_score.text forKey:@"colorGame_bestScore"];
            _bestScore.text = _score.text;
        }
        
        //游戏结束,弹出提示
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"游戏结束"
                                                                       message:[NSString stringWithFormat:@"您获得了%@个邦币", _bangBi.text]
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
    
    // 当分值大于15才赠送邦币
    if ([_score.text integerValue] >= 10 && [_score.text integerValue] < 20) {
        _bangBi.text = _score.text;
        
    // 当大于20，三倍
    } else if ([_score.text integerValue] >= 20) {
        _bangBi.text = [NSString stringWithFormat:@"%ld", [_score.text integerValue] + ([_score.text integerValue] - 20)*3];
    }
}


- (void)backButtonAction:(UIBarButtonItem *)item {

    [self dismissViewControllerAnimated:YES completion:nil];

}





























@end
