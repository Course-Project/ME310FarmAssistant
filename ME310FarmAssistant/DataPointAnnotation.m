//
//  DataPointAnnotation.m
//  ME310FarmAssistant
//
//  Created by Tom Hu on 5/3/15.
//  Copyright (c) 2015 Tom Hu. All rights reserved.
//

#import "DataPointAnnotation.h"

@implementation DataPointAnnotation

- (instancetype)initWithID:(NSUInteger)pointID Location:(CLLocationCoordinate2D)coord {
    self = [super init];
    if (self) {
        _pointID = pointID;
        _coordinate = coord;
        _title = @"Test";
        _subtitle = @"HEHEHE";
    }
    return self;
}

@end
