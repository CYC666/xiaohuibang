//
//  LocationController.m
//  XiaoHuiBang
//
//  Created by mac on 16/12/19.
//  Copyright © 2016年 消汇邦. All rights reserved.
//

#import "LocationController.h"
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@interface LocationController () <MKMapViewDelegate, CLLocationManagerDelegate> {

    NSString *_placeName;
    double _lat;
    double _lon;
    
    MKMapItem *_currentItem;
    MKMapItem *_toItem;
    
    CLLocationManager *_manager;
    
}

@end

@implementation LocationController


- (instancetype)initWithLocationString:(NSString *)string {

    self = [super init];
    if (self != nil) {
        NSArray *array = [string componentsSeparatedByString:@"+"];
        if (array.count == 3) {
            _placeName = array[0];
            _lat = [array[1] doubleValue];
            _lon = [array[2] doubleValue];
        }
    }
    return self;

}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 40)];
    title.text = _placeName;
    title.textAlignment = NSTextAlignmentCenter;
    title.textColor = [UIColor whiteColor];
    title.font = [UIFont systemFontOfSize:20];
    self.navigationItem.titleView = title;
    
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithTitle:@"取消"
                                                                 style:UIBarButtonItemStylePlain
                                                                target:self
                                                                action:@selector(cancelShow:)];
    [self.navigationItem setLeftBarButtonItem:leftItem];
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:@"前往"
                                                                 style:UIBarButtonItemStylePlain
                                                                target:self
                                                                action:@selector(goToThere:)];
    rightItem.enabled = NO;
    [self.navigationItem setRightBarButtonItem:rightItem];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    // 创建地图
    MKMapView *mapView = [[MKMapView alloc] initWithFrame:self.view.bounds];
    CLLocationCoordinate2D  coordinate = CLLocationCoordinate2DMake(_lat, _lon);
    MKCoordinateSpan span = MKCoordinateSpanMake(.05, .05);
    [mapView setRegion:MKCoordinateRegionMake(coordinate, span)];
    mapView.delegate = self;
    [self.view addSubview:mapView];
    
    // 添加大头针
    MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
    [annotation setCoordinate:CLLocationCoordinate2DMake(_lat, _lon)];
    [annotation setTitle:_placeName];
    [mapView addAnnotation:annotation];
    
    // 获取当前位置
    _manager = [[CLLocationManager alloc] init];
    _manager.delegate = self;
    [_manager startUpdatingLocation];
    
    
}


- (void)cancelShow:(UIBarButtonItem *)item {

    [self dismissViewControllerAnimated:YES completion:nil];

}

- (void)goToThere:(UIBarButtonItem *)item {

    // 拼接路径
    NSArray *items = [NSArray arrayWithObjects:_currentItem, _toItem, nil];
    NSDictionary *options = @{ MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeDriving,
                               MKLaunchOptionsMapTypeKey: [NSNumber numberWithInteger:MKMapTypeStandard],
                               MKLaunchOptionsShowsTrafficKey:@YES };
    
    // 打开苹果自带地图进行导航
    [MKMapItem openMapsWithItems:items launchOptions:options];
    

}


#pragma mark - 代理方法
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {

    // 当前位置
    CLLocation *currentLocation = locations.firstObject;
    CLLocationCoordinate2D currentCoor2D = currentLocation.coordinate;
    _currentItem = [[MKMapItem alloc] initWithPlacemark:[[MKPlacemark alloc] initWithCoordinate:currentCoor2D
                                                                                        addressDictionary:nil]];
    // 目的地
    CLLocationCoordinate2D toCoor2D = CLLocationCoordinate2DMake(_lat, _lon);
    _toItem = [[MKMapItem alloc] initWithPlacemark:[[MKPlacemark alloc] initWithCoordinate:toCoor2D
                                                                                   addressDictionary:nil]];
    
    // 停止更新地理位置
    [manager stopUpdatingLocation];

}































@end
