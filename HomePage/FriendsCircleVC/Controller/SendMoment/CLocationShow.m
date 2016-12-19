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
    

}



@end

@implementation CLocationShow

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 40)];
    title.text = @"你的位置";
    title.font = [UIFont systemFontOfSize:20];
    title.textAlignment = NSTextAlignmentCenter;
    title.textColor = [UIColor whiteColor];
    self.navigationItem.titleView = title;
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithTitle:@"取消"
                                                                 style:UIBarButtonItemStylePlain
                                                                target:self
                                                                action:@selector(cancelPicker:)];
    [self.navigationItem setLeftBarButtonItem:leftItem];
    
    _locationC = [[CLLocationManager alloc] init];
    _locationC.delegate = self;
    // 开始定位
    [_locationC startUpdatingLocation];
    
}

// 取消按钮
- (void)cancelPicker:(UIBarButtonItem *)item {
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}




#pragma mark - 表视图代理方法
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return 1;

}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    LocationCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"LocationCell" owner:nil options:nil] lastObject];
    cell.title.text = [NSString stringWithFormat:@"%@%@", _place.locality, _place.thoroughfare];
    cell.detial.text = [NSString stringWithFormat:@"%@%@%@%@%@", _place.country, _place.administrativeArea, _place.locality, _place.thoroughfare, _place.name];
    
    return cell;

}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    return 60;

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    // 传过去的数据格式
    // 地名+纬度+经度
    CLLocationCoordinate2D coordinate2D = _location.coordinate;
    NSString *placeStr = [NSString stringWithFormat:@"%@%@", _place.locality, _place.thoroughfare];
    __block NSString *outStr = [NSString stringWithFormat:@"%@+%.15f+%.15f", placeStr, coordinate2D.latitude, coordinate2D.longitude];
    self.locationBlock(outStr);
    
    // 返回
    [self dismissViewControllerAnimated:YES completion:nil];

}

#pragma mark - 定位
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations{

    // 接收定位信息
    _location = locations.firstObject;
    
    // 反地理编码
    _geocoderC = [[CLGeocoder alloc] init];
    [_geocoderC reverseGeocodeLocation:_location
                     completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
                         
                         _place = placemarks.firstObject;
                         
                         // 表视图显示
                         _locationTable = [[UITableView alloc] initWithFrame:[UIScreen mainScreen].bounds style:UITableViewStylePlain];
                         _locationTable.delegate = self;
                         _locationTable.dataSource = self;
                         [self.view addSubview:_locationTable];
                         
                     }];
    

    // 成功定位后，关闭定位
    [_locationC stopUpdatingLocation];

}





























@end
