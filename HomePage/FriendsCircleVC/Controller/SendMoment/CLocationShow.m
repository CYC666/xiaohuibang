//
//  CLocationShow.m
//  XiaoHuiBang
//
//  Created by mac on 16/12/19.
//  Copyright © 2016年 消汇邦. All rights reserved.
//

#import "CLocationShow.h"
#import <CoreLocation/CoreLocation.h>
#import "LocationCell.h"
#import "LocationSearchBar.h"

#define kScreenWidth [UIScreen mainScreen].bounds.size.width    // 屏宽
#define kScreenHeight [UIScreen mainScreen].bounds.size.height  // 屏高


@interface CLocationShow () <UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate> {

    CLLocationManager *_locationC;  // 定位对象
    CLLocation *_location;          // 定位
    CLGeocoder *_geocoderC;         // 反地理编码对象
    CLPlacemark *_place;            // 反地理编码的结果
    
    UITableView *_locationTable;    // 显示地理位置的表视图
    
    NSMutableArray *_placeMakeArray;// 储存定位
    
    CALayer *_grayLayer;             // 点击搜索框，顶部显示的灰色图层

}



@end

@implementation CLocationShow

- (void)viewDidLoad {
    [super viewDidLoad];

    _placeMakeArray = [NSMutableArray array];
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 40)];
    title.text = @"选择你的位置";
    title.font = [UIFont systemFontOfSize:20];
    title.textAlignment = NSTextAlignmentCenter;
    title.textColor = [UIColor colorWithRed:238/255.0 green:238/255.0 blue:238/255.0 alpha:1];
    self.navigationItem.titleView = title;
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:46/255.0 green:145/255.0 blue:253/255.0 alpha:1];
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithTitle:@"取消"
                                                                 style:UIBarButtonItemStylePlain
                                                                target:self
                                                                action:@selector(cancelPicker:)];
    [self.navigationItem setLeftBarButtonItem:leftItem];
    UIBarButtonItem *rigthItem = [[UIBarButtonItem alloc] initWithTitle:@"不使用定位"
                                                                 style:UIBarButtonItemStylePlain
                                                                target:self
                                                                action:@selector(nilLocation:)];
    [self.navigationItem setRightBarButtonItem:rigthItem];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    _locationC = [[CLLocationManager alloc] init];
    if([[[UIDevice currentDevice]systemVersion]floatValue] >= 8) {
        
        [_locationC requestWhenInUseAuthorization];           // 请求定位服务
        
    }    
    _locationC.delegate = self;
    // 开始定位
    [_locationC startUpdatingLocation];
    
}

// 取消按钮
- (void)cancelPicker:(UIBarButtonItem *)item {
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

// 不使用定位
- (void)nilLocation:(UIBarButtonItem *)item {

    self.locationBlock(@"");
    [self dismissViewControllerAnimated:YES completion:nil];

}




#pragma mark - 表视图代理方法
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return _placeMakeArray.count;

}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    LocationCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"LocationCell" owner:nil options:nil] lastObject];
    // 取出定位
    MKPlacemark *place = _placeMakeArray[indexPath.row];
    cell.title.text = place.name;
    cell.detial.text = [NSString stringWithFormat:@"%@%@", place.locality, place.thoroughfare];
    
    return cell;

}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    return 50;

}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {

    LocationSearchBar *searchBar = [[LocationSearchBar alloc] initWithFrame:CGRectZero];
    
    __weak CLocationShow *weakSelf = self;
    // 点击了输入框
    searchBar.searchBarEditBeginBlock = ^() {
    
        [weakSelf touchSearchBarAnimate];
    
    };
    // 搜索点击return，进行搜索
    searchBar.searchBarReturnBlock = ^() {
    
        
        
    };
    // 点击了取消按钮
    searchBar.searchBarCancelBlock = ^() {
    
        [weakSelf touchSearchBarCancelAnimate];
    
    };
    return searchBar;
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {

    return 45;

}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    // 传过去的数据格式
    // 地名+纬度+经度
    NSString *placeStr;
    __block NSString *outStr;
    MKPlacemark *place = _placeMakeArray[indexPath.row];
    CLLocationCoordinate2D coordinate2D = place.coordinate;
    placeStr = [NSString stringWithFormat:@"%@%@", place.locality, place.name];
    outStr = [NSString stringWithFormat:@"%@+%.8f+%.8f", placeStr, coordinate2D.latitude, coordinate2D.longitude];
    // 将数据传到发送动态界面
    self.locationBlock(outStr);
    
    // 返回
    [self dismissViewControllerAnimated:YES completion:nil];

}

#pragma mark - 定位
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {

    // 接收定位信息
    _location = locations.firstObject;
    
    
    // 反地理编码
    _geocoderC = [[CLGeocoder alloc] init];
    [_geocoderC reverseGeocodeLocation:_location
                     completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {

                         _place = placemarks.firstObject;
                         MKPlacemark *placeMark = [[MKPlacemark alloc] initWithPlacemark:placemarks.firstObject];
                         [_placeMakeArray addObject:placeMark];

                     }];
    
    [self searchSidePoint:_location.coordinate withText:@"all"];

    // 成功定位后，关闭定位
    [_locationC stopUpdatingLocation];

}

// 附近兴趣点检索
- (void)searchSidePoint:(CLLocationCoordinate2D)coor2D withText:(NSString *)text {

    //创建一个位置信息对象，第一个参数为经纬度，第二个为纬度检索范围，单位为米，第三个为经度检索范围，单位为米
    
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(coor2D, 100, 100);
    
    //初始化一个检索请求对象
    
    MKLocalSearchRequest * req = [[MKLocalSearchRequest alloc] init];
    
    //设置检索参数
    
    req.region = region;
    
    //兴趣点关键字
    
    req.naturalLanguageQuery = text;
    
    //初始化检索
    
    MKLocalSearch *ser = [[MKLocalSearch alloc] initWithRequest:req];
    
    //开始检索，结果返回在block中
    __block NSArray *array;
    [ser startWithCompletionHandler:^(MKLocalSearchResponse *response, NSError *error) {
        
        //兴趣点节点数组
        
        array = [NSArray arrayWithArray:response.mapItems];
        for (MKMapItem *item in array) {
            [_placeMakeArray addObject:item.placemark];
        }
        
        // 去重复
        NSMutableDictionary *placeDic = [NSMutableDictionary dictionary];
        for (MKMapItem *item in _placeMakeArray) {
            [placeDic setObject:item forKey:item.name];
        }
        [_placeMakeArray removeAllObjects];
        [_placeMakeArray addObjectsFromArray:[placeDic allValues]];
        
        // 表视图显示
        _locationTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 64)
                                                      style:UITableViewStyleGrouped];
        _locationTable.backgroundColor = [UIColor colorWithRed:238/255.0 green:238/255.0 blue:238/255.0 alpha:1];
        _locationTable.delegate = self;
        _locationTable.dataSource = self;
        [self.view addSubview:_locationTable];
        
    }];
    

}

#pragma mark - 点击搜索框做动画
- (void)touchSearchBarAnimate {
    
    // 状态栏颜色
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
    // 添加灰色背景图层
    _grayLayer = [[CALayer alloc] init];
    _grayLayer.frame = CGRectMake(0, -20, kScreenWidth, 20);
    _grayLayer.backgroundColor = [UIColor colorWithRed:238/255.0 green:238/255.0 blue:238/255.0 alpha:1].CGColor;
    [self.view.layer addSublayer:_grayLayer];
    // 其他动画
    [UIView animateWithDuration:.35
                     animations:^{
                         self.navigationController.navigationBar.translucent = YES;
                         self.navigationController.navigationBar.transform = CGAffineTransformMakeTranslation(0, -64);
                     } completion:^(BOOL finished) {
                         [UIView animateWithDuration:.35
                                          animations:^{
                                              _grayLayer.frame = CGRectMake(0, 0, kScreenWidth, 20);
                                              _locationTable.transform = CGAffineTransformMakeTranslation(0, 20);
                                          }];
                     }];
    

}

- (void)touchSearchBarCancelAnimate {

    // 状态栏颜色
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
    [self.view bringSubviewToFront:_locationTable];
    // 其他动画
    [UIView animateWithDuration:.35
                     animations:^{
                         self.navigationController.navigationBar.translucent = NO;
                         self.navigationController.navigationBar.transform = CGAffineTransformIdentity;
                         _locationTable.transform = CGAffineTransformIdentity;
                     } completion:^(BOOL finished) {
                         // 去掉灰色显示层
                         [_grayLayer removeFromSuperlayer];
                         _grayLayer = nil;
                     }];
    

}


















/*
 
 //    [_locationArray addObject:locations.firstObject];
 // 反地理编码
 //    _geocoderC = [[CLGeocoder alloc] init];
 //    [_geocoderC reverseGeocodeLocation:_location
 //                     completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
 //
 //                         _place = placemarks.firstObject;
 //                         // [_placeMakeArray addObject:placemarks.firstObject];
 //
 //                         // 表视图显示
 //                         _locationTable = [[UITableView alloc] initWithFrame:[UIScreen mainScreen].bounds style:UITableViewStylePlain];
 //                         _locationTable.delegate = self;
 //                         _locationTable.dataSource = self;
 //                         [self.view addSubview:_locationTable];
 //
 //                     }];
 
 //- (void)locationManager:(CLLocationManager *)manager
 //    didUpdateToLocation:(CLLocation *)newLocation
 //           fromLocation:(CLLocation *)oldLocation{
 //
 //    // 获取当前所在的城市名
 //    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
 //    //根据经纬度反向地理编译出地址信息
 //    [geocoder reverseGeocodeLocation:newLocation completionHandler:^(NSArray *array, NSError *error) {
 //
 //         if (array.count > 0) {
 //             CLPlacemark *placemark = [array objectAtIndex:0];
 //             [_placeMakeArray addObject:placemark];
 //
 //             // 表视图显示
 //             _locationTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height) style:UITableViewStylePlain];
 //             _locationTable.delegate = self;
 //             _locationTable.dataSource = self;
 //             [self.view addSubview:_locationTable];
 ////
 ////             //将获得的所有信息显示到label上
 ////             //             self.location.text = placemark.name;
 ////             //获取城市
 ////             NSString *city = placemark.locality;
 ////             if (!city) {
 ////                 //四大直辖市的城市信息无法通过locality获得，只能通过获取省份的方法来获得（如果city为空，则可知为直辖市）
 ////                 city = placemark.administrativeArea;
 ////             }
 ////
 ////
 ////             NSString *reString = [NSString stringWithFormat:@"%@/%@/%@",placemark.administrativeArea,placemark.locality,placemark.subLocality];
 ////
 ////
 //
 //
 //         } else if (error == nil && [array count] == 0) {
 //             NSLog(@"定位请求失败");
 //         } else if (error != nil) {
 //             NSLog(@"定位错误信息 = %@", error);
 //         }
 //     }];
 //
 //    //系统会一直更新数据，直到选择停止更新，因为我们只需要获得一次经纬度即可，所以获取之后就停止更新
 //    [manager stopUpdatingLocation];
 //
 //}

 
 //                         CLPlacemark *place = _placeMakeArray.firstObject;
 //                         if (![place.name isEqualToString:placemarks.firstObject.name]) {
 //                             [_placeMakeArray addObject:placemarks.firstObject];
 //                         }

 
 //    if (indexPath.row == 0) {
 //        placeStr = [NSString stringWithFormat:@"%@%@", _place.locality, _place.name];
 //        outStr = [NSString stringWithFormat:@"%@+%.8f+%.8f", placeStr, _place.location.coordinate.latitude, _place.location.coordinate.longitude];
 //    } else {
 //        MKPlacemark *place = _placeMakeArray[indexPath.row];
 //        CLLocationCoordinate2D coordinate2D = place.coordinate;
 //        placeStr = [NSString stringWithFormat:@"%@%@", place.locality, place.name];
 //        outStr = [NSString stringWithFormat:@"%@+%.8f+%.8f", placeStr, coordinate2D.latitude, coordinate2D.longitude];
 //    }

 
 
 
 
 
 */







@end
