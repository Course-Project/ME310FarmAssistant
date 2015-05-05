//
//  FAMapOverlay.m
//  ME310FarmAssistant
//
//  Created by Nathan on 5/4/15.
//  Copyright (c) 2015 Tom Hu. All rights reserved.
//

#import "FAMapOverlay.h"

@implementation FAMapOverlay

-(CLLocationCoordinate2D)coordinate {
    //Image center point
    //    return CLLocationCoordinate2DMake(48.85883, 2.2945);
    return CLLocationCoordinate2DMake(31.28539, 121.2077);
}

- (MKMapRect)boundingMapRect
{
    //Latitue and longitude for each corner point
    MKMapPoint upperLeft   = MKMapPointForCoordinate(CLLocationCoordinate2DMake(31.28542, 121.2065));
    MKMapPoint upperRight  = MKMapPointForCoordinate(CLLocationCoordinate2DMake(31.28542, 121.2089));
    MKMapPoint bottomLeft  = MKMapPointForCoordinate(CLLocationCoordinate2DMake(31.28539, 121.2065));
    
    //Building a map rect that represents the image projection on the map
    MKMapRect bounds = MKMapRectMake(upperLeft.x, upperLeft.y, fabs(upperLeft.x - upperRight.x), fabs(upperLeft.y - bottomLeft.y));
    
    return bounds;
}


@end
