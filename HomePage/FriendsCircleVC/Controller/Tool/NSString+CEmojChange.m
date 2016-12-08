//
//  NSString+CEmojChange.m
//  emoj
//
//  Created by mac on 16/12/8.
//  Copyright © 2016年 CYC. All rights reserved.
//

#import "NSString+CEmojChange.h"

#define EMOJI_CODE_TO_SYMBOL(x) ((((0x808080F0 | (x & 0x3F000) >> 4) | (x & 0xFC0) << 10) | (x & 0x1C0000) << 18) | (x & 0x3F) << 24);


@implementation NSString (CEmojChange)


// 表情转文字
- (NSString *)changeToString {
    
    NSMutableString *mStr = [NSMutableString string];
    
    [self enumerateSubstringsInRange:NSMakeRange(0, self.length)
                             options:NSStringEnumerationByComposedCharacterSequences
                          usingBlock:^(NSString * _Nullable substring, NSRange substringRange, NSRange enclosingRange, BOOL * _Nonnull stop) {
                              
                              // 判断是否是表情
                              const unichar hs = [substring characterAtIndex:0];
                              if (0xd800 <= hs && hs <= 0xdbff) {
                                  if (substring.length > 1) {
                                      const unichar ls = [substring characterAtIndex:1];
                                      const int uc = ((hs - 0xd800) * 0x400) + (ls - 0xdc00) + 0x10000;
                                      if (0x1d000 <= uc && uc <= 0x1f77f) {
                                          
                                          // 将表情转换成int
                                          NSString *tempStr = [NSString stringWithFormat:@"[%d]", uc];
                                          // 将int转换成字符串
                                          [mStr appendString:tempStr];
                                      } else {
                                          [mStr appendString:substring];
                                      }
                                  } else {
                                      [mStr appendString:substring];
                                  }
                                  
                              } else {
                                  [mStr appendString:substring];
                              }
                              
                              
                          }];

    return mStr;

}





// 文字转表情
- (NSString *)changeToEmoj {
    
    NSMutableString *mStr = [NSMutableString string];
    __block int count = 0;
    [self enumerateSubstringsInRange:NSMakeRange(0, self.length)
                             options:NSStringEnumerationByComposedCharacterSequences
                          usingBlock:^(NSString * _Nullable substring, NSRange substringRange, NSRange enclosingRange, BOOL * _Nonnull stop) {
                              
                              if ([substring isEqualToString:@"["]) {
                                  NSString *tempStr = [self substringWithRange:NSMakeRange(substringRange.location+1, 6)];
                                  int tempInt = EMOJI_CODE_TO_SYMBOL([tempStr intValue]);
                                  NSString *emojStr = [[NSString alloc] initWithBytes:&tempInt
                                                                               length:sizeof(tempInt)
                                                                             encoding:NSUTF8StringEncoding];
                                  if (emojStr != nil) {
                                      count = 8;
                                      [mStr appendString:emojStr];
                                  } else {
                                      [mStr appendString:@"["];
                                  }
                                  
                                  
                              } else {
                                  // [之后的7位就不要拼接了
                                  if (count == 0) {
                                      [mStr appendString:substring];
                                  }
                                  
                              }
                              
                              if (count > 0) {
                                  count--;
                              }
                              
                          }];

    return mStr;

}







































@end
