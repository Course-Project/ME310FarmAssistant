//
//  GlobalConfig.h
//  ME310FarmAssistant
//
//  Created by Tom Hu on 6/2/15.
//  Copyright (c) 2015 Tom Hu. All rights reserved.
//

#ifndef ME310FarmAssistant_GlobalConfig_h
#define ME310FarmAssistant_GlobalConfig_h

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, FADataFilterMode) {
    FADataFilterModeMoisture,
    FADataFilterModeTranspiration,
    FADataFilterModeBoth,
};

typedef NS_ENUM(NSUInteger, FAHeatMapType) {
    FAHeatMapTypeMoisture,
    FAHeatMapTypeTranspiration,
    FAHeatMapTypeMixed,
    FAHeatMapTypeNone,
};

#endif
