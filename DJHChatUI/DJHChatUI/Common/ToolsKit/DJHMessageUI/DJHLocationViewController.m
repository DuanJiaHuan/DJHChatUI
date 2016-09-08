//
//  DJHLocationViewController.m
//  DJHChatUI
//
//  Created by qch－djh on 16/7/15.
//  Copyright © 2016年 DuanJiaHuan. All rights reserved.
//

#import "DJHLocationViewController.h"

@interface DJHLocationViewController () <MKMapViewDelegate,CLLocationManagerDelegate>

{
    MKMapView *_mapView;
    MKPointAnnotation *_annotation;
    CLLocationManager *_locationManager;
    CLLocationCoordinate2D _currentLocationCoordinate;
    BOOL _isSendLocation;
}

@end

@implementation DJHLocationViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _isSendLocation = YES;
    }
    
    return self;
}

- (instancetype)initWithLocation:(CLLocationCoordinate2D)locationCoordinate
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _isSendLocation = NO;
        _currentLocationCoordinate = locationCoordinate;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"位置信息";
    [self buildView];
}

- (void)buildView
{
    _mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 64, self.view.bounds.size.width, self.view.bounds.size.height - 64)];
    _mapView.delegate = self;
    _mapView.mapType = MKMapTypeStandard;
    _mapView.zoomEnabled = YES;
    [self.view addSubview:_mapView];
    
    if (_isSendLocation) {
        _mapView.showsUserLocation = YES;//显示当前位置
        
        UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"发送" style:(UIBarButtonItemStylePlain) target:self action:@selector(sendLocation)];
        self.navigationItem.rightBarButtonItem = rightBarButtonItem;
        self.navigationItem.rightBarButtonItem.enabled = NO;
        
        [self startLocation];
    } else {
        [self removeToLocation:_currentLocationCoordinate];
    }
}

- (void)sendLocation
{
    if (_delegate && [_delegate respondsToSelector:@selector(sendLocationLatitude:longitude:andAddress:)]) {
        [_delegate sendLocationLatitude:_currentLocationCoordinate.latitude longitude:_currentLocationCoordinate.longitude andAddress:_addressString];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - public

- (void)startLocation
{
    if([CLLocationManager locationServicesEnabled]){
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        _locationManager.distanceFilter = 5;
        _locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;//kCLLocationAccuracyBest;
        if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
            [_locationManager requestWhenInUseAuthorization];
        }
    }
    
    if (_isSendLocation) {
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"正在定位";
}

-(void)createAnnotationWithCoords:(CLLocationCoordinate2D)coords
{
    if (_annotation == nil) {
        _annotation = [[MKPointAnnotation alloc] init];
    }
    else{
        [_mapView removeAnnotation:_annotation];
    }
    _annotation.coordinate = coords;
    _annotation.title = self.addressString;
    [_mapView addAnnotation:_annotation];
}

- (void)removeToLocation:(CLLocationCoordinate2D)locationCoordinate
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    _currentLocationCoordinate = locationCoordinate;
    float zoomLevel = 0.01;
    MKCoordinateRegion region = MKCoordinateRegionMake(_currentLocationCoordinate, MKCoordinateSpanMake(zoomLevel, zoomLevel));
    [_mapView setRegion:[_mapView regionThatFits:region] animated:YES];
    
    if (_isSendLocation) {
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
    
    [self createAnnotationWithCoords:_currentLocationCoordinate];
}

#pragma mark - MKMapViewDelegate

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    __weak typeof(self) weakSelf = self;
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:userLocation.location completionHandler:^(NSArray *array, NSError *error) {
        if (!error && array.count > 0) {
            CLPlacemark *placemark = [array objectAtIndex:0];
            weakSelf.addressString = placemark.name;
            
            [self removeToLocation:userLocation.coordinate];
        }
    }];
}

- (void)mapView:(MKMapView *)mapView didFailToLocateUserWithError:(NSError *)error
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    if (error.code == 0) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                            message:[error.userInfo objectForKey:NSLocalizedRecoverySuggestionErrorKey]
                                                           delegate:nil
                                                  cancelButtonTitle:@"确定"
                                                  otherButtonTitles:nil, nil];
        [alertView show];
    }
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    switch (status) {
        case kCLAuthorizationStatusNotDetermined:
            if ([_locationManager respondsToSelector:@selector(requestAlwaysAuthorization)])
            {
                [_locationManager requestWhenInUseAuthorization];
            }
            break;
        case kCLAuthorizationStatusDenied:
        {
            
        }
        default:
            break;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
