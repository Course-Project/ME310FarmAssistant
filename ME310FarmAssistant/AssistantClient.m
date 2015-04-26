//
//  AssistantClient.m
//  ME310FarmAssistant
//
//  Created by Tom Hu on 4/7/15.
//  Copyright (c) 2015 Tom Hu. All rights reserved.
//

#import "AssistantClient.h"
#import "DataPoint.h"

@implementation AssistantClient

#pragma mark Singleton

+ (AssistantClient *)sharedClient {
    static AssistantClient *sharedClient = nil;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        sharedClient = [[super allocWithZone:NULL] init];
    });
    return sharedClient;
}

# pragma mark alloc

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    return [self sharedClient];
}

#pragma mark -
#pragma mark Basic HTTP Method



#pragma mark -
#pragma mark Network

- (NSArray *)getDataPoints {
    NSMutableArray *result = [[NSMutableArray alloc] init];
    
    
    
    return result;
}

- (DataPoint *)getDetailIndoWithDataPointID:(NSUInteger)dataPointID {
    DataPoint *dataPoint = [[DataPoint alloc] init];
    
    
    
    return dataPoint;
}

@end
