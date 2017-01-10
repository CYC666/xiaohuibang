//
//  F3HNumberTileGameViewController.m
//  NumberTileGame
//
//  Created by Austin Zheng on 3/22/14.
//
//

#import "F3HNumberTileGameViewController.h"

#import "F3HGameboardView.h"
#import "F3HControlView.h"
#import "F3HScoreView.h"
#import "F3HGameModel.h"
#import "CYCBangBiScoreView.h"
#import "CYCBestScoreView.h"

#define ELEMENT_SPACING 10      // 视图之间的差距
#define kScreenHeight [UIScreen mainScreen].bounds.size.height                          // 屏高
#define kScreenWidth [UIScreen mainScreen].bounds.size.width                            // 屏宽


@interface F3HNumberTileGameViewController () <F3HGameModelProtocol, F3HControlViewProtocol>

@property (nonatomic, strong) F3HGameboardView *gameboard;  // 游戏界面
@property (nonatomic, strong) F3HGameModel *model;          // 游戏数据
@property (nonatomic, strong) F3HScoreView *scoreView;      // 得分视图
@property (strong, nonatomic) CYCBangBiScoreView *bangBiView;   // 获得的邦币视图
@property (strong, nonatomic) CYCBestScoreView *bestScoreView;  // 最佳成绩
@property (strong, nonatomic) UILabel *tipLabel;            // 提示
@property (nonatomic, strong) F3HControlView *controlView;  // 控制面板

@property (nonatomic) BOOL useScoreView;        // 是否显示得分
@property (nonatomic) BOOL useControlView;      // 是否使用（显示）按钮控制

@property (nonatomic) NSUInteger dimension;     // 尺寸       ? * ?
@property (nonatomic) NSUInteger threshold;     // 获胜的分数  ？？？？
@end

@implementation F3HNumberTileGameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupGame];
}

- (void)viewDidAppear:(BOOL)animated {
    // [[UIApplication sharedApplication] setStatusBarHidden:YES];
}
- (void)viewWillDisappear:(BOOL)animated {
    // [[UIApplication sharedApplication] setStatusBarHidden:NO];
}


+ (instancetype)numberTileGameWithDimension:(NSUInteger)dimension
                               winThreshold:(NSUInteger)threshold
                            backgroundColor:(UIColor *)backgroundColor
                              swipeControls:(BOOL)swipeControlsEnabled {
    F3HNumberTileGameViewController *c = [[self class] new];
    c.dimension = dimension > 2 ? dimension : 2;
    c.threshold = threshold > 8 ? threshold : 8;
    c.useScoreView = YES;
    c.useControlView = NO;
    c.view.backgroundColor = backgroundColor ?: [UIColor whiteColor];
    if (swipeControlsEnabled) {
        [c setupSwipeControls];
    }
    return c;
}


#pragma mark - 设置手势
- (void)setupSwipeControls {
    UISwipeGestureRecognizer *upSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                                                  action:@selector(upButtonTapped)];
    upSwipe.numberOfTouchesRequired = 1;
    upSwipe.direction = UISwipeGestureRecognizerDirectionUp;
    [_gameboard addGestureRecognizer:upSwipe];
    
    UISwipeGestureRecognizer *downSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                                                    action:@selector(downButtonTapped)];
    downSwipe.numberOfTouchesRequired = 1;
    downSwipe.direction = UISwipeGestureRecognizerDirectionDown;
    [_gameboard addGestureRecognizer:downSwipe];
    
    UISwipeGestureRecognizer *leftSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                                                    action:@selector(leftButtonTapped)];
    leftSwipe.numberOfTouchesRequired = 1;
    leftSwipe.direction = UISwipeGestureRecognizerDirectionLeft;
    [_gameboard addGestureRecognizer:leftSwipe];
    
    UISwipeGestureRecognizer *rightSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                                                     action:@selector(rightButtonTapped)];
    rightSwipe.numberOfTouchesRequired = 1;
    rightSwipe.direction = UISwipeGestureRecognizerDirectionRight;
    [_gameboard addGestureRecognizer:rightSwipe];
}
#pragma mark - 设置游戏界面
- (void)setupGame {
    
    // 返回按钮
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_game2048_back"]
                                                                 style:UIBarButtonItemStylePlain
                                                                target:self
                                                                action:@selector(backButtonAction:)];
    [self.navigationItem setLeftBarButtonItem:backItem];
    
    // 左右间隔
    float space = (kScreenWidth - 20*2 - 110 - 95 - 95)/2;
    
    // 获得的邦币视图
    _bangBiView = [CYCBangBiScoreView bangBiScoreViewWithCornerRadius:5
                                                      backgroundColor:[UIColor colorWithRed:238/255.0 green:223/255.0 blue:203/255.0 alpha:1]
                                                            textColor:[UIColor whiteColor]
                                                             textFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:32]
                                                                frame:CGRectMake(20, 15, 110, 115)];
    [self.view addSubview:_bangBiView];
    
    // 是否打开成绩面板
    if (self.useScoreView) {
        _scoreView = [F3HScoreView scoreViewWithCornerRadius:5
                                             backgroundColor:[UIColor colorWithRed:238/255.0 green:223/255.0 blue:203/255.0 alpha:1]
                                                   textColor:[UIColor colorWithRed:120/255.0 green:110/255.0 blue:100/255.0 alpha:1]
                                                    textFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:32]
                                                       frame:CGRectMake(20 + 110 + space, 15, 95, 64)];
        [self.view addSubview:_scoreView];
    }
    
    // 排行榜按钮
    UIButton *rankButton = [UIButton buttonWithType:UIButtonTypeCustom];
    rankButton.frame = CGRectMake(20 + 110 + space, 15 + 64 + 15, 95, 36);
    [rankButton setImage:[UIImage imageNamed:@"icon_ranking_score"] forState:UIControlStateNormal];
    [rankButton addTarget:self action:@selector(rankButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:rankButton];
    
    // 最高成绩
    _bestScoreView = [CYCBestScoreView bestScoreViewWithCornerRadius:5
                                                     backgroundColor:[UIColor colorWithRed:238/255.0 green:223/255.0 blue:203/255.0 alpha:1]
                                                           textColor:[UIColor colorWithRed:120/255.0 green:110/255.0 blue:100/255.0 alpha:1]
                                                            textFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:32]
                                                           bestScore:0
                                                               frame:CGRectMake(20 + 110 + 95 + space*2, 15, 95, 64)];
    [self.view addSubview:_bestScoreView];
    
    // 重置按钮
    
    UIButton *resetButton = [UIButton buttonWithType:UIButtonTypeCustom];
    resetButton.frame = CGRectMake(20 + 110 + 95 + space*2, 15 + 64 + 15, 95, 36);
    [resetButton setImage:[UIImage imageNamed:@"icon_game2048_reset"] forState:UIControlStateNormal];
    [resetButton addTarget:self action:@selector(resetButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:resetButton];
    
    
    // 提示
    _tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 15 + 115 + 20, kScreenWidth - 20*2, 20)];
    _tipLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:20];
    _tipLabel.textColor = [UIColor colorWithRed:158/255.0 green:158/255.0 blue:158/255.0 alpha:1];
    _tipLabel.adjustsFontSizeToFitWidth = YES;
    _tipLabel.text = @"移动相同数字合成更大数字，并获取邦币";
    [self.view addSubview:_tipLabel];
    
    
    
    // 游戏主视图
    CGFloat padding = (self.dimension > 5) ? 3.0 : 6.0; // 小格子间隙
    CGFloat cellWidth = floorf((kScreenWidth - 40 - padding*(self.dimension+1))/((float)self.dimension)); // 小格子大小
    if (cellWidth < 30) {   // 控制小格子最小宽高
        cellWidth = 30;
    }
    F3HGameboardView *gameboard = [F3HGameboardView gameboardWithDimension:self.dimension
                                                                 cellWidth:cellWidth
                                                               cellPadding:padding
                                                              cornerRadius:6
                                                           backgroundColor:[UIColor colorWithRed:185/255.0 green:172/255.0 blue:160/255.0 alpha:1]
                                                           foregroundColor:[UIColor colorWithRed:202/255.0 green:190/255.0 blue:180/255.0 alpha:1]];
    CGRect gameboardFrame = gameboard.frame;
    gameboardFrame.origin.y = 15 + 115 + 20 + 20 + 20;
    gameboard.frame = gameboardFrame;
    [self.view addSubview:gameboard];
    self.gameboard = gameboard;
    
    // 创建游戏数据模型
    F3HGameModel *model = [F3HGameModel gameModelWithDimension:self.dimension
                                                      winValue:self.threshold
                                                      delegate:self];
    [model insertAtRandomLocationTileWithValue:2];
    [model insertAtRandomLocationTileWithValue:2];
    self.model = model;
}




#pragma mark - Private API
// 判断成绩 如果
- (void)followUp {
    // This is the earliest point the user can win
    if ([self.model userHasWon]) {
        [self.delegate gameFinishedWithVictory:YES score:self.model.score];
        // 提示，注意：不能使用模态弹出
    }
    else {
        NSInteger rand = arc4random_uniform(10);
        if (rand == 1) {
            [self.model insertAtRandomLocationTileWithValue:4];
        }
        else {
            [self.model insertAtRandomLocationTileWithValue:2];
        }
        // At this point, the user may lose
        if ([self.model userHasLost]) {
            [self.delegate gameFinishedWithVictory:NO score:self.model.score];
            // 提示，注意：不能使用模态弹出
        }
    }
}


#pragma mark - Model Protocol

- (void)moveTileFromIndexPath:(NSIndexPath *)fromPath toIndexPath:(NSIndexPath *)toPath newValue:(NSUInteger)value {
    [self.gameboard moveTileAtIndexPath:fromPath toIndexPath:toPath withValue:value];
}

- (void)moveTileOne:(NSIndexPath *)startA tileTwo:(NSIndexPath *)startB toIndexPath:(NSIndexPath *)end newValue:(NSUInteger)value {
    [self.gameboard moveTileOne:startA tileTwo:startB toIndexPath:end withValue:value];
}

- (void)insertTileAtIndexPath:(NSIndexPath *)path value:(NSUInteger)value {
    [self.gameboard insertTileAtIndexPath:path withValue:value];
}

- (void)scoreChanged:(NSInteger)newScore {
    self.scoreView.score = newScore;
}


#pragma mark - 手势响应
- (void)upButtonTapped {
    [self.model performMoveInDirection:F3HMoveDirectionUp completionBlock:^(BOOL changed) {
        if (changed) [self followUp];
    }];
}

- (void)downButtonTapped {
    [self.model performMoveInDirection:F3HMoveDirectionDown completionBlock:^(BOOL changed) {
        if (changed) [self followUp];
    }];
}

- (void)leftButtonTapped {
    [self.model performMoveInDirection:F3HMoveDirectionLeft completionBlock:^(BOOL changed) {
        if (changed) [self followUp];
    }];
}

- (void)rightButtonTapped {
    [self.model performMoveInDirection:F3HMoveDirectionRight completionBlock:^(BOOL changed) {
        if (changed) [self followUp];
    }];
}

#pragma mark - 按钮响应
- (void)backButtonAction:(UIBarButtonItem *)button {

    [self dismissViewControllerAnimated:YES completion:nil];

}

- (void)rankButtonAction:(UIButton *)button {

    

}

- (void)resetButtonAction:(UIButton *)button {

    [self.gameboard reset];
    [self.model reset];
    [self.model insertAtRandomLocationTileWithValue:2];
    [self.model insertAtRandomLocationTileWithValue:2];

}

- (void)resetButtonTapped {
    [self.gameboard reset];
    [self.model reset];
    [self.model insertAtRandomLocationTileWithValue:2];
    [self.model insertAtRandomLocationTileWithValue:2];
}

- (void)exitButtonTapped {
    [self dismissViewControllerAnimated:YES completion:nil];
}




@end



/*
 
 // 是否打开了允许按钮控制
 if (self.useControlView) {
 controlView = [F3HControlView controlViewWithCornerRadius:5
 backgroundColor:[UIColor blackColor]
 movementButtons:YES
 exitButton:NO
 delegate:self];
 totalHeight += (ELEMENT_SPACING + controlView.bounds.size.height);
 self.controlView = controlView;
 }

 
 if (self.useScoreView) {
 CGRect scoreFrame = scoreView.frame;
 scoreFrame.origin.x = 0.5*(self.view.bounds.size.width - scoreFrame.size.width);
 scoreFrame.origin.y = currentTop;
 scoreView.frame = scoreFrame;
 [self.view addSubview:scoreView];
 currentTop += (scoreFrame.size.height + ELEMENT_SPACING);
 }

 if (self.useControlView) {
 CGRect controlFrame = controlView.frame;
 controlFrame.origin.x = 0.5*(self.view.bounds.size.width - controlFrame.size.width);
 controlFrame.origin.y = currentTop;
 controlView.frame = controlFrame;
 [self.view addSubview:controlView];
 }
 
 //-----------------------------------------------------计算并设置frame-----------------------------------------------------
 // 计算UI的Y起点，如果小于0那么从0开始
 CGFloat currentTop = 0.5*(self.view.bounds.size.height - totalHeight);
 if (currentTop < 0) {
 currentTop = 0;
 }


 CGRect gameboardFrame = gameboard.frame;
 gameboardFrame.origin.x = 0.5*(self.view.bounds.size.width - gameboardFrame.size.width);
 gameboardFrame.origin.y = currentTop;
 gameboard.frame = gameboardFrame;
 
 currentTop += (gameboardFrame.size.height + ELEMENT_SPACING);






























 
 */


































