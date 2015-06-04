//
//  DataPointAnnotation.m
//  ME310FarmAssistant
//
//  Created by Tom Hu on 5/3/15.
//  Copyright (c) 2015 Tom Hu. All rights reserved.
//

#import "DataPointAnnotation.h"
#import "DataPoint.h"

@interface DataPointAnnotation ()

@property (nonatomic, strong) DataPoint *dataPoint;

@end

@implementation DataPointAnnotation

- (instancetype)initWithDataPoint:(DataPoint *)dataPoint {
    self = [super init];
    if (self) {
        _dataPoint = dataPoint;
        
        _pointID = dataPoint.pointID;
        _coordinate = dataPoint.coordinate;
        _title = [NSString stringWithFormat:@"Point #%tu", dataPoint.pointID];
        _subtitle = [NSString stringWithFormat:@"Moisture: %zd  Transpiration: %zd", [dataPoint.moisture integerValue], [dataPoint.transpiration integerValue]];
    }
    return self;
}

- (BOOL)isNormal {
    return [self.dataPoint isNormal];
}

@end
