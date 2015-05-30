//
//  FAMapOverlay.m
//  ME310FarmAssistant
//
//  Created by Nathan on 5/4/15.
//  Copyright (c) 2015 Tom Hu. All rights reserved.
//

#import "FAMapOverlay.h"

@implementation FAMapOverlay

- (instancetype)initWithView:(MKMapView *)mapView centerCoordinate:(CLLocationCoordinate2D)coordinate {
    if (self = [super init]) {
        _mapView = mapView;
        _mapRect = mapView.visibleMapRect;
        _coordinate = coordinate;
    }
    return self;
}

- (id)initWithView:(MKMapView *)mapView {
    if (self = [super init]) {
        _mapView = mapView;
        _coordinate = mapView.centerCoordinate;
        _mapRect = mapView.visibleMapRect;
    }
    return self;
}

-(CLLocationCoordinate2D)coordinate {
    return _coordinate;
}

- (MKMapRect)boundingMapRect {
    return _mapRect;
}

@end
