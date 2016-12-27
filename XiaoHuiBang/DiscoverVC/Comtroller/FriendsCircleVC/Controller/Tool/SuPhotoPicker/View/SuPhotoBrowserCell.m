//
//  SuPhotoBrowserCell.m
//  LazyWeather
//
//  Created by KevinSu on 15/12/6.
//  Copyright © 2015年 SuXiaoMing. All rights reserved.
//

#import "SuPhotoBrowserCell.h"

@implementation SuPhotoBrowserCell

// 右上角的选择按钮，选中后会执行block，传递单元格的选中状态
- (IBAction)selectBtnAction:(UIButton *)sender {
    sender.selected = !sender.selected;
    if (self.selectedBlock) self.selectedBlock(sender.selected);
}

// 选中单元格，执行block
- (IBAction)imageTapAction:(UIButton *)sender {
    if (self.imgTapBlock) self.imgTapBlock();
}

@end
