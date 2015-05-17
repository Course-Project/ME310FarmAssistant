//
//  FAIndexTableViewController.m
//  ME310FarmAssistant
//
//  Created by Tom Hu on 5/9/15.
//  Copyright (c) 2015 Tom Hu. All rights reserved.
//

#import "FAIndexTableViewController.h"
#import "DataPoint.h"
#import "FAIndexTableViewCell.h"
#import "DetailTableViewController.h"

@interface FAIndexTableViewController ()

@property (nonatomic, strong) NSMutableArray *importantDataPoints;

@end

@implementation FAIndexTableViewController

#pragma mark - Properties
- (NSMutableArray *)importantDataPoints {
    if (!_importantDataPoints) {
        _importantDataPoints = [NSMutableArray new];
    }
    return _importantDataPoints;
}

#pragma mark - Life Circle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Load Data
    WEAKSELF_T weakSelf = self;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [self configureDataPointWithCompletion:^{
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        [weakSelf.tableView reloadData];
    }];
}

#pragma mark - UI Methods
- (void)configureDataPointWithCompletion:(void (^)(void))completed{
    AssistantClient *client = [AssistantClient sharedClient];
    WEAKSELF_T weakSelf = self;
    [SVProgressHUD showWithStatus:@"Loading..."];
    [client getHistoryFrom:@"2015-05-07" To:@"2015-05-08" success:^(NSArray *points) {
        for (id obj in points) {
            double moisture = [obj[@"moisture"] doubleValue];
            double transpiration = [obj[@"transpiration"] doubleValue];
            
            // (moisture < 30, moisture >60, transpiration < 20, transpiration > 50)
            if ((moisture >= 30.0f && moisture <= 60.0f) &&
                (transpiration >= 20.0f && transpiration <= 50.0f))
                continue; // Filter
            
            DataPoint *point = [[DataPoint alloc] initWithDictionary:obj];
            [weakSelf.importantDataPoints addObject:point];
        }
        
        if (completed) {
            completed();
        }
        
        [SVProgressHUD showSuccessWithStatus:@"Success!"];
    }];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.importantDataPoints count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *reuseIdentifier = @"ImportantPointCell";
    FAIndexTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    if (!cell) {
        cell = [[FAIndexTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    }
    
    [cell configureWithDataPoint:self.importantDataPoints[indexPath.row]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqual:@"IndexToDetailSegue"]) {
        DetailTableViewController *destinationViewController = segue.destinationViewController;
        destinationViewController.pointID = [(FAIndexTableViewCell *)sender pointID];
    }
}

@end
