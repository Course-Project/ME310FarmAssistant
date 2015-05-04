//
//  DataPoint.h
//  ME310FarmAssistant
//
//  Created by Tom Hu on 4/7/15.
//  Copyright (c) 2015 Tom Hu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface DataPoint : NSObject

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, readonly) NSUInteger pointID;
@property (nonatomic, strong, readonly) NSNumber *moisture;
@property (nonatomic, strong, readonly) NSNumber *airTemperature;
@property (nonatomic, strong, readonly) NSNumber *leafTemperature;
@property (nonatomic, strong, readonly) NSNumber *humidity;
@property (nonatomic, strong, readonly) NSNumber *transpiration;
@property (nonatomic, strong, readonly) NSString *photoURLPathString;
@property (nonatomic, strong, readonly) NSDate *time;

- (instancetype)initWithDictionary:(NSDictionary *)dict;

@end
