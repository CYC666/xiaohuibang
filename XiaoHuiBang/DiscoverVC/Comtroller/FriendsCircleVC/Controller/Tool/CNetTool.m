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


// 发表动态(不含图片)
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


// 收藏文本
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

// 收藏图片
+ (void)collectImageWithParameters:(id)parameters
                              data:(NSData *)imageData
                           success:(void (^)(id response))success
                           failure:(void (^)(NSError *err))failure {

    NSString *urlStr = @"http://115.28.6.7/rongyun.php/Home/collection/coll_add";
    AFHTTPSessionManager *session = [AFHTTPSessionManager manager];
    session.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html", nil];
    [session POST:urlStr
       parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
           
           NSData *data = imageData;
           // 上传的参数名
           NSString * name = [NSString stringWithFormat:@"CYCimageData"];
           // 上传filename
           NSString * fileName = [NSString stringWithFormat:@"%@.jpg", name];
           [formData appendPartWithFileData:data name:name fileName:fileName mimeType:@"image/jpg"];
           
       } progress:nil
          success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
              success(responseObject);
          } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
              failure(error);
          }];


}


















@end
