//
//  DataPoint.m
//  ME310FarmAssistant
//
//  Created by Tom Hu on 4/7/15.
//  Copyright (c) 2015 Tom Hu. All rights reserved.
//

#import "DataPoint.h"

@implementation DataPoint

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        _pointID = [dict[@"id"] unsignedIntegerValue];
        _moisture = dict[@"moisture"];
        _airTemperature = dict[@"air_temp"];
        _leafTemperature = dict[@"leaf_temp"];
        _humidity = dict[@"humidity"];
        _transpiration = dict[@"transpiration"];
        _photoURLPathString = dict[@"photo"];
        _time = [NSDate new]; // TODO
    }
    return self;
}

@end
