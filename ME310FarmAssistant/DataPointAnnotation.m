//
//  DataPointAnnotation.m
//  ME310FarmAssistant
//
//  Created by Tom Hu on 5/3/15.
//  Copyright (c) 2015 Tom Hu. All rights reserved.
//

#import "DataPointAnnotation.h"
#import "DataPoint.h"

@implementation DataPointAnnotation

- (instancetype)initWithDataPoint:(DataPoint *)dataPoint {
    self = [super init];
    if (self) {
        _pointID = dataPoint.pointID;
        _coordinate = dataPoint.coordinate;
        _title = [NSString stringWithFormat:@"Point #%tu", dataPoint.pointID];
        _subtitle = [NSString stringWithFormat:@"Moisture: %@  Transpiration: %@", [dataPoint.moisture stringValue], [dataPoint.transpiration stringValue]];
        
        _isNormal = [dataPoint isNormal];
    }
    return self;
}

@end
