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

- (MKMapRect)boundingMapRect;
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;


@end
