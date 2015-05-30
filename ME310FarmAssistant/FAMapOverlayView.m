//
//  FAMapOverlayView.m
//  ME310FarmAssistant
//
//  Created by Nathan on 5/4/15.
//  Copyright (c) 2015 Tom Hu. All rights reserved.
//

#import "FAMapOverlayView.h"

@implementation FAMapOverlayView

- (void)drawMapRect:(MKMapRect)mapRect zoomScale:(MKZoomScale)zoomScale inContext:(CGContextRef)context{
    CGImageRef imageReference = self.heatMapImage.CGImage;
    
    //Loading and setting the image
    MKMapRect theMapRect    = [self.overlay boundingMapRect];
    CGRect theRect2         = [self rectForMapRect:theMapRect];
    
    MKMapPoint topRightPoint = MKMapPointForCoordinate(_topRightCoordinate);
    MKMapPoint bottomLeftPoint = MKMapPointForCoordinate(_bottomLeftCoordinate);
    double width = ABS(topRightPoint.x - bottomLeftPoint.x);
    double height = ABS(topRightPoint.y - bottomLeftPoint.y);
    MKMapRect heatMapRect = MKMapRectMake(bottomLeftPoint.x,
                                          topRightPoint.y,
                                          width,
                                          height);
    
    CGRect theRect = [self rectForMapRect:heatMapRect];
    theRect.origin.y = (height - theRect2.size.height) / 2;
    
    // We need to flip and reposition the image here
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextTranslateCTM(context, 0.0, -theRect.size.height);
    
    //drawing the image to the context
    CGContextDrawImage(context, theRect, imageReference);
}

- (MKCoordinateRegion)regionForCoordinate1:(CLLocationCoordinate2D)coordinate1 coordinate2:(CLLocationCoordinate2D)coordinate2 {
    double minLat = MIN(coordinate1.latitude, coordinate2.latitude), maxLat = MAX(coordinate1.latitude, coordinate2.latitude);
    double minLon = MIN(coordinate1.longitude, coordinate2.longitude), maxLon = MAX(coordinate1.longitude, coordinate2.longitude);
    
    CLLocationCoordinate2D center = CLLocationCoordinate2DMake((minLat+maxLat)/2.0, (minLon+maxLon)/2.0);
    MKCoordinateSpan span = MKCoordinateSpanMake(maxLat-minLat, maxLon-minLon);
    MKCoordinateRegion region = MKCoordinateRegionMake (center, span);
    
    return region;
}

- (MKMapRect)MKMapRectForCoordinateRegion:(MKCoordinateRegion)region {
    MKMapPoint a = MKMapPointForCoordinate(CLLocationCoordinate2DMake(
                                                                      region.center.latitude + region.span.latitudeDelta / 2,
                                                                      region.center.longitude - region.span.longitudeDelta / 2));
    MKMapPoint b = MKMapPointForCoordinate(CLLocationCoordinate2DMake(
                                                                      region.center.latitude - region.span.latitudeDelta / 2,
                                                                      region.center.longitude + region.span.longitudeDelta / 2));
    return MKMapRectMake(MIN(a.x,b.x), MIN(a.y,b.y), ABS(a.x-b.x), ABS(a.y-b.y));
}

@end
