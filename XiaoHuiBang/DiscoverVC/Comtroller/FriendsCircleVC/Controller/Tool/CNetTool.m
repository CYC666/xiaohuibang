//
//  CNetTool.m
//  XiaoHuiBang
//
//  Created by mac on 16/11/17.
//  Copyright © 2016年 消汇邦. All rights reserved.
//

#import "CNetTool.h"

@implementation CNetTool


// 获取动态
+ (void)loadAboutWithParameters:(id)parameters
                        success:(void (^)(id response))success
                        failure:(void (^)(NSError *err))failure{

    NSString *urlStr = @"http://115.28.6.7/rongyun.php/Home/about/about_see";
    AFHTTPSessionManager *session = [AFHTTPSessionManager manager];
    session.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html", nil];
    [session POST:urlStr
       parameters:parameters
         progress:nil
          success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
              success(responseObject);
          } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
              failure(error);
          }];


}


// 发表动态(纯文字)
+ (void)postAboutWithParameters:(id)parameters
                        success:(void (^)(id response))success
                        failure:(void (^)(NSError *err))failure {

    NSString *urlStr = @"http://115.28.6.7/rongyun.php/Home/about/about_publish";
    AFHTTPSessionManager *session = [AFHTTPSessionManager manager];
    session.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html", nil];
    [session POST:urlStr
       parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
           
       } progress:nil
          success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
              success(responseObject);
          } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
              failure(error);
          }];

}




// 发表动态(含图片)
+ (void)postAboutWithParameters:(id)parameters
                           data:(NSMutableArray *)dataArr
                        success:(void (^)(id response))success
                        failure:(void (^)(NSError *err))failure {

    NSString *urlStr = @"http://115.28.6.7/rongyun.php/Home/about/about_publish";
    AFHTTPSessionManager *session = [AFHTTPSessionManager manager];
    session.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html", nil];
    [session POST:urlStr
       parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
           
           for (int i = 0; i < dataArr.count; i++) {
               NSData *imageData = dataArr[i];
               // 上传的参数名
               NSString * name = [NSString stringWithFormat:@"CYCimage%d", i+1];
               // 上传filename
               NSString * fileName = [NSString stringWithFormat:@"%@.jpg", name];
               [formData appendPartWithFileData:imageData name:name fileName:fileName mimeType:@"image/jpg"];
           }
           
       } progress:nil
          success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
              success(responseObject);
          } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
              failure(error);
          }];
    
    

}

// 发表动态(含视频)
+ (void)postAboutWithParameters:(id)parameters
                      movieData:(NSData *)movieData
                        success:(void (^)(id response))success
                        failure:(void (^)(NSError *err))failure {
    
    NSString *urlStr = @"http://115.28.6.7/rongyun.php/Home/about/about_publish";
    AFHTTPSessionManager *session = [AFHTTPSessionManager manager];
    session.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html", nil];
    [session POST:urlStr
       parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
           
           [formData appendPartWithFileData:movieData name:@"movie" fileName:@"movie.mov" mimeType:@"movie/mov"];
           
       } progress:nil
          success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
              success(responseObject);
          } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
              failure(error);
          }];
    
    
    
}


// 点赞功能
+ (void)postProWithParameters:(id)parameters
                      success:(void (^)(id response))success
                      failure:(void (^)(NSError *err))failure {

    NSString *urlStr = @"http://115.28.6.7/rongyun.php/Home/about/about_praise";
    AFHTTPSessionManager *session = [AFHTTPSessionManager manager];
    session.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html", nil];
    [session POST:urlStr
       parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
           
       } progress:nil
          success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
              success(responseObject);
          } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
              failure(error);
          }];


}


// 删除动态
+ (void)deleteAboutWithParameters:(id)parameters
                          success:(void (^)(id response))success
                          failure:(void (^)(NSError *err))failure {

    NSString *urlStr = @"http://115.28.6.7/rongyun.php/Home/about/about_remove";
    AFHTTPSessionManager *session = [AFHTTPSessionManager manager];
    session.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html", nil];
    [session POST:urlStr
       parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
           
       } progress:nil
          success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
              success(responseObject);
          } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
              failure(error);
          }];

}

// 评论功能
+ (void)postCommentWithParameters:(id)parameters
                          success:(void (^)(id response))success
                          failure:(void (^)(NSError *err))failure {

    NSString *urlStr = @"http://115.28.6.7/rongyun.php/Home/about/about_aveluate";
    AFHTTPSessionManager *session = [AFHTTPSessionManager manager];
    session.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html", nil];
    [session POST:urlStr
       parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
           
       } progress:nil
          success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
              success(responseObject);
          } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
              failure(error);
          }];

}

// 获取个人动态
+ (void)loadPersonAboutWithParameters:(id)parameters
                              success:(void (^)(id response))success
                              failure:(void (^)(NSError *err))failure {

    NSString *urlStr = @"http://115.28.6.7/rongyun.php/Home/about/about_user";
    AFHTTPSessionManager *session = [AFHTTPSessionManager manager];
    session.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html", nil];
    [session POST:urlStr
       parameters:parameters
         progress:nil
          success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
              success(responseObject);
          } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
              failure(error);
          }];

}

// 获取单条动态
+ (void)loadOneAboutWithParameters:(id)parameters
                           success:(void (^)(id response))success
                           failure:(void (^)(NSError *err))failure {
    
    NSString *urlStr = @"http://115.28.6.7/rongyun.php/Home/about/about_one";
    AFHTTPSessionManager *session = [AFHTTPSessionManager manager];
    session.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html", nil];
    [session POST:urlStr
       parameters:parameters
         progress:nil
          success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
              success(responseObject);
          } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
              failure(error);
          }];
    
}


// 搜索动态
+ (void)searchAboutWithParameters:(id)parameters
                          success:(void (^)(id response))success
                          failure:(void (^)(NSError *err))failure {

    NSString *urlStr = @"http://115.28.6.7/rongyun.php/Home/about/about_like";
    AFHTTPSessionManager *session = [AFHTTPSessionManager manager];
    session.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html", nil];
    [session POST:urlStr
       parameters:parameters
         progress:nil
          success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
              success(responseObject);
          } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
              failure(error);
          }];

}


// 收藏
+ (void)collectWithParameters:(id)parameters
                      success:(void (^)(id response))success
                      failure:(void (^)(NSError *err))failure {

    NSString *urlStr = @"http://115.28.6.7/rongyun.php/Home/collection/coll_add";
    AFHTTPSessionManager *session = [AFHTTPSessionManager manager];
    session.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html", nil];
    [session POST:urlStr
       parameters:parameters
         progress:nil
          success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
              success(responseObject);
          } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
              failure(error);
          }];

}

// 邦友圈权限设置查看
+ (void)jurisdictionSeeWithParameters:(id)parameters
                              success:(void (^)(id response))success
                              failure:(void (^)(NSError *err))failure {
    
    NSString *urlStr = @"http://115.28.6.7/rongyun.php/Home/about/user_perm";
    AFHTTPSessionManager *session = [AFHTTPSessionManager manager];
    session.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html", nil];
    [session POST:urlStr
       parameters:parameters
         progress:nil
          success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
              success(responseObject);
          } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
              failure(error);
          }];
    
}

// 邦友圈权限设置添加
+ (void)jurisdictionAddWithParameters:(id)parameters
                           success:(void (^)(id response))success
                           failure:(void (^)(NSError *err))failure {

    NSString *urlStr = @"http://115.28.6.7/rongyun.php/Home/about/about_perm_add";
    AFHTTPSessionManager *session = [AFHTTPSessionManager manager];
    session.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html", nil];
    [session POST:urlStr
       parameters:parameters
         progress:nil
          success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
              success(responseObject);
          } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
              failure(error);
          }];

}

// 邦友圈权限设置删除
+ (void)jurisdictionDeleteWithParameters:(id)parameters
                                 success:(void (^)(id response))success
                                 failure:(void (^)(NSError *err))failure {

    NSString *urlStr = @"http://115.28.6.7/rongyun.php/Home/about/about_perm_rm";
    AFHTTPSessionManager *session = [AFHTTPSessionManager manager];
    session.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html", nil];
    [session POST:urlStr
       parameters:parameters
         progress:nil
          success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
              success(responseObject);
          } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
              failure(error);
          }];

}

// 上传最佳成绩
+ (void)postBestScoreWithParameters:(id)parameters
                            success:(void (^)(id response))success
                            failure:(void (^)(NSError *err))failure {

    NSString *urlStr = @"http://192.168.1.135/index.php/Home/game/game_data_edit";
    AFHTTPSessionManager *session = [AFHTTPSessionManager manager];
    session.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html", nil];
    [session POST:urlStr
       parameters:parameters
         progress:nil
          success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
              success(responseObject);
          } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
              failure(error);
          }];

}

// 查看排行榜
+ (void)loadBestRankWithParameters:(id)parameters
                           success:(void (^)(id response))success
                           failure:(void (^)(NSError *err))failure {

    NSString *urlStr = @"http://192.168.1.135/index.php/Home/game/game_rank";
    AFHTTPSessionManager *session = [AFHTTPSessionManager manager];
    session.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html", nil];
    [session POST:urlStr
       parameters:parameters
         progress:nil
          success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
              success(responseObject);
          } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
              failure(error);
          }];

}















@end
