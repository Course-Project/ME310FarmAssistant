//
//  AssistantClient.h
//  ME310FarmAssistant
//
//  Created by Tom Hu on 4/7/15.
//  Copyright (c) 2015 Tom Hu. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, FAHeatMapType) {
    FAHeatMapTypeMoisture,
    FAHeatMapTypeTranspiration,
    FAHeatMapTypeMixed,
    FAHeatMapTypeNone,
};

typedef void(^responseBlock)(id res, NSError *err);

@class DataPoint;

@interface AssistantClient : NSObject

#pragma mark Singleton
/**
 *  Get client singleton
 *
 *  @return client singleton instance
 */
+ (AssistantClient *)sharedClient;

#pragma mark - Network
- (void)getDataPointsWithCallback:(responseBlock)callback;
- (void)getImportantDataPointWithCallback:(responseBlock)callback;
- (void)getDetailWithDataPointID:(NSUInteger)dataPointID callback:(responseBlock)callback;
- (void)getHistoryFrom:(NSString *)fromTime To:(NSString *)toTime callback:(responseBlock)callback;
- (void)getHeatMapWithType:(FAHeatMapType)type callback:(responseBlock)callback;

@end
