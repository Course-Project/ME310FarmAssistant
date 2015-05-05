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
#import <HSDatePickerViewController/HSDatePickerViewController.h>

static NSString *const kLatitude = @"latitude";
static NSString *const kLongitude = @"longitude";
static NSString *const kMagnitude = @"magnitude";

@interface MapViewController () <CLLocationManagerDelegate, HSDatePickerViewControllerDelegate>

@property (nonatomic, strong) NSMutableArray *locations;
@property (nonatomic, strong) NSMutableArray *weights;
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
    
    // Configure Heat Map
    [self configureHeatMap];
    
    // Add Annotations
    [self addAnnotations];
    
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
    // get data
    NSString *dataFile = [[NSBundle mainBundle] pathForResource:@"quake" ofType:@"plist"];
    NSArray *quakeData = [[NSArray alloc] initWithContentsOfFile:dataFile];
    
    self.locations = [[NSMutableArray alloc] initWithCapacity:[quakeData count]];
    self.weights = [[NSMutableArray alloc] initWithCapacity:[quakeData count]];
    for (NSDictionary *reading in quakeData) {
        CLLocationDegrees latitude = [[reading objectForKey:kLatitude] doubleValue];
        CLLocationDegrees longitude = [[reading objectForKey:kLongitude] doubleValue];
        double magnitude = [[reading objectForKey:kMagnitude] doubleValue];
        
        CLLocation *location = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
        [self.locations addObject:location];
        
        [self.weights addObject:[NSNumber numberWithInteger:(magnitude * 10)]];
    }
    
    // set map region
    MKCoordinateSpan span = MKCoordinateSpanMake(10.0, 13.0);
    CLLocationCoordinate2D center = CLLocationCoordinate2DMake(39.0, -77.0);
    self.mapView.region = MKCoordinateRegionMake(center, span);
    
    // create overlay view for the heatmap image
    self.imageView = [[UIImageView alloc] initWithFrame:self.view.frame];
    self.imageView.contentMode = UIViewContentModeCenter;
    [self.view addSubview:self.imageView];
    
    float boost = 0.4f;
    UIImage *heatmap = [LFHeatMap heatMapForMapView:self.mapView boost:boost locations:self.locations weights:self.weights];
    self.imageView.image = heatmap;
}

- (void)addAnnotations {
//    AssistantClient *client = [AssistantClient sharedClient];
//    WEAKSELF_T weakSelf = self;
//    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
//    [client getDataPointsWithSuccessBlock:^(NSArray *points) {
//        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
//        NSMutableArray *annotations = [NSMutableArray new];
//        for (id obj in points) {
//            NSUInteger pointID = [[obj valueForKey:@"id"] unsignedIntegerValue];
//            CLLocationDegrees latitude = [[obj valueForKey:@"latitude"] doubleValue];
//            CLLocationDegrees longtitude = [[obj valueForKey:@"longtitude"] doubleValue];
//            
//            DataPointAnnotation *annotation = [[DataPointAnnotation alloc] initWithID:pointID
//                                                                             Location:CLLocationCoordinate2DMake(latitude, longtitude)];
//            [annotations addObject:annotation];
//        }
//        [weakSelf.mapView showAnnotations:annotations animated:YES];
//    }];
    
    // Testing
    NSMutableArray *annotations = [NSMutableArray new];
    for (CLLocation *location in self.locations) {
        DataPointAnnotation *annotation = [[DataPointAnnotation alloc] initWithID:1 Location:location.coordinate];
        [annotations addObject:annotation];
    }
    [self.mapView addAnnotations:annotations];
    NSLog(@"Add annotations...");
}

#pragma mark - MKMapViewDelegate
- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated {
    NSLog(@"Region will change");
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    NSLog(@"Region did change");
    float boost = 0.4f;
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

@end
