//
//  MapViewController.m
//  ME310FarmAssistant
//
//  Created by Tom Hu on 4/26/15.
//  Copyright (c) 2015 Tom Hu. All rights reserved.
//

#import "MapViewController.h"
#import "LFHeatMap.h"
#import "DataPointAnnotation.h"
#import "DetailTableViewController.h"
#import "DataPoint.h"
#import "FAMapOverlay.h"
#import "FAMapOverlayView.h"
#import <HSDatePickerViewController/HSDatePickerViewController.h>
#import <REFrostedViewController/REFrostedViewController.h>

// MARK: Copy from website
#define MINIMUM_ZOOM_ARC 0.014 //approximately 1 miles (1 degree of arc ~= 69 miles)
#define ANNOTATION_REGION_PAD_FACTOR 1.15
#define MAX_DEGREES_ARC 360

#define HEAT_MAP_SIZE CGSizeMake(70, 70)

static NSString *const kLatitude = @"latitude";
static NSString *const kLongitude = @"longitude";
static NSString *const kMagnitude = @"magnitude";

typedef NS_ENUM(NSUInteger, TimeRange) {
    TimeRangeStart,
    TimeRangeEnd,
    TimeRangeNone,
};

@interface MapViewController () <CLLocationManagerDelegate, HSDatePickerViewControllerDelegate, UITextFieldDelegate>

// Point location for annotations
@property (nonatomic, strong) NSMutableArray *locations;

// Moisture Weights & Transpiration Weights
@property (nonatomic, strong) NSMutableArray *moistureWeights;
@property (nonatomic, strong) NSMutableArray *transpirationWeights;

// Moisture & Transpiration Heat Map Overlay
@property (nonatomic, strong) FAMapOverlay *moistureHeatMapOverlay;
@property (nonatomic, strong) FAMapOverlay *transpirationHeatMapOverlay;

// Moisture & Transpiration Heat Map Image
@property (nonatomic, strong) UIImage *moistureHeatMapImage;
@property (nonatomic, strong) UIImage *transpirationHeatMapImage;

// Moisture & Transpiration Heat Map Image Size Ratio
@property (nonatomic, assign) float moistureHeatMapWidthRatio;
@property (nonatomic, assign) float moistureHeatMapHeightRatio;
@property (nonatomic, assign) float transpirationHeatMapWidthRatio;
@property (nonatomic, assign) float transpirationHeatMapHeightRatio;



// Data Points
@property (nonatomic, strong) NSMutableArray *dataPoints;

// Annotations Array
@property (nonatomic, strong) NSMutableArray *dataPointAnnotationsArray;

@property (nonatomic, strong) CLLocationManager *locationManager;

// Wigets - UI
@property (nonatomic, weak) IBOutlet UISwitch *moistureSwitch;
@property (nonatomic, weak) IBOutlet UISwitch *transpirationSwitch;

@property (nonatomic, weak) IBOutlet UITextField *startTimeTextField;
@property (nonatomic, weak) IBOutlet UITextField *endTimeTextField;
@property (nonatomic, weak) IBOutlet UIButton *searchHistoryButton;

@property (nonatomic, assign) TimeRange currentTimeRange;

@end

@implementation MapViewController

#pragma mark Life Circle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.searchHistoryButton setEnabled:NO];
    
    // Configure Location Manager
    [self configureLocationManager];
    
    // Configure Map
    [self configureMap];
    
    // Configure Data
    WEAKSELF_T weakSelf = self;
    [self configureDataPointWithCompletion:^{
        // Configure Heat Map
        [weakSelf configureHeatMap];
        
        // Add Annotations
        [weakSelf configureAnnotations];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UI Methods
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
    
    // Crete location array & weight array (moisture & transipiration)
    weakSelf.locations = [NSMutableArray arrayWithCapacity:weakSelf.dataPoints.count];
    weakSelf.moistureWeights = [NSMutableArray arrayWithCapacity:weakSelf.dataPoints.count];
    weakSelf.transpirationWeights = [NSMutableArray arrayWithCapacity:weakSelf.dataPoints.count];
    
    for (DataPoint *point in weakSelf.dataPoints) {
         CLLocation *location = [[CLLocation alloc] initWithLatitude:point.coordinate.latitude longitude:point.coordinate.longitude];
        [weakSelf.locations addObject:location];
        [weakSelf.moistureWeights addObject:point.moisture];
        [weakSelf.transpirationWeights addObject:point.transpiration];
    }
    
    weakSelf.moistureHeatMapOverlay = [[FAMapOverlay alloc] initWithView:self.mapView];
    weakSelf.transpirationHeatMapOverlay = [[FAMapOverlay alloc] initWithView:self.mapView];
    
    [weakSelf generateMoistureHeatMap];
    [weakSelf generateTranspirationHeatMap];
}

- (void)generateMoistureHeatMap {
    NSLog(@"Generating moisture heat map...");
    float boost = 1.0f;
    UIImage *image = [LFHeatMap heatMapForMapView:self.mapView boost:boost locations:self.locations weights:self.moistureWeights];
    CGSize originSize = image.size;
    UIImage *newImage = [self imageByCroppingImage:image toSize:HEAT_MAP_SIZE];
    self.moistureHeatMapWidthRatio = (float)newImage.size.width/originSize.width;
    self.moistureHeatMapHeightRatio = (float)newImage.size.height/originSize.height;
    self.moistureHeatMapImage = newImage;
    
}

- (void)generateTranspirationHeatMap {
    NSLog(@"Generating transpiration heat map...");
    float boost = 1.0f;
    UIImage *image = [LFHeatMap heatMapForMapView:self.mapView boost:boost locations:self.locations weights:self.transpirationWeights];
    CGSize originSize = image.size;
    UIImage *newImage = [self imageByCroppingImage:image toSize:HEAT_MAP_SIZE];
    self.transpirationHeatMapWidthRatio = (float)newImage.size.width/originSize.width;
    self.transpirationHeatMapHeightRatio = (float)newImage.size.height/originSize.height;
    self.transpirationHeatMapImage = newImage;
}

- (void)configureAnnotations {
    NSLog(@"Add annotations...");
    [self.dataPointAnnotationsArray removeAllObjects];
    for (DataPoint *point in self.dataPoints) {
        DataPointAnnotation *annotation = [[DataPointAnnotation alloc] initWithDataPoint:point];
        [self.dataPointAnnotationsArray addObject:annotation];
    }
    [self.mapView addAnnotations:self.dataPointAnnotationsArray];
}

- (void)removeAnnotations {
    NSLog(@"Remove annotations...");
    [self.mapView removeAnnotations:self.dataPointAnnotationsArray];
}

- (void)removeHeatMapOverlays {
    NSLog(@"Remove Overlays...");
    [self.mapView removeOverlay:self.moistureHeatMapOverlay];
    [self.mapView removeOverlay:self.transpirationHeatMapOverlay];
}

- (void)configureTextFields {
    self.startTimeTextField.enabled = YES;
    self.endTimeTextField.enabled = NO;
}

- (void)configureDataPointWithCompletion:(void (^)(void))completed {
    AssistantClient *client = [AssistantClient sharedClient];
    WEAKSELF_T weakSelf = self;
    [SVProgressHUD showWithStatus:@"Loading..."];
    [client getDataPointsWithSuccessBlock:^(NSArray *points) {
        for (id obj in points) {
            DataPoint *point = [[DataPoint alloc] initWithDictionary:obj];
            [weakSelf.dataPoints addObject:point];
        }
        if (completed) {
            completed();
        }
        [SVProgressHUD showSuccessWithStatus:@"Success!"];
    }];
}

// MARK: Copy from website
//size the mapView region to fit its annotations
- (void)zoomMapViewToFitAnnotations:(MKMapView *)mapView animated:(BOOL)animated {
    NSArray *annotations = mapView.annotations;
    NSUInteger count = [mapView.annotations count];
    
    if (count == 0) return; //bail if no annotations
    
    //convert NSArray of id <MKAnnotation> into an MKCoordinateRegion that can be used to set the map size
    //can't use NSArray with MKMapPoint because MKMapPoint is not an id
    MKMapPoint points[count]; //C array of MKMapPoint struct
    
    //load points C array by converting coordinates to points
    for (int i = 0; i < count; i++) {
        CLLocationCoordinate2D coordinate = [(id <MKAnnotation>)[annotations objectAtIndex:i] coordinate];
        points[i] = MKMapPointForCoordinate(coordinate);
    }
    //create MKMapRect from array of MKMapPoint
    MKMapRect mapRect = [[MKPolygon polygonWithPoints:points count:count] boundingMapRect];
    //convert MKCoordinateRegion from MKMapRect
    MKCoordinateRegion region = MKCoordinateRegionForMapRect(mapRect);
    
    //add padding so pins aren't scrunched on the edges
    region.span.latitudeDelta  *= ANNOTATION_REGION_PAD_FACTOR;
    region.span.longitudeDelta *= ANNOTATION_REGION_PAD_FACTOR;
    //but padding can't be bigger than the world
    if(region.span.latitudeDelta > MAX_DEGREES_ARC) { region.span.latitudeDelta  = MAX_DEGREES_ARC; }
    if(region.span.longitudeDelta > MAX_DEGREES_ARC){ region.span.longitudeDelta = MAX_DEGREES_ARC; }
    
    //and don't zoom in stupid-close on small samples
    if(region.span.latitudeDelta  < MINIMUM_ZOOM_ARC) { region.span.latitudeDelta  = MINIMUM_ZOOM_ARC; }
    if(region.span.longitudeDelta < MINIMUM_ZOOM_ARC) { region.span.longitudeDelta = MINIMUM_ZOOM_ARC; }
    //and if there is a sample of 1 we want the max zoom-in instead of max zoom-out
    if(count == 1) {
        region.span.latitudeDelta = MINIMUM_ZOOM_ARC;
        region.span.longitudeDelta = MINIMUM_ZOOM_ARC;
    }
    [mapView setRegion:region animated:animated];
}

#pragma mark - MKMapViewDelegate
//- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated {
//    NSLog(@"Region will change");
//}
//
//- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
//    NSLog(@"Region did change");
//}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    static NSString *reuse = @"PIN_ANNOTATION";
    MKPinAnnotationView *annotationView = (MKPinAnnotationView *)[self.mapView dequeueReusableAnnotationViewWithIdentifier:reuse];
    if (!annotationView) {
        annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:reuse];
    }
    
    if ([annotation isKindOfClass:[MKUserLocation class]]) {
        annotationView.pinColor = MKPinAnnotationColorPurple;
    } else {
        DataPointAnnotation *dataPointAnnotation = (DataPointAnnotation *)annotation;
        if (!dataPointAnnotation.isNormal) {
            annotationView.pinColor = MKPinAnnotationColorRed;
        } else {
            annotationView.pinColor = MKPinAnnotationColorGreen;
        }
        
        annotationView.animatesDrop = YES;
        annotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    }
    
    annotationView.canShowCallout = YES;
    
    return annotationView;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    NSLog(@"Callout accessory control tapped");
    DetailTableViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"DetailViewController"];
    vc.pointID = [(DataPointAnnotation *)view.annotation pointID];
    [self.navigationController pushViewController:vc animated:YES];
}

// Overlay Delegate
- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id<MKOverlay>)overlay{
    FAMapOverlay *mapOverlay = (FAMapOverlay *)overlay;
    FAMapOverlayView *mapOverlayView = [[FAMapOverlayView alloc] initWithOverlay:mapOverlay];
    
    if ([overlay isEqual:self.moistureHeatMapOverlay]) {
        mapOverlayView.heatMapImage = self.moistureHeatMapImage;
        mapOverlayView.widthRatio = self.moistureHeatMapWidthRatio;
        mapOverlayView.heightRatio = self.moistureHeatMapHeightRatio;
    } else if ([overlay isEqual:self.transpirationHeatMapOverlay]) {
        mapOverlayView.heatMapImage = self.transpirationHeatMapImage;
        mapOverlayView.widthRatio = self.transpirationHeatMapWidthRatio;
        mapOverlayView.heightRatio = self.transpirationHeatMapHeightRatio;
    }
    
    return mapOverlayView;
}

#pragma mark - CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    NSLog(@"Did update location");
}

#pragma mark - HSDatePickerViewControllerDelegate
- (void)hsDatePickerPickedDate:(NSDate *)date {
    NSLog(@"Selected date: %@", date);
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm";
    
    // Display date
    switch (self.currentTimeRange) {
        case TimeRangeStart:
            self.startTimeTextField.text = [dateFormatter stringFromDate:date];
            
            self.endTimeTextField.enabled = YES;
            break;
        case TimeRangeEnd:
            self.endTimeTextField.text = [dateFormatter stringFromDate:date];
            
            [self.searchHistoryButton setEnabled:YES];
            break;
        case TimeRangeNone:
            
            break;
        default:
            break;
    }
}

- (void)hsDatePickerWillDismissWithQuitMethod:(HSDatePickerQuitMethod)method {
    NSLog(@"Date picker will dismiss");
}

- (void)hsDatePickerDidDismissWithQuitMethod:(HSDatePickerQuitMethod)method {
    NSLog(@"Date picker did dismiss");
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    HSDatePickerViewController *datePickerViewController = [HSDatePickerViewController new];
    datePickerViewController.delegate = self;
    
    if ([textField isEqual:self.startTimeTextField]) {
        self.currentTimeRange = TimeRangeStart;
    } else if ([textField isEqual:self.endTimeTextField]) {
        NSDateFormatter *dateFormatter = [NSDateFormatter new];
        dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
        datePickerViewController.minDate = [dateFormatter dateFromString:self.startTimeTextField.text];
        self.currentTimeRange = TimeRangeEnd;
    } else {
        self.currentTimeRange = TimeRangeNone;
    }
    
    datePickerViewController.maxDate = [NSDate date];
    [self presentViewController:datePickerViewController animated:YES completion:^{
        NSLog(@"Presented");
    }];
    
    return NO;
}

#pragma mark - Actions
- (IBAction)didChangeTranspirationSwitch:(UISwitch *)sender {
    NSLog(@"Transpiration Switch changed");
    if ([sender isOn]) {
        NSLog(@"ON");
//        self.moistureHeatMapOverlay = [[FAMapOverlay alloc] initWithView:self.mapView];
//        [self generateMoistureHeatMap];
        [self.mapView addOverlay:self.moistureHeatMapOverlay];
    } else {
        NSLog(@"OFF");
        [self.mapView removeOverlay:self.moistureHeatMapOverlay];
    }
}

- (IBAction)didChangeMoistureSwitch:(UISwitch *)sender {
    NSLog(@"Moisture Switch changed");
    if ([sender isOn]) {
        NSLog(@"ON");
//        self.transpirationHeatMapOverlay = [[FAMapOverlay alloc] initWithView:self.mapView];
//        [self generateTranspirationHeatMap];
        [self.mapView addOverlay:self.transpirationHeatMapOverlay];
    } else {
        NSLog(@"OFF");
        [self.mapView removeOverlay:self.transpirationHeatMapOverlay];
    }
}

- (IBAction)didClickSearchHistoryButton:(UIButton *)sender {
    // Remove old data points
    [self.dataPoints removeAllObjects];
    
    // Get start & end date
    NSString *startDate = [NSString stringWithFormat:@"%@:00", self.startTimeTextField.text];
    NSString *endDate = [NSString stringWithFormat:@"%@:59", self.endTimeTextField.text];
    
    AssistantClient *client = [AssistantClient sharedClient];
    WEAKSELF_T weakSelf = self;
    
    [SVProgressHUD showWithStatus:@"Loading..."];
    [client getHistoryFrom:startDate To:endDate success:^(NSArray *points) {
        // Remove Old Data Points
        [weakSelf.dataPoints removeAllObjects];
        
        for (id obj in points) {
            DataPoint *point = [[DataPoint alloc] initWithDictionary:obj];
            [weakSelf.dataPoints addObject:point];
        }
        
        // Remove Annotations
        [weakSelf removeAnnotations];
        
        // TODO: Disable Heat Map
        [weakSelf.moistureSwitch setOn:NO animated:YES];
        [weakSelf.transpirationSwitch setOn:NO animated:YES];
        
        // Configure Heat Map
        [weakSelf configureHeatMap];
        
        // Add Annotations
        [weakSelf configureAnnotations];
        
        [SVProgressHUD showSuccessWithStatus:@"Success!"];
    }];
}

- (IBAction)didClickMenuButton:(id)sender {
    // Dismiss keyboard (optional)
    //
    [self.view endEditing:YES];
    [self.frostedViewController.view endEditing:YES];
    
    // Present the view controller
    //
    [self.frostedViewController presentMenuViewController];
}

#pragma mark - Properties
- (NSMutableArray *)dataPoints {
    if (!_dataPoints) {
        _dataPoints = [NSMutableArray new];
    }
    return _dataPoints;
}

- (NSMutableArray *)dataPointAnnotationsArray {
    if (!_dataPointAnnotationsArray) {
        _dataPointAnnotationsArray = [NSMutableArray new];
    }
    return _dataPointAnnotationsArray;
}

#pragma mark - Utils

- (UIImage *)imageByCroppingImage:(UIImage *)image toSize:(CGSize)size
{
    // not equivalent to image.size (which depends on the imageOrientation)!
    double refWidth = CGImageGetWidth(image.CGImage);
    double refHeight = CGImageGetHeight(image.CGImage);
    
    double x = (refWidth - size.width) / 2.0;
    double y = (refHeight - size.height) / 2.0;
    
    CGRect cropRect = CGRectMake(x, y, size.height, size.width);
    CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], cropRect);
    
    UIImage *cropped = [UIImage imageWithCGImage:imageRef scale:0.0 orientation:UIImageOrientationUp];
    CGImageRelease(imageRef);
    
    return cropped;
}

@end
