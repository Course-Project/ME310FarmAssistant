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
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html", @"application/json", nil];
    [manager GET:api
      parameters:parameters
         success:^(AFHTTPRequestOperation *operation, id responseObjecct) {
             NSLog(@"Fetch data successfully!");
             if (success) {
                 success(responseObjecct);
             }
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             NSLog(@"Error: %@", error);
         }];
}

#pragma mark - Network
- (void)getDataPointsWithSuccessBlock:(void (^)(NSArray *dataPoints))success {
    [self GET:[baseURL stringByAppendingString:getData] parameters:nil success:success];
}

- (void)getDetailWithDataPointID:(NSUInteger)dataPointID success:(void (^)(NSDictionary *dataDict))success {
    NSDictionary *parameters = @{@"id": [NSNumber numberWithUnsignedInteger:dataPointID]};
    [self GET:[baseURL stringByAppendingString:getDetail] parameters:parameters success:success];
}

- (void)getHistoryFrom:(NSDate *)fromTime To:(NSDate *)toTime success:(void (^)(NSArray *historyDataPoints))success {
    NSDictionary *parameters = @{@"time_from": @"2015-05-07", @"time_to": @"2015-05-08"};
    [self GET:[baseURL stringByAppendingString:getHistory] parameters:parameters success:success];
}

@end
