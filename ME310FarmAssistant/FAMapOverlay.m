//
//  FAMapOverlay.m
//  ME310FarmAssistant
//
//  Created by Nathan on 5/4/15.
//  Copyright (c) 2015 Tom Hu. All rights reserved.
//

#import "FAMapOverlay.h"

@implementation FAMapOverlay

- (id)initWithView:(MKMapView *)mapView{
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

- (MKMapRect)boundingMapRect
{
    return _mapRect;
}


@end
