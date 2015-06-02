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
        _coordinate = CLLocationCoordinate2DMake([dict[@"latitude"] doubleValue], [dict[@"longtitude"]doubleValue]);
        _time = dict[@"time"];
    }
    return self;
}

- (BOOL)isNormal {
    double moisture = [_moisture doubleValue];
    double transpiration = [_transpiration doubleValue];
    double moistureDryThreshold = [[[NSUserDefaults standardUserDefaults] objectForKey:@"MoistureDryThreshold"] doubleValue];
    double moistureWetThreshold = [[[NSUserDefaults standardUserDefaults] objectForKey:@"MoistureWetThreshold"] doubleValue];
    double transpirationThreshold = [[[NSUserDefaults standardUserDefaults] objectForKey:@"TranspirationThreshold"] doubleValue];

    return ((moisture >= moistureDryThreshold && moisture <= moistureWetThreshold) &&
            (transpiration >= transpirationThreshold));
}

@end
