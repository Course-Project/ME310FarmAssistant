//
//  ViewController.m
//  ME310FarmAssistant
//
//  Created by Tom Hu on 4/4/15.
//  Copyright (c) 2015 Tom Hu. All rights reserved.
//

#import "ViewController.h"
#import "PopupInfoView.h"
#import "DetailViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Configure Location Manager
    [self configureLocationManager];
    
    // Configure Map View
    [self configureMapView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES];
}

#pragma mark -
#pragma mark Configure

- (void)configureMapView {
    CLLocation *location = self.locationManager.location;
    
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:location.coordinate.latitude
                                                            longitude:location.coordinate.longitude
                                                                 zoom:16];
    self.mapView = [GMSMapView mapWithFrame:CGRectZero camera:camera];
    self.mapView.settings.compassButton = YES;
    self.mapView.settings.myLocationButton = YES;
    self.mapView.myLocationEnabled = YES;
    self.view = self.mapView;
    
    // Marker
    GMSMarker *marker = [[GMSMarker alloc] init];
    marker.position = location.coordinate;
    marker.appearAnimation = kGMSMarkerAnimationPop;
    marker.map = self.mapView;
    
    // Set Delegate
    self.mapView.delegate = self;
}

- (void)configureLocationManager {
    // init Location Manager
    self.locationManager = [[CLLocationManager alloc] init];
    
    if (![CLLocationManager locationServicesEnabled]) {
        NSLog(@"定位服务当前可能尚未打开，请设置打开！");
        return;
    }
    
    // Authorization
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined) {
        [self.locationManager requestWhenInUseAuthorization];
    } else if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse) {
        self.locationManager.delegate = self;
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        CLLocationDistance distance = 10.0; // 10m
        self.locationManager.distanceFilter = distance;
        
        // Start
        [self.locationManager startUpdatingLocation];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark Actions

- (void)didClickInfoWindow {
    DetailViewController *vc = (DetailViewController *)[[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"detailViewController"];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark -
#pragma mark GMSMapViewDelegate

- (UIView *)mapView:(GMSMapView *)mapView markerInfoWindow:(GMSMarker *)marker {
    PopupInfoView *view =  [[[NSBundle mainBundle] loadNibNamed:@"PopupInfoView"
                                                          owner:self
                                                        options:nil] objectAtIndex:0];
    
    return view;
}

- (void)mapView:(GMSMapView *)mapView didTapInfoWindowOfMarker:(GMSMarker *)marker {
    [self didClickInfoWindow];
}

#pragma mark -
#pragma mark CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    CLLocation *location = [locations firstObject];
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:location.coordinate.latitude
                                                            longitude:location.coordinate.longitude
                                                                 zoom:12];
    [self.mapView animateToCameraPosition:camera];
}

@end
