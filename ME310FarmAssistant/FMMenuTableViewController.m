//
//  FMMenuTableViewController.m
//  ME310FarmAssistant
//
//  Created by Tom Hu on 5/28/15.
//  Copyright (c) 2015 Tom Hu. All rights reserved.
//

#import "FMMenuTableViewController.h"
#import "DataPoint.h"
#import "FAIndexTableViewCell.h"
#import "DetailTableViewController.h"
#import <MZFormSheetController/MZFormSheetController.h>

@interface FMMenuTableViewController ()

@property (nonatomic, assign) BOOL isHistory;
@property (nonatomic, assign) double moistureDryThreshold;
@property (nonatomic, assign) double moistureWetThreshold;
@property (nonatomic, assign) double transpirationThreshold;

@property (nonatomic, strong) NSArray *originalDataPoints;

@property (nonatomic, strong) NSMutableArray *importantDataPoints;

@end

@implementation FMMenuTableViewController

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
    
    self.isHistory = NO;
    self.moistureWetThreshold = 20;
    self.moistureDryThreshold = 80;
    self.transpirationThreshold = 30;
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithDouble:20.0f] forKey:@"MoistureThreshold"];
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithDouble:30.0f] forKey:@"TranspirationThreshold"];
    
    // Configure Refresh Control
    [self configureRefreshControl];
    
    // Load Data
    [self refreshData:nil];
    
    // Add Observers
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveMoistureSliderNotification:)
                                                 name:@"SoilMoisureSliderValue"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveTranspirationSliderNotification:)
                                                 name:@"TranspirationSliderValue"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveDatePickerNotification:)
                                                 name:@"HistoryDateSelected"
                                               object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - UI Methods
- (void)configureRefreshControl {
    self.refreshControl = [[UIRefreshControl alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.tableView.frame.size.width, 100.0f)];
    [self.refreshControl addTarget:self action:@selector(refreshData:) forControlEvents:UIControlEventValueChanged];
    self.tableView.tableHeaderView = [[UIView alloc] init];
    [self.tableView.tableHeaderView addSubview:self.refreshControl];
}

- (void)refreshData:(id)sender {
    [self.refreshControl beginRefreshing];
    WEAKSELF_T weakSelf = self;
    [self configureDataPointWithCompletion:^ {
        [weakSelf.tableView reloadData];
        [self.refreshControl endRefreshing];
    }];
}

- (void)configureDataPointWithCompletion:(void (^)(void))completed{
    AssistantClient *client = [AssistantClient sharedClient];
    WEAKSELF_T weakSelf = self;
    [SVProgressHUD showWithStatus:@"Loading..."];
    [client getDataPointsWithCallback:^(NSDictionary *res, NSError *err) {
        if (err) {
            [SVProgressHUD showErrorWithStatus:@"Network Error!"];
            return;
        }
        
        NSArray *points = res[@"data"];
        weakSelf.originalDataPoints = points;
        
        [weakSelf filterDataPoints];
        
        if (completed) {
            completed();
        }
        
        [SVProgressHUD showSuccessWithStatus:@"Success!"];
    }];
}

#pragma mark - Utils
- (void)filterDataPoints {
    NSLog(@"Filtering...");
    [self.importantDataPoints removeAllObjects];
    for (id obj in self.originalDataPoints) {
        double moisture = [obj[@"moisture"] doubleValue];
        double transpiration = [obj[@"transpiration"] doubleValue];
        
        if ((moisture >= _moistureWetThreshold && moisture <= _moistureDryThreshold) &&
            (transpiration >= _transpirationThreshold))
            continue; // Filter
        
        DataPoint *point = [[DataPoint alloc] initWithDictionary:obj];
        [self.importantDataPoints addObject:point];
    }
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 70;
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (0 == [self.importantDataPoints count]) {
        return 1;
    }
    
    return [self.importantDataPoints count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // No Data
    if (0 == [self.importantDataPoints count]) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NoPointCell" forIndexPath:indexPath];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"NoPointCell"];
        }
        return cell;
    }
    
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
    
    // Solution: Send notification
    FAIndexTableViewCell *cell = (FAIndexTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ShowAnnotationCalloutView"
                                                        object:[NSNumber numberWithUnsignedInteger:cell.pointID]];
}

#pragma mark - Header View Delegate

-(NSString *)segmentTitle
{
    return nil;
}

-(UIScrollView *)streachScrollView
{
    return self.tableView;
}

#pragma mark - Observers
- (void)didReceiveMoistureSliderNotification:(NSNotification *)notification {
    NSLog(@"Moisture Threshold Changed!");
    NSLog(@"Moisture Threshold: %@", notification.object);
    
    NSArray *threshold = notification.object;

    self.moistureDryThreshold = [[threshold objectAtIndex:0] doubleValue];
    self.moistureWetThreshold = [[threshold objectAtIndex:1] doubleValue];
    
    [[NSUserDefaults standardUserDefaults] setObject:notification.object forKey:@"MoistureThreshold"];
    
    [self filterDataPoints];
    
    [self.tableView reloadData];
}

- (void)didReceiveTranspirationSliderNotification:(NSNotification *)notification {
    NSLog(@"Transpiration Threshold Changed!");
    NSLog(@"Transpiration Threshold: %@", notification.object);
    
    self.transpirationThreshold = [notification.object doubleValue];
    
    [[NSUserDefaults standardUserDefaults] setObject:notification.object forKey:@"TranspirationThreshold"];
    
    [self filterDataPoints];
    
    [self.tableView reloadData];
}

- (void)didReceiveDatePickerNotification:(NSNotification *)notification {
    NSLog(@"Date Range Changed!");
    NSLog(@"Date Range: %@", notification.object);
    
    self.isHistory = YES;
    
}

@end
