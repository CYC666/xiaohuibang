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

@interface LocationController () <MKMapViewDelegate> {

    NSString *_placeName;
    double _lat;
    double _lon;
    
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
    
    
}


- (void)cancelShow:(UIBarButtonItem *)item {

    [self dismissViewControllerAnimated:YES completion:nil];

}


#pragma mark - 代理方法
//- (nullable MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
//
//    [annotation setCoordinate:CLLocationCoordinate2DMake(_lat, _lon)];
//
//}































@end
