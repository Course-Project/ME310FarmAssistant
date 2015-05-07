//
//  MapViewController.m
//  ME310FarmAssistant
//
//  Created by Tom Hu on 4/26/15.
//  Copyright (c) 2015 Tom Hu. All rights reserved.
//

#import "MapViewController.h"
#import <LFHeatMap/LFHeatMap.h>
#import "DataPointAnnotation.h"
#import "DetailViewController.h"
#import "DataPoint.h"
#import <HSDatePickerViewController/HSDatePickerViewController.h>

static NSString *const kLatitude = @"latitude";
static NSString *const kLongitude = @"longitude";
static NSString *const kMagnitude = @"magnitude";

@interface MapViewController () <CLLocationManagerDelegate, HSDatePickerViewControllerDelegate>

@property (nonatomic, strong) NSMutableArray *locations;
@property (nonatomic, strong) NSMutableArray *weights;
@property (nonatomic, strong) NSMutableArray *dataPoints;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) CLLocationManager *locationManager;

@property (nonatomic, weak) IBOutlet UISwitch *moistureSwitch;
@property (nonatomic, weak) IBOutlet UISwitch *transpirationSwitch;

@end

@implementation MapViewController

#pragma mark Life Circle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Configure Location Manager
    [self configureLocationManager];
    
    // Configure Map
    [self configureMap];
    
    // Configure Data
    [self configureDataPointWithCompletion:^{
        // Configure Heat Map
        [self configureHeatMap];
        
        // Add Annotations
        [self addAnnotations];
        
    }];
    
    HSDatePickerViewController *datePickerViewController = [HSDatePickerViewController new];
    datePickerViewController.delegate = self;
    [self presentViewController:datePickerViewController animated:YES completion:^{
        NSLog(@"Presented");
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // Configure Bars
    [self configureBars];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UI Methods
- (void)configureBars {
    //Status Bar
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
    
    // Navigation Bar
    [self.navigationController setNavigationBarHidden:YES];
}

- (void)configureMap {
    // Show user location
    self.mapView.showsUserLocation = YES;
    
    [self.mapView setCenterCoordinate:self.mapView.userLocation.coordinate animated:YES];
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

- (void)configureHeatMap {
    
    WEAKSELF_T weakSelf = self;
    
    MKCoordinateSpan span = MKCoordinateSpanMake(0.05, 0.05);
    CLLocationCoordinate2D center = CLLocationCoordinate2DMake(37.4263, -122.1720);
    weakSelf.mapView.region = MKCoordinateRegionMake(center, span);
    
    // create overlay view for the heatmap image
    weakSelf.imageView = [[UIImageView alloc] initWithFrame:weakSelf.view.frame];
    weakSelf.imageView.contentMode = UIViewContentModeCenter;
    [weakSelf.view addSubview:weakSelf.imageView];
    
    //crete location array & weight array (temperature)
    weakSelf.locations = [NSMutableArray arrayWithCapacity:weakSelf.dataPoints.count];
    weakSelf.weights = [NSMutableArray arrayWithCapacity:weakSelf.dataPoints.count];
    for (DataPoint *point in weakSelf.dataPoints) {
         CLLocation *location = [[CLLocation alloc] initWithLatitude:point.coordinate.latitude longitude:point.coordinate.longitude];
        [weakSelf.locations addObject:location];
        [weakSelf.weights addObject:point.airTemperature];
    }
    

    
    float boost = 1.0f;
    UIImage *heatmap = [LFHeatMap heatMapForMapView:weakSelf.mapView boost:boost locations:weakSelf.locations weights:weakSelf.weights];
    weakSelf.imageView.image = heatmap;
}

- (void)addAnnotations {
    WEAKSELF_T weakSelf = self;
    for (DataPoint *point in weakSelf.dataPoints) {
        DataPointAnnotation *annotation = [[DataPointAnnotation alloc] initWithID:point.pointID
                                                                         Location:point.coordinate];
        [weakSelf.mapView addAnnotation:annotation];
    }
    
    NSLog(@"Add annotations...");
}

- (void)configureDataPointWithCompletion:(void (^)(void))completed{
    AssistantClient *client = [AssistantClient sharedClient];
    WEAKSELF_T weakSelf = self;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [client getHistoryFrom:nil To:nil success:^(NSArray *points) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        for (id obj in points) {
            DataPoint *point = [[DataPoint alloc]initWithDictionary:obj];
            [weakSelf.dataPoints addObject:point];
        }
        completed();
    }];

}

#pragma mark - MKMapViewDelegate
- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated {
    NSLog(@"Region will change");
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    NSLog(@"Region did change");
    float boost = 1.0f;
    UIImage *heatmap = [LFHeatMap heatMapForMapView:self.mapView boost:boost locations:self.locations weights:self.weights];
    self.imageView.image = heatmap;
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    static NSString *reuse = @"PIN_ANNOTATION";
    MKPinAnnotationView *annotationView = (MKPinAnnotationView *)[self.mapView dequeueReusableAnnotationViewWithIdentifier:reuse];
    if (!annotationView) {
        annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:reuse];
    }
    
    annotationView.pinColor = MKPinAnnotationColorRed;
    annotationView.animatesDrop = YES;
    annotationView.canShowCallout = YES;
    annotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];;
    
    return annotationView;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    NSLog(@"Callout accessory control tapped");
    DetailViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"DetailViewController"];
    vc.pointID = [(DataPointAnnotation *)view.annotation pointID];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    NSLog(@"Did update location");
}

#pragma mark - HSDatePickerViewControllerDelegate
- (void)hsDatePickerPickedDate:(NSDate *)date {
    NSLog(@"Selected date: %@", date);
    
    // TODO: Display historical points
    AssistantClient *client = [AssistantClient sharedClient];
    WEAKSELF_T weakSelf = self;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [client getHistoryFrom:date To:date success:^(NSArray *points) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        NSMutableArray *annotations = [NSMutableArray new];
        for (id obj in points) {
            NSUInteger pointID = [[obj valueForKey:@"id"] unsignedIntegerValue];
            CLLocationDegrees latitude = [[obj valueForKey:@"latitude"] doubleValue];
            CLLocationDegrees longtitude = [[obj valueForKey:@"longtitude"] doubleValue];
            
            DataPointAnnotation *annotation = [[DataPointAnnotation alloc] initWithID:pointID
                                                                             Location:CLLocationCoordinate2DMake(latitude, longtitude)];
            [annotations addObject:annotation];
        }
        [weakSelf.mapView showAnnotations:annotations animated:YES];
    }];
}

- (void)hsDatePickerWillDismissWithQuitMethod:(HSDatePickerQuitMethod)method {
    NSLog(@"Date picker will dismiss");
}

- (void)hsDatePickerDidDismissWithQuitMethod:(HSDatePickerQuitMethod)method {
    NSLog(@"Date picker did dismiss");
}

#pragma mark - Actions
- (IBAction)didChangeTranspirationSwitch:(UISwitch *)sender {
    NSLog(@"Transpiration Switch changed");
    if ([sender isOn]) {
        NSLog(@"ON");
        // Show Transpiration Heat Map
        
    } else {
        NSLog(@"OFF");
    }
}

- (IBAction)didChangeMoistureSwitch:(UISwitch *)sender {
    NSLog(@"Moisture Switch changed");
    if ([sender isOn]) {
        NSLog(@"ON");
        // Show Moisture Heat Map
        
    } else {
        NSLog(@"OFF");
    }
}

#pragma mark - Initialization

- (NSMutableArray *)dataPoints{
    if (!_dataPoints) {
        _dataPoints = [[NSMutableArray alloc]init];
    }
    return _dataPoints;
}

@end
