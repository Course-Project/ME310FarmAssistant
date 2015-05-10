//
//  FAMapOverlay.h
//  ME310FarmAssistant
//
//  Created by Nathan on 5/4/15.
//  Copyright (c) 2015 Tom Hu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
@interface FAMapOverlay : NSObject<MKOverlay>

- (id)initWithView:(MKMapView *)mapView;
- (MKMapRect)boundingMapRect;

@property (nonatomic) MKMapRect mapRect;
@property (nonatomic) CLLocationCoordinate2D coordinate;
@property (nonatomic, strong) MKMapView *mapView;

@end
