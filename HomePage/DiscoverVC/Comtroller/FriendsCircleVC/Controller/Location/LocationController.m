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

@interface LocationController () <CLLocationManagerDelegate> {

    NSString *_placeName;
    double _lat;
    double _lon;
    
    MKMapItem *_currentItem;
    MKMapItem *_toItem;
    
    CLLocationManager *_manager;
    MKMapView *_mapView;
    
    UIBarButtonItem *_rightItem;
    
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
    
    _rightItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_go"]
                                                  style:UIBarButtonItemStylePlain
                                                 target:self
                                                 action:@selector(goToThere:)];
    _rightItem.enabled = NO;
    [self.navigationItem setRightBarButtonItem:_rightItem];
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:46/255.0 green:145/255.0 blue:253/255.0 alpha:1];
    self.view.backgroundColor = [UIColor whiteColor];
    
    // 创建地图
    _mapView = [[MKMapView alloc] initWithFrame:self.view.bounds];
    CLLocationCoordinate2D  coordinate = CLLocationCoordinate2DMake(_lat, _lon);
    MKCoordinateSpan span = MKCoordinateSpanMake(.05, .05);
    [_mapView setRegion:MKCoordinateRegionMake(coordinate, span)];
    [self.view addSubview:_mapView];
    
    // 添加大头针
    MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
    [annotation setCoordinate:CLLocationCoordinate2DMake(_lat, _lon)];
    [annotation setTitle:_placeName];
    [_mapView addAnnotation:annotation];
    
    // 获取当前位置
    _manager = [[CLLocationManager alloc] init];
    if([[[UIDevice currentDevice]systemVersion]floatValue] >=8) {
        
        [_manager requestWhenInUseAuthorization];           // 请求定位服务
        
    }
    
    _manager.delegate = self;
    [_manager startUpdatingLocation];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    
    _mapView.delegate = nil; // 不用时，置nil
    _manager.delegate = nil;
}




- (void)cancelShow:(UIBarButtonItem *)item {

    [self dismissViewControllerAnimated:YES completion:nil];

}

- (void)goToThere:(UIBarButtonItem *)item {
    
    // 提示可选导航工具
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"请选择导航方式"
                                                                       message:nil
                                                                preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *sureAction = [UIAlertAction actionWithTitle:@"苹果地图"
                                                         style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction * _Nonnull action) {
                                                           // 拼接路径
                                                           NSArray *items = [NSArray arrayWithObjects:_currentItem, _toItem, nil];
                                                           NSDictionary *options = @{ MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeTransit,
                                                                                      MKLaunchOptionsMapTypeKey: [NSNumber numberWithInteger:MKMapTypeStandard],
                                                                                      MKLaunchOptionsShowsTrafficKey:@YES };
                                                           
                                                           // 打开苹果自带地图进行导航
                                                           [MKMapItem openMapsWithItems:items launchOptions:options];
                                                       }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消"
                                                           style:UIAlertActionStyleDefault
                                                         handler:nil];
    
    [alert addAction:sureAction];
    [alert addAction:cancelAction];
    [self presentViewController:alert animated:YES completion:nil];
    
    

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
    [_manager stopUpdatingLocation];
    _rightItem.enabled = YES;

}

// 请求定位失败
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {

    // 停止更新地理位置
    [_manager stopUpdatingLocation];

}

//// 当定位允许发生了改变
//- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
//
//    switch (status) {
//            // 用户还未决定
//        case kCLAuthorizationStatusNotDetermined: {
//            break;
//        }
//            // 访问受限(苹果预留选项,暂时没用)
//        case kCLAuthorizationStatusRestricted: {
//            break;
//        }
//            // 定位关闭时和对此APP授权为never时调用
//        case kCLAuthorizationStatusDenied: {
//            // 定位是否可用（是否支持定位或者定位是否开启）
//            if([CLLocationManager locationServicesEnabled]) {
//                // 在此处, 应该提醒用户给此应用授权, 并跳转到"设置"界面让用户进行授权
//                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"定位功能已经被关闭"
//                                                                                   message:@"tip:打开定位可以进行导航"
//                                                                            preferredStyle:UIAlertControllerStyleAlert];
//                UIAlertAction *sureAction = [UIAlertAction actionWithTitle:@"确定"
//                                                                     style:UIAlertActionStyleDefault
//                                                                   handler:^(UIAlertAction * _Nonnull action) {
//                                                                       // 在iOS8.0之后跳转到"设置"界面代码
//                                                                       NSURL *settingURL = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
//                                                                       if([[UIApplication sharedApplication] canOpenURL:settingURL]) {
//                                                                           [[UIApplication sharedApplication] openURL:settingURL];
//                                                                       }
//                                                                   }];
//                UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消"
//                                                                       style:UIAlertActionStyleDefault
//                                                                     handler:nil];
//                
//                [alert addAction:sureAction];
//                [alert addAction:cancelAction];
//                
//            } else {
//
//            }
//            break;
//        }
//            // 获取前后台定位授权
//        case kCLAuthorizationStatusAuthorizedAlways: {
//            //  case kCLAuthorizationStatusAuthorized: // 失效，不建议使用
//            break;
//        }
//            // 获得前台定位授权
//        case kCLAuthorizationStatusAuthorizedWhenInUse: {
//            
//            break;
//        }
//        default:
//            break;
//    }
//
//}






























@end
