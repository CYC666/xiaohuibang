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

@interface CLocationShow () <UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate> {

    CLLocationManager *_locationC;  // 定位对象
    CLLocation *_location;          // 定位
    CLGeocoder *_geocoderC;         // 反地理编码对象
    CLPlacemark *_place;            // 反地理编码的结果
    
    UITableView *_locationTable;    // 显示地理位置的表视图
    
    NSMutableArray *_placeMakeArray;// 储存定位

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
    title.textColor = [UIColor whiteColor];
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
    cell.detial.text = [NSString stringWithFormat:@"%@%@%@", place.administrativeArea, place.locality, place.thoroughfare];
    
    return cell;

}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    return 60;

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    // 传过去的数据格式
    // 地名+纬度+经度
    NSString *placeStr;
    __block NSString *outStr;
    if (indexPath.row == 0) {
        placeStr = [NSString stringWithFormat:@"%@%@", _place.locality, _place.name];
        outStr = [NSString stringWithFormat:@"%@+%.8f+%.8f", placeStr, _place.location.coordinate.latitude, _place.location.coordinate.longitude];
    } else {
        MKPlacemark *place = _placeMakeArray[indexPath.row];
        CLLocationCoordinate2D coordinate2D = place.coordinate;
        placeStr = [NSString stringWithFormat:@"%@%@", place.locality, place.name];
        outStr = [NSString stringWithFormat:@"%@+%.8f+%.8f", placeStr, coordinate2D.latitude, coordinate2D.longitude];
    }
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
                         CLPlacemark *place = _placeMakeArray.firstObject;
                         if (![place.name isEqualToString:placemarks.firstObject.name]) {
                             [_placeMakeArray addObject:placemarks.firstObject];
                         }
                         

                     }];
    
    [self searchSidePoint:_location.coordinate];

    // 成功定位后，关闭定位
    [_locationC stopUpdatingLocation];

}

// 附近兴趣点检索
- (void)searchSidePoint:(CLLocationCoordinate2D)coor2D {

    //创建一个位置信息对象，第一个参数为经纬度，第二个为纬度检索范围，单位为米，第三个为经度检索范围，单位为米
    
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(coor2D, 100, 100);
    
    //初始化一个检索请求对象
    
    MKLocalSearchRequest * req = [[MKLocalSearchRequest alloc] init];
    
    //设置检索参数
    
    req.region=region;
    
    //兴趣点关键字
    
    req.naturalLanguageQuery = @"all";
    
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
        
        // 表视图显示
        _locationTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height) style:UITableViewStylePlain];
        _locationTable.delegate = self;
        _locationTable.dataSource = self;
        [self.view addSubview:_locationTable];
        
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
 

 
 */







@end
