//
//  MapViewController.m
//  ME310FarmAssistant
//
//  Created by Tom Hu on 4/26/15.
//  Copyright (c) 2015 Tom Hu. All rights reserved.
//

#import "MapViewController.h"
#import "DataPointAnnotation.h"
#import "DetailTableViewController.h"
#import "DataPoint.h"
#import "FAMapOverlay.h"
#import "FAMapOverlayView.h"
#import <REFrostedViewController/REFrostedViewController.h>
#import <MZFormSheetController/MZFormSheetController.h>

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

@interface MapViewController () <CLLocationManagerDelegate, UITextFieldDelegate>

@property (nonatomic, assign) BOOL isHistory;
@property (nonatomic, assign) double moistureThreshold;
@property (nonatomic, assign) double transpirationThreshold;

// Point Location for Annotations
@property (nonatomic, strong) NSMutableArray *locations;

// Moisture & Transpiration & Mixed Heat Map Overlay
@property (nonatomic, strong) FAMapOverlay *moistureHeatMapOverlay;
@property (nonatomic, strong) FAMapOverlay *transpirationHeatMapOverlay;
@property (nonatomic, strong) FAMapOverlay *mixedHeatMapOverlay;

// Moisture & Transpiration & Mixed Heat Map Image
@property (nonatomic, strong) UIImage *moistureHeatMapImage;
@property (nonatomic, strong) UIImage *transpirationHeatMapImage;
@property (nonatomic, strong) UIImage *mixedHeatMapImage;

// Moisture & Transpiration & Mixed Heat Map Bit Image Data
@property (nonatomic, strong) NSArray *moistureHeatMapBitArray;
@property (nonatomic, strong) NSArray *transpirationHeatMapBitArray;
@property (nonatomic, strong) NSArray *mixedHeatMapBitArray;

@property (nonatomic, assign) BOOL isConfiguringMoistureHeatMap;
@property (nonatomic, assign) BOOL isConfiguringTranspirationHeatMap;
@property (nonatomic, assign) BOOL isConfiguringMixedHeatMap;

// Heat Map Coordinate
@property (nonatomic) CLLocationCoordinate2D topRightCoordinate;
@property (nonatomic) CLLocationCoordinate2D bottomLeftCoordinate;

// Moisture & Transpiration & Mixed Heat Map Extreme Value
@property (nonatomic, assign) double maxMoistureValue;
@property (nonatomic, assign) double minMoistureValue;
@property (nonatomic, assign) double maxTranspirationValue;
@property (nonatomic, assign) double minTranspirationValue;
@property (nonatomic, assign) double maxMixedValue;
@property (nonatomic, assign) double minMixedValue;

// Data Points
@property (nonatomic, strong) NSMutableArray *dataPoints;

// Annotations Array
@property (nonatomic, strong) NSMutableArray *dataPointAnnotationsArray;

// Location Manager
@property (nonatomic, strong) CLLocationManager *locationManager;

// Wigets - UI
@property (nonatomic, weak) IBOutlet UISwitch *moistureSwitch;
@property (nonatomic, weak) IBOutlet UISwitch *transpirationSwitch;
@property (nonatomic, weak) IBOutlet UIView *switchView;
@property (nonatomic, strong) UIView *switchOverlayView;
@property (nonatomic, strong) UIActivityIndicatorView *heatMapSwitchIndicatorView;

@property (nonatomic, assign) TimeRange currentTimeRange;

@end

@implementation MapViewController

#pragma mark Life Circle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.isHistory = NO;
    self.moistureThreshold = 0.2f;
    self.transpirationThreshold = 0.2f;
    
    // Configure Location Manager
    [self configureLocationManager];
    
    // Configure Map
    [self configureMap];
    
    // Configure Switch Overlay View
    [self configureSwitchOverlayView];
    
    // Configure Data
    WEAKSELF_T weakSelf = self;
    [self configureDataPointWithCompletion:^{
        // Add Annotations
        [weakSelf configureAnnotations];
    }];
    
    // Configure Heat Map
    [self configureMoistureHeatMap];
    [self configureTranspirationHeatMap];
    [self configureMixedHeatMap];
    
    // Add Observers
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveShowCalloutNotification:)
                                                 name:@"ShowAnnotationCalloutView"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveMoistureSliderNotification:)
                                                 name:@"SoilMoisureSliderValue"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveTranspirationSliderNotification:)
                                                 name:@"TranspirationSliderValue"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveDatePickerNotification:)
                                                 name:@"HistoryDateSelected"
                                               object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - UI Methods
- (void)configureMap {
    // Show user location
    self.mapView.showsUserLocation = YES;
    
    [self.mapView setCenterCoordinate:self.mapView.userLocation.coordinate animated:YES];
}

- (void)configureSwitchOverlayView {
    self.switchOverlayView = [[UIView alloc] initWithFrame:self.switchView.bounds];
    
    self.heatMapSwitchIndicatorView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 15, 15)];
    self.heatMapSwitchIndicatorView.center = self.switchOverlayView.center;
    
    [self.switchOverlayView addSubview:self.heatMapSwitchIndicatorView];
    
    [self.switchView addSubview:self.switchOverlayView];
    
    [self.heatMapSwitchIndicatorView startAnimating];
    
    [self.switchView setUserInteractionEnabled:NO];
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

- (void)configureMoistureHeatMap {
    NSLog(@"Configuring moisture heat map...");
    [self.moistureSwitch setEnabled:NO];
    WEAKSELF_T weakSelf = self;
    [[AssistantClient sharedClient] getHeatMapWithType:FAHeatMapTypeMoisture callback:^(NSDictionary *res, NSError *err) {
        // TODO: Error Handle
        
        // Get Moisture Bit Info
        weakSelf.moistureHeatMapBitArray = res[@"all-image"];
        
        // Get Top-right Point
        weakSelf.topRightCoordinate = CLLocationCoordinate2DMake([res[@"max-x"] doubleValue], [res[@"max-y"] doubleValue]);
        
        // Get Bottom-left Point
        weakSelf.bottomLeftCoordinate = CLLocationCoordinate2DMake([res[@"min-x"] doubleValue], [res[@"min-y"] doubleValue]);
        
        // Get Extreme Value
        weakSelf.maxMoistureValue = [res[@"max-z"] doubleValue];
        weakSelf.minMoistureValue = [res[@"min-z"] doubleValue];
        
        [weakSelf generateMoistureHeatMapWithCompletion:^ {
            [weakSelf.moistureSwitch setEnabled:YES];
            NSLog(@"Moisture heat map finished!");
            
            if (!(weakSelf.isConfiguringMoistureHeatMap || weakSelf.isConfiguringTranspirationHeatMap || weakSelf.isConfiguringMixedHeatMap)) {
                [weakSelf removeSwitchOverlayView];
            }
        }];
    }];
    
//    CLLocationCoordinate2D heatMapCenter = CLLocationCoordinate2DMake((_topRightCoordinate.latitude + _bottomLeftCoordinate.latitude) / 2, (_topRightCoordinate.longitude + _bottomLeftCoordinate.longitude) / 2);
//    weakSelf.moistureHeatMapOverlay = [[FAMapOverlay alloc] initWithView:self.mapView centerCoordinate:heatMapCenter];
//    weakSelf.transpirationHeatMapOverlay = [[FAMapOverlay alloc] initWithView:self.mapView centerCoordinate:heatMapCenter];
}

- (void)configureTranspirationHeatMap {
    NSLog(@"Configuring transpiration heat map...");
    [self.transpirationSwitch setEnabled:NO];
    WEAKSELF_T weakSelf = self;
    [[AssistantClient sharedClient] getHeatMapWithType:FAHeatMapTypeTranspiration callback:^(NSDictionary *res, NSError *err) {
        // TODO: Error Handle
        
        // Get Transpiration Bit Info
        weakSelf.transpirationHeatMapBitArray = res[@"all-image"];
        
        // Get Top-right Point
        weakSelf.topRightCoordinate = CLLocationCoordinate2DMake([res[@"max-x"] doubleValue], [res[@"max-y"] doubleValue]);
        
        // Get Bottom-left Point
        weakSelf.bottomLeftCoordinate = CLLocationCoordinate2DMake([res[@"min-x"] doubleValue], [res[@"min-y"] doubleValue]);
        
        // Get Extreme Value
        weakSelf.maxTranspirationValue = [res[@"max-z"] doubleValue];
        weakSelf.minTranspirationValue = [res[@"min-z"] doubleValue];
        
        [weakSelf generateTranspirationHeatMapWithCompletion:^ {
            [weakSelf.transpirationSwitch setEnabled:YES];
            NSLog(@"Transpiration heat map finished!");
            
            if (!(weakSelf.isConfiguringMoistureHeatMap || weakSelf.isConfiguringTranspirationHeatMap || weakSelf.isConfiguringMixedHeatMap)) {
                [weakSelf removeSwitchOverlayView];
            }
        }];
    }];
}

- (void)configureMixedHeatMap {
    NSLog(@"Configuring mixed heat map...");
    WEAKSELF_T weakSelf = self;
    [[AssistantClient sharedClient] getHeatMapWithType:FAHeatMapTypeMixed callback:^(NSDictionary *res, NSError *err) {
        // TODO: Error Handle
        
        // Get Transpiration Bit Info
        weakSelf.mixedHeatMapBitArray = res[@"all-image"];
        
        // Get Top-right Point
        weakSelf.topRightCoordinate = CLLocationCoordinate2DMake([res[@"max-x"] doubleValue], [res[@"max-y"] doubleValue]);
        
        // Get Bottom-left Point
        weakSelf.bottomLeftCoordinate = CLLocationCoordinate2DMake([res[@"min-x"] doubleValue], [res[@"min-y"] doubleValue]);
        
        // Get Extreme Value
        weakSelf.maxMixedValue = [res[@"max-z"] doubleValue];
        weakSelf.minMixedValue = [res[@"min-z"] doubleValue];
        
        [weakSelf generateMixedHeatMapWithCompletion:^ {
            NSLog(@"Mixed heat map finished!");
            if (!(weakSelf.isConfiguringMoistureHeatMap || weakSelf.isConfiguringTranspirationHeatMap || weakSelf.isConfiguringMixedHeatMap)) {
                [weakSelf removeSwitchOverlayView];
            }
        }];
    }];
}

- (void)generateMoistureHeatMapWithCompletion:(dispatch_block_t)success {
    NSLog(@"Generating moisture heat map...");
    self.isConfiguringMoistureHeatMap = YES;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"WillGenerateMoistureHeatMap" object:nil];
    
    NSArray *colors = @[
                        (__bridge id) UIColorFromRGB(0xFE1016).CGColor,
                        (__bridge id) UIColorFromRGB(0xFF7F10).CGColor,
                        (__bridge id) UIColorFromRGB(0xFFB610).CGColor,
                        (__bridge id) UIColorFromRGB(0xFFE010).CGColor,
                        (__bridge id) UIColorFromRGB(0xE8FC10).CGColor,
                        (__bridge id) UIColorFromRGB(0x6BED0F).CGColor,
                        (__bridge id) UIColorFromRGB(0x0DCB96).CGColor,
                        (__bridge id) UIColorFromRGB(0x1D69CB).CGColor
                        ];
    
    WEAKSELF_T weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^ {
        double threshold = weakSelf.moistureThreshold;
        double step = (1 - threshold) / 7.0f;
        
        CGFloat locations[] = {0.0f, threshold, threshold + step, threshold + step * 2, threshold + step * 3, threshold + step * 4, threshold + step * 5, threshold + step * 6};
        UIImage *image = [weakSelf generateHeatMapImageWithBitInfoArray:weakSelf.moistureHeatMapBitArray
                                                     withGradientColors:colors locations:locations
                                                           withMaxValue:weakSelf.maxMoistureValue minValue:weakSelf.minMoistureValue];
        weakSelf.moistureHeatMapImage = image;
        weakSelf.isConfiguringMoistureHeatMap = NO;
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"DidGenerateMoistureHeatMap" object:nil];
        
        dispatch_async(dispatch_get_main_queue(), success);
    });
}

- (void)generateTranspirationHeatMapWithCompletion:(dispatch_block_t)success {
    NSLog(@"Generating transpiration heat map...");
    self.isConfiguringTranspirationHeatMap = YES;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"WillGenerateTranspirationHeatMap" object:nil];
    
    NSArray *colors = @[
                        (__bridge id) UIColorFromRGB(0xFFB45F).CGColor,
                        (__bridge id) UIColorFromRGB(0x9BD27B).CGColor
                        ];
    
    WEAKSELF_T weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^ {
        CGFloat locations[] = {0.0f, weakSelf.transpirationThreshold};
        UIImage *image = [weakSelf generateHeatMapImageWithBitInfoArray:weakSelf.transpirationHeatMapBitArray
                                                     withGradientColors:colors locations:locations
                                                           withMaxValue:weakSelf.maxTranspirationValue minValue:weakSelf.minTranspirationValue];
        weakSelf.transpirationHeatMapImage = image;
        self.isConfiguringTranspirationHeatMap = NO;
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"DidGenerateTranspirationHeatMap" object:nil];
        
        dispatch_async(dispatch_get_main_queue(), success);
    });
}

- (void)generateMixedHeatMapWithCompletion:(dispatch_block_t)success {
    NSLog(@"Generating mixed heat map...");
    self.isConfiguringMixedHeatMap = YES;
    NSArray *colors = @[
                        (__bridge id) UIColorFromRGB(0xFFB45F).CGColor,
                        (__bridge id) UIColorFromRGB(0x9BD27B).CGColor
                        ];
    
    WEAKSELF_T weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^ {
        CGFloat locations[] = {0.0f, 0.3f};
        UIImage *image = [weakSelf generateHeatMapImageWithBitInfoArray:weakSelf.mixedHeatMapBitArray
                                                     withGradientColors:colors locations:locations
                                                           withMaxValue:weakSelf.maxMixedValue minValue:weakSelf.minMixedValue];
        weakSelf.mixedHeatMapImage = image;
        self.isConfiguringMixedHeatMap = NO;
        dispatch_async(dispatch_get_main_queue(), success);
    });
}

- (void)configureAnnotations {
    NSLog(@"Add annotations...");
    [self.dataPointAnnotationsArray removeAllObjects];
    for (DataPoint *point in self.dataPoints) {
        DataPointAnnotation *annotation = [[DataPointAnnotation alloc] initWithDataPoint:point];
        [self.dataPointAnnotationsArray addObject:annotation];
    }
    [self.mapView addAnnotations:self.dataPointAnnotationsArray];
    
    [self.mapView setRegion:[self regionForAnnotations:_dataPointAnnotationsArray]];
    self.moistureHeatMapOverlay = [[FAMapOverlay alloc] initWithView:_mapView];
    self.transpirationHeatMapOverlay = [[FAMapOverlay alloc] initWithView:_mapView];
    self.mixedHeatMapOverlay = [[FAMapOverlay alloc] initWithView:_mapView];
}

- (void)removeAnnotations {
    NSLog(@"Remove annotations...");
    [self.mapView removeAnnotations:self.dataPointAnnotationsArray];
}

- (void)removeHeatMapOverlays {
    NSLog(@"Remove Overlays...");
    [self.mapView removeOverlay:self.moistureHeatMapOverlay];
    [self.mapView removeOverlay:self.transpirationHeatMapOverlay];
    [self.mapView removeOverlay:self.mixedHeatMapOverlay];
}

- (void)removeSwitchOverlayView {
    NSLog(@"Remove Switch Overlay...");
    [self.heatMapSwitchIndicatorView stopAnimating];
    [self.switchOverlayView removeFromSuperview];
    [self.switchView setUserInteractionEnabled:YES];
}

- (void)configureDataPointWithCompletion:(void (^)(void))completed {
    AssistantClient *client = [AssistantClient sharedClient];
    WEAKSELF_T weakSelf = self;
    [SVProgressHUD showWithStatus:@"Loading..."];
    [client getDataPointsWithCallback:^(NSDictionary *res, NSError *err) {
        // Error Handle
        if (err) {
            [SVProgressHUD showErrorWithStatus:@"Network Error!"];
            return;
        }
        
        // Get Data Points
        NSArray *points = res[@"data"];
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

- (void)updateOverlays {
    [self.mapView removeOverlays:self.mapView.overlays];
    
    if ([_moistureSwitch isOn] && [_transpirationSwitch isOn]) {
        [self.mapView addOverlay:self.mixedHeatMapOverlay];
    } else if (![_moistureSwitch isOn] && [_transpirationSwitch isOn]) {
        [self.mapView addOverlay:self.transpirationHeatMapOverlay];
    } else if ([_moistureSwitch isOn] && ![_transpirationSwitch isOn]) {
        [self.mapView addOverlay:self.moistureHeatMapOverlay];
    }
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

// MARK: Copy from website
- (MKCoordinateRegion)regionForAnnotations:(NSArray*) annotations {
    double minLat=90.0f, maxLat=-90.0f;
    double minLon=180.0f, maxLon=-180.0f;
    
    for (id<MKAnnotation> mka in annotations) {
        if ( mka.coordinate.latitude  < minLat ) minLat = mka.coordinate.latitude;
        if ( mka.coordinate.latitude  > maxLat ) maxLat = mka.coordinate.latitude;
        if ( mka.coordinate.longitude < minLon ) minLon = mka.coordinate.longitude;
        if ( mka.coordinate.longitude > maxLon ) maxLon = mka.coordinate.longitude;
    }
    
    CLLocationCoordinate2D center = CLLocationCoordinate2DMake((minLat+maxLat)/2.0, (minLon+maxLon)/2.0);
    MKCoordinateSpan span = MKCoordinateSpanMake(maxLat-minLat, maxLon-minLon);
    MKCoordinateRegion region = MKCoordinateRegionMake (center, span);
    
    return region;
}

#pragma mark - MKMapViewDelegate
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    NSLog(@"Annotation View");
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

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    MKCoordinateSpan currentSpan = mapView.region.span;
    MKCoordinateSpan span = MKCoordinateSpanMake(MAX(currentSpan.latitudeDelta, MINIMUM_ZOOM_ARC), MAX(currentSpan.longitudeDelta, MINIMUM_ZOOM_ARC));
    [mapView setRegion:MKCoordinateRegionMake([view.annotation coordinate], span) animated:YES];
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    NSLog(@"Callout accessory control tapped");
    DetailTableViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"DetailViewController"];
    vc.pointID = [(DataPointAnnotation *)view.annotation pointID];
    
    MZFormSheetController *formSheet = [[MZFormSheetController alloc] initWithViewController:vc];
    
    formSheet.shouldDismissOnBackgroundViewTap = YES;
    formSheet.transitionStyle = MZFormSheetTransitionStyleSlideFromBottom;
    formSheet.cornerRadius = 8.0;
    formSheet.portraitTopInset = 6.0;
    formSheet.landscapeTopInset = 6.0;
    formSheet.shouldCenterVertically = YES;
    formSheet.presentedFormSheetSize = CGSizeMake(640, 600);
    
    formSheet.didTapOnBackgroundViewCompletionHandler = ^(CGPoint location) {
        NSLog(@"Did tap on %@", NSStringFromCGPoint(location));
    };
    
    formSheet.willPresentCompletionHandler = ^(UIViewController *presentedFSViewController) {
        NSLog(@"Presented View Controller Frame: %@", NSStringFromCGRect(presentedFSViewController.view.frame));
        NSLog(@"Presented View Controller Class: %@", NSStringFromClass(presentedFSViewController.class));
    };
    
    [self mz_presentFormSheetController:formSheet animated:YES completionHandler:^(MZFormSheetController *formSheetController) {
        NSLog(@"Presented!");
    }];
}

// Overlay Delegate
- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id<MKOverlay>)overlay {
    NSLog(@"Overlay View");
    FAMapOverlay *mapOverlay = (FAMapOverlay *)overlay;
    FAMapOverlayView *mapOverlayView = [[FAMapOverlayView alloc] initWithOverlay:mapOverlay];
    
    if ([overlay isEqual:self.moistureHeatMapOverlay]) {
        mapOverlayView.heatMapImage = self.moistureHeatMapImage;
    } else if ([overlay isEqual:self.transpirationHeatMapOverlay]) {
        mapOverlayView.heatMapImage = self.transpirationHeatMapImage;
    } else if ([overlay isEqual:self.mixedHeatMapOverlay]) {
        mapOverlayView.heatMapImage = self.mixedHeatMapImage;
    }
    
    mapOverlayView.topRightCoordinate = _topRightCoordinate;
    mapOverlayView.bottomLeftCoordinate = _bottomLeftCoordinate;
    
    return mapOverlayView;
}

#pragma mark - CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    NSLog(@"Did update location");
}

#pragma mark - Actions
- (IBAction)didChangeMoistureSwitch:(UISwitch *)sender {
    NSLog(@"Moisture Switch changed");
    [self updateOverlays];
}

- (IBAction)didChangeTranspirationSwitch:(UISwitch *)sender {
    NSLog(@"Transpiration Switch changed");
    [self updateOverlays];
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
- (UIImage *)imageByCroppingImage:(UIImage *)image toSize:(CGSize)size {
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

- (UIImage *)generateHeatMapImageWithBitInfoArray:(NSArray *)bitInfo
                               withGradientColors:(NSArray *)colors locations:(const CGFloat[])locations
                                     withMaxValue:(double)max minValue:(double)min {
    int width = [[bitInfo firstObject] count], height = [bitInfo count];
    unsigned char *rgba = (unsigned char *)calloc(width * height * 4, sizeof(unsigned char));
    
    clock_t start = clock();
    
    // Convert
    NSArray *colorRGBA;
    int i = 0;
    UInt32 indexOrigin;
    for (int x = width - 1; x >= 0; x--) {
        for (int y = 0; y < height; y++, i++) {
            NSNumber *number = [[bitInfo objectAtIndex:y] objectAtIndex:x];
            if ([number isKindOfClass:[NSNull class]]) continue;
            double val = [number doubleValue];
            
            indexOrigin = 4 * i;
            
            val = (val - min) / (max - min);
            colorRGBA = [self calculateColorInGradientColors:colors locations:locations atPosition:val];
            
            rgba[indexOrigin + 0] = [[colorRGBA objectAtIndex:0] unsignedCharValue]; // r
            rgba[indexOrigin + 1] = [[colorRGBA objectAtIndex:1] unsignedCharValue]; // g
            rgba[indexOrigin + 2] = [[colorRGBA objectAtIndex:2] unsignedCharValue]; // b
            rgba[indexOrigin + 3] = [[colorRGBA objectAtIndex:3] unsignedCharValue]; // a
        }
    }
    
    clock_t endLoop = clock();
    
    NSLog(@"Loop Time: %lu", endLoop - start);
    
    // Create image from rendered raw data
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef bitmapContext = CGBitmapContextCreate(rgba,
                                                       width,
                                                       height,
                                                       8, // bitsPerComponent
                                                       4 * width, // bytesPerRow
                                                       colorSpace,
                                                       kCGImageAlphaPremultipliedLast | kCGBitmapByteOrderDefault);
    
    CFRelease(colorSpace);
    
    CGImageRef cgImage = CGBitmapContextCreateImage(bitmapContext);
    
    UIImage *image = [UIImage imageWithCGImage:cgImage];
    
    CFRelease(cgImage);
    CFRelease(bitmapContext);
    
    free(rgba);
    
    return image;
}

- (NSArray *)calculateColorInGradientColors:(NSArray *)colors locations:(const CGFloat[])locations atPosition:(double)position {
    position = position < 0 ? 0 : position;
    position = position > 1 ? 1 : position;
    
    CGFloat tmpImagewidth = 1000.0f; // Make this bigger or smaller if you need more or less resolution (number of different colors).
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();

    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef) colors, locations);
    CGPoint startPoint = CGPointMake(0, 0);
    CGPoint endPoint = CGPointMake(tmpImagewidth, 0);
    
    // create a bitmap context to draw the gradient to, 1 pixel high.
    CGContextRef context = CGBitmapContextCreate(NULL, tmpImagewidth, 1, 8, 0, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrderDefault);
    
    // draw the gradient into it
    CGContextAddRect(context, CGRectMake(0, 0, tmpImagewidth, 1));
    CGContextClip(context);
    CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
    
    // Get our RGB bytes into a buffer with a couple of intermediate steps...
    //      CGImageRef -> CFDataRef -> byte array
    CGImageRef cgImage = CGBitmapContextCreateImage(context);
    CGDataProviderRef provider = CGImageGetDataProvider(cgImage);
    CFDataRef pixelData = CGDataProviderCopyData(provider);
    
    // cleanup:
    CGGradientRelease(gradient);
    CGColorSpaceRelease(colorSpace);
    CGImageRelease(cgImage);
    CGContextRelease(context);
    
    const UInt8* data = CFDataGetBytePtr(pixelData);
    
    // we got all the data we need.
    // bytes in the data buffer are a succession of R G B A bytes
    
    // For instance, the color of the point 27% in our gradient is:
    CGFloat x = tmpImagewidth * position;
    int pixelIndex = (int)x * 4; // 4 bytes per color

    NSArray *colorRGBA = @[
                           [NSNumber numberWithUnsignedChar:data[pixelIndex + 0]],
                           [NSNumber numberWithUnsignedChar:data[pixelIndex + 1]],
                           [NSNumber numberWithUnsignedChar:data[pixelIndex + 2]],
                           [NSNumber numberWithUnsignedChar:data[pixelIndex + 3]]
                           ];
    
    // done fetching color data, finally release the buffer
    CGDataProviderRelease(provider);
    
    return colorRGBA;
}

#pragma mark - Observers
- (void)didReceiveShowCalloutNotification:(NSNotification *)notification {
    NSUInteger pointID = [notification.object unsignedIntegerValue];
    for (DataPointAnnotation *annotation in self.mapView.annotations) {
        if (pointID == annotation.pointID) {
            [self.mapView selectAnnotation:annotation animated:YES];
            
            // Re-center
            [self.mapView setCenterCoordinate:annotation.coordinate animated:YES];
            
            break;
        }
    }
}

- (void)didReceiveMoistureSliderNotification:(NSNotification *)notification {
    NSLog(@"Moisture Threshold Changed!");
    NSLog(@"Moisture Threshold: %@", notification.object);
    
    self.moistureThreshold = [notification.object doubleValue] / 100.0f;
    
    if ([self isConfiguringMoistureHeatMap]) return;
    
    if (![self.switchView.subviews containsObject:self.switchOverlayView]) {
        [self.switchView addSubview:self.switchOverlayView];
        [self.heatMapSwitchIndicatorView startAnimating];
        [self.switchView setUserInteractionEnabled:NO];
    }
    
    WEAKSELF_T weakSelf = self;
    [self generateMoistureHeatMapWithCompletion:^ {
        NSLog(@"Moisture heat map updated!");
        
        [weakSelf updateOverlays];
        
        if (!(weakSelf.isConfiguringMoistureHeatMap || weakSelf.isConfiguringTranspirationHeatMap || weakSelf.isConfiguringMixedHeatMap)) {
            [weakSelf removeSwitchOverlayView];
        }
    }];
}

- (void)didReceiveTranspirationSliderNotification:(NSNotification *)notification {
    NSLog(@"Transpiration Threshold Changed!");
    NSLog(@"Transpiration Threshold: %@", notification.object);
    
    self.transpirationThreshold = [notification.object doubleValue] / 100.0f;
    
    if ([self isConfiguringTranspirationHeatMap]) return;
    
    if (![self.switchView.subviews containsObject:self.switchOverlayView]) {
        [self.switchView addSubview:self.switchOverlayView];
        [self.heatMapSwitchIndicatorView startAnimating];
        [self.switchView setUserInteractionEnabled:NO];
    }
    
    WEAKSELF_T weakSelf = self;
    [self generateTranspirationHeatMapWithCompletion:^ {
        NSLog(@"Moisture heat map updated!");
        
        [weakSelf updateOverlays];
        
        if (!(weakSelf.isConfiguringMoistureHeatMap || weakSelf.isConfiguringTranspirationHeatMap || weakSelf.isConfiguringMixedHeatMap)) {
            [weakSelf removeSwitchOverlayView];
        }
    }];
}

- (void)didReceiveDatePickerNotification:(NSNotification *)notification {
    NSLog(@"Date Range Changed!");
    NSLog(@"Date Range: %@", notification.object);
    
    self.isHistory = YES;
    
//    if (![self.switchView.subviews containsObject:self.switchOverlayView]) {
//        [self.switchView addSubview:self.switchOverlayView];
//        [self.heatMapSwitchIndicatorView startAnimating];
//        [self.switchView setUserInteractionEnabled:NO];
//    }
}

@end
