//
//  CNetTool.h
//  XiaoHuiBang
//
//  Created by mac on 16/11/17.
//  Copyright © 2016年 消汇邦. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <AFNetworking.h>
#import <SVProgressHUD.h>



@interface CNetTool : NSObject



// 获取动态
+ (void)loadAboutWithParameters:(id)parameters
                        success:(void (^)(id response))success
                        failure:(void (^)(NSError *err))failure;

// 发表动态(不含图片)
+ (void)postAboutWithParameters:(id)parameters
                        success:(void (^)(id response))success
                        failure:(void (^)(NSError *err))failure;

// 发表动态(含图片)
+ (void)postAboutWithParameters:(id)parameters
                           data:(NSMutableArray *)dataArr
                        success:(void (^)(id response))success
                        failure:(void (^)(NSError *err))failure;

// 点赞功能
+ (void)postProWithParameters:(id)parameters
                        success:(void (^)(id response))success
                        failure:(void (^)(NSError *err))failure;


// 删除动态
+ (void)deleteAboutWithParameters:(id)parameters
                          success:(void (^)(id response))success
                          failure:(void (^)(NSError *err))failure;

// 评论功能
+ (void)postCommentWithParameters:(id)parameters
                          success:(void (^)(id response))success
                          failure:(void (^)(NSError *err))failure;

// 获取个人动态
+ (void)loadPersonAboutWithParameters:(id)parameters
                        success:(void (^)(id response))success
                        failure:(void (^)(NSError *err))failure;


// 获取单条动态
+ (void)loadOneAboutWithParameters:(id)parameters
                           success:(void (^)(id response))success
                           failure:(void (^)(NSError *err))failure;

// 搜索动态
+ (void)searchAboutWithParameters:(id)parameters
                          success:(void (^)(id response))success
                          failure:(void (^)(NSError *err))failure;

// 收藏文本
+ (void)collectWithParameters:(id)parameters
                      success:(void (^)(id response))success
                      failure:(void (^)(NSError *err))failure;

// 收藏图片
+ (void)collectImageWithParameters:(id)parameters
                              data:(NSData *)imageData
                           success:(void (^)(id response))success
                           failure:(void (^)(NSError *err))failure;

















@end
