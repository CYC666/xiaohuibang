//
//  NSString+CEmojChange.h
//  emoj
//
//  Created by mac on 16/12/8.
//  Copyright © 2016年 CYC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (CEmojChange)


// 表情转文字
- (NSString *)changeToString;

// 文字转表情
- (NSString *)changeToEmoj;



@end
