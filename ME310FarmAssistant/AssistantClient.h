//
//  AssistantClient.h
//  ME310FarmAssistant
//
//  Created by Tom Hu on 4/7/15.
//  Copyright (c) 2015 Tom Hu. All rights reserved.
//

#import <Foundation/Foundation.h>

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
/**
 *  Fetch data points collected within xxx hours
 *
 *  @param success callback block
 */
- (void)getDataPointsWithSuccessBlock:(void (^)(id dataPoints))success;

/**
 *  Fetch data points (moisture < 30, moisture >60, transpiration < 20, transpiration > 50)
 *  (Fetch abnormal data points)
 *
 *  @param success callback block
 */
- (void)getImportantDataPointWithSuccessBlock:(void (^)(id importantDataPoints))success;

/**
 *  Fetch detail information of a specific data point
 *
 *  @param dataPointID each data points have different ID
 *  @param success     callback block
 */
- (void)getDetailWithDataPointID:(NSUInteger)dataPointID success:(void (^)(id dataDict))success;

/**
 *  Fetch data points in a certain time range
 *
 *  @param fromTime begin time
 *  @param toTime   end time
 *  @param success  callback block
 */
- (void)getHistoryFrom:(NSString *)fromTime To:(NSString *)toTime success:(void (^)(id historyDataPoints))success;

@end
