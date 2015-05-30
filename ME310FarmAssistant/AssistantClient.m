//
//  AssistantClient.m
//  ME310FarmAssistant
//
//  Created by Tom Hu on 4/7/15.
//  Copyright (c) 2015 Tom Hu. All rights reserved.
//

#import "AssistantClient.h"

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

#pragma mark - Basic HTTP Method
- (void)GET:(NSString *)api parameters:(id)parameters success:(void (^)(id obj))success {
    // Show network activity indicator
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html", @"application/json", nil];
    [manager GET:api
      parameters:parameters
         success:^(AFHTTPRequestOperation *operation, id responseObjecct) {
             NSLog(@"Fetch data successfully!");
             // Hide network activity indicator
             [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
             
             if (success) {
                 success(responseObjecct);
             }
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             NSLog(@"Error: %@", error);
             [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
         }];
}

#pragma mark - Network
- (void)getDataPointsWithSuccessBlock:(void (^)(id dataPoints))success {
    [self GET:[baseURL stringByAppendingString:getData] parameters:nil success:success];
}

- (void)getImportantDataPointWithSuccessBlock:(void (^)(id importantDataPoints))success {
    [self GET:[baseURL stringByAppendingString:getImportantData] parameters:nil success:success];
}

- (void)getDetailWithDataPointID:(NSUInteger)dataPointID success:(void (^)(id dataDict))success {
    NSDictionary *parameters = @{@"id": [NSNumber numberWithUnsignedInteger:dataPointID]};
    [self GET:[baseURL stringByAppendingString:getDetail] parameters:parameters success:success];
}

- (void)getHistoryFrom:(NSString *)fromTime To:(NSString *)toTime success:(void (^)(id historyDataPoints))success {
    NSDictionary *parameters = @{@"time_from": fromTime, @"time_to": toTime};
    [self GET:[baseURL stringByAppendingString:getHistory] parameters:parameters success:success];
}

- (void)getHeatMapWithType:(FAHeatMapType)type success:(void (^)(id heatMapData))success {
    NSString *heatMapType;
    switch (type) {
        case FAHeatMapTypeMoisture:
            heatMapType = @"moisture";
            break;
        case FAHeatMapTypeTranspiration:
            heatMapType = @"transpiration";
            break;
        case FAHeatMapTypeMixed:
            heatMapType = @"both";
            break;
        default:
            heatMapType = @"none";
            break;
    }
    NSDictionary *parameters = @{@"type": heatMapType};
    [self GET:[baseURL stringByAppendingString:getHeatMap] parameters:parameters success:success];
}

@end
