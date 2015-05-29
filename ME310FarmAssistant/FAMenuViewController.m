//
//  FAMenuViewController.m
//  ME310FarmAssistant
//
//  Created by Nathan on 5/29/15.
//  Copyright (c) 2015 Tom Hu. All rights reserved.
//

#import "FAMenuViewController.h"
#import "DataPoint.h"
#import "FAIndexTableViewCell.h"
#import "DetailTableViewController.h"
#import <MZFormSheetController/MZFormSheetController.h>
#import "MenuHeader.h"
#import "SquareCashStyleBehaviorDefiner.h"
#import "BLKDelegateSplitter.h"

@interface FAMenuViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *importantDataPoints;

@property (nonatomic, strong) UIRefreshControl *refreshControl;
@end

@implementation FAMenuViewController

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
    
    // Configure Header Bar
//    [self configureHeader];
    
    // Configure Refresh Control
    [self configureRefreshControl];
    
    // Load Data
    [self refreshData:nil];
}

#pragma mark - UI Methods
- (void)configureHeader{
    // Setup the bar
    MenuHeader *menuHeader = [[MenuHeader alloc] initWithFrame:CGRectMake(0.0, 0.0, CGRectGetWidth(self.view.frame), 100.0)];
    
    SquareCashStyleBehaviorDefiner *behaviorDefiner = [[SquareCashStyleBehaviorDefiner alloc] init];
    [behaviorDefiner addSnappingPositionProgress:0.0 forProgressRangeStart:0.0 end:0.5];
    [behaviorDefiner addSnappingPositionProgress:1.0 forProgressRangeStart:0.5 end:1.0];
    behaviorDefiner.snappingEnabled = YES;
    behaviorDefiner.elasticMaximumHeightAtTop = YES;
    menuHeader.behaviorDefiner = behaviorDefiner;
    
    // Configure a separate UITableViewDelegate and UIScrollViewDelegate (optional)
    BLKDelegateSplitter *delegateSplitter = [[BLKDelegateSplitter alloc] initWithFirstDelegate:behaviorDefiner secondDelegate:self];
    self.tableView.delegate = (id<UITableViewDelegate>)delegateSplitter;
    
    [self.view addSubview:menuHeader];
    
    // Setup the table view
    self.tableView.contentInset = UIEdgeInsetsMake(menuHeader.maximumBarHeight, 0.0, 0.0, 0.0);
    
}


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
    [client getDataPointsWithSuccessBlock:^(NSDictionary *res) {
        NSArray *points = res[@"data"];
        
        [weakSelf.importantDataPoints removeAllObjects];
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
@end