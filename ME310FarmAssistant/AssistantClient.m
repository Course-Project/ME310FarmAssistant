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
// TODO - Refactor


#pragma mark - Network
- (void)getDataPointsWithSuccessBlock:(void (^)(NSArray *dataPoints))success {
    NSDictionary *parameters = @{
                                 @"time_from": @"2015-04-27",
                                 @"time_to": @"2015-04-28"
                                 };
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html", @"application/json", nil];
    [manager GET:@"http://film.h1994st.com:8899/farm/gethistory"
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

- (void)getDetailIndoWithDataPointID:(NSUInteger)dataPointID success:(void (^)(NSDictionary *dataDict))success {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *parameters = @{
                                 @"id": [NSNumber numberWithUnsignedInteger:dataPointID],
                                 };
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html", @"application/json", nil];
    [manager GET:@"http://film.h1994st.com:8899/farm/getdetail"
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

@end
