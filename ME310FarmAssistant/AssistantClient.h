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
- (void)getDataPointsWithSuccessBlock:(void (^)(NSArray *dataPoints))success;

/**
 *  Fetch detail information of a specific data point
 *
 *  @param dataPointID each data points have different ID
 *  @param success     callback block
 */
- (void)getDetailWithDataPointID:(NSUInteger)dataPointID success:(void (^)(NSDictionary *dataDict))success;

/**
 *  Fetch data points in a certain time range
 *
 *  @param fromTime begin time
 *  @param toTime   end time
 *  @param success  callback block
 */
- (void)getHistoryFrom:(NSDate *)fromTime To:(NSDate *)toTime success:(void (^)(NSArray *historyDataPoints))success;

@end
