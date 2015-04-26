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
#import "AssistantClient.h"
#import <LFHeatMap/LFHeatMap.h>
#import "CustomSyncTileLayer.h"

static NSString *const kLatitude = @"latitude";
static NSString *const kLongitude = @"longitude";
static NSString *const kMagnitude = @"magnitude";

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Configure Location Manager
    [self configureLocationManager];
    
    // Configure Map View
    [self configureMapView];
    
    // Add Heat Map
    [self configureTestPoint];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES];
}

#pragma mark -
#pragma mark UI Methods

- (void)configureMapView {
    CLLocation *location = self.locationManager.location;
    
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:location.coordinate.latitude
                                                            longitude:location.coordinate.longitude
                                                                 zoom:0];
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

- (void)configureTestPoint {
    // get data
    NSString *dataFile = [[NSBundle mainBundle] pathForResource:@"quake" ofType:@"plist"];
    NSArray *quakeData = [[NSArray alloc] initWithContentsOfFile:dataFile];
    
    NSMutableArray *weights = [[NSMutableArray alloc] initWithCapacity:[quakeData count]];
    NSMutableArray *points = [[NSMutableArray alloc] initWithCapacity:[quakeData count]];
    for (NSDictionary *reading in quakeData) {
        CLLocationDegrees latitude = [[reading objectForKey:kLatitude] doubleValue];
        CLLocationDegrees longitude = [[reading objectForKey:kLongitude] doubleValue];
        double magnitude = [[reading objectForKey:kMagnitude] doubleValue];
        
//        CLLocation *location = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
        CGPoint point = [_mapView convertPoint:CGPointMake(latitude, longitude) toCoordinateSpace:_mapView];
        [points addObject:[NSValue valueWithCGPoint:point]];
        
        [weights addObject:[NSNumber numberWithInteger:(magnitude * 10)]];
    }
    
    UIImage *heatMapImage = [LFHeatMap heatMapWithRect:[UIScreen mainScreen].bounds boost:3 points:points weights:weights];
    
    CustomSyncTileLayer *customSyncTileLayer = [[CustomSyncTileLayer alloc] initWithHeatMapImage:heatMapImage zoom:3];
    customSyncTileLayer.map = _mapView;
}

#pragma -
#pragma mark Memory Warning

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
                                                                 zoom:0];
    [self.mapView animateToCameraPosition:camera];
}

@end
