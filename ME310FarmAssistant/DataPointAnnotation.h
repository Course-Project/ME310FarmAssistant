//
//  DataPointAnnotation.h
//  ME310FarmAssistant
//
//  Created by Tom Hu on 5/3/15.
//  Copyright (c) 2015 Tom Hu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@class DataPoint;

@interface DataPointAnnotation : NSObject <MKAnnotation>

@property (nonatomic, readonly) NSUInteger pointID;

#pragma mark - MKAnnotation Property
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, readonly, copy) NSString *title;
@property (nonatomic, readonly, copy) NSString *subtitle;

#pragma mark - init
- (instancetype)initWithDataPoint:(DataPoint *)dataPoint;

@end
