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

#pragma mark -
#pragma mark Network

/**
 *  Fetch data points collected within xxx hours
 *
 *  @return an array with general information about each data points
 */
- (NSArray *)getDataPoints;

/**
 *  Fetch detail information of a specific data point
 *
 *  @param dataPointID each data points have different ID
 *
 *  @return a 'DataPoint' object
 */
- (DataPoint *)getDetailIndoWithDataPointID:(NSUInteger)dataPointID;

@end
