//
//  DetailViewController.m
//  ME310FarmAssistant
//
//  Created by Tom Hu on 4/6/15.
//  Copyright (c) 2015 Tom Hu. All rights reserved.
//

#import "DetailViewController.h"
#import "DataPoint.h"
#import <UIImageView+AFNetworking.h>
#import <ASMediaFocusManager/ASMediaFocusManager.h>

@interface DetailViewController () <ASMediasFocusDelegate>

@property (nonatomic, weak) IBOutlet UILabel *moistureLabel;
@property (nonatomic, weak) IBOutlet UILabel *airTemperatureLabel;
@property (nonatomic, weak) IBOutlet UILabel *leafTemperatureLabel;
@property (nonatomic, weak) IBOutlet UILabel *humidityLabel;
@property (nonatomic, weak) IBOutlet UILabel *transpirationLabel;
@property (nonatomic, weak) IBOutlet UIImageView *photoImageView;

@property (nonatomic, strong) ASMediaFocusManager *mediaFocusManager;

@end

@implementation DetailViewController

#pragma mark Life Circle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.mediaFocusManager = [[ASMediaFocusManager alloc] init];
    self.mediaFocusManager.delegate = self;
    self.mediaFocusManager.elasticAnimation = YES;
    
    WEAKSELF_T weakSelf = self;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [[AssistantClient sharedClient] getDetailWithDataPointID:self.pointID success:^(NSDictionary *dict) {
        weakSelf.dataPoint = [[DataPoint alloc] initWithDictionary:dict];
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        
        // Updating UI
        [weakSelf displayData:weakSelf.dataPoint];
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // Configure Bars
    [self configureBars];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UI Methods
- (void)configureBars {
    //Status Bar
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
    
    // Navigation Bar
    [self.navigationController setNavigationBarHidden:NO];
}

- (void)displayData:(DataPoint *)dataPoint {
    [self.moistureLabel setText:[dataPoint.moisture stringValue]];
    [self.airTemperatureLabel setText:[dataPoint.airTemperature stringValue]];
    [self.leafTemperatureLabel setText:[dataPoint.leafTemperature stringValue]];
    [self.humidityLabel setText:[dataPoint.humidity stringValue]];
    [self.transpirationLabel setText:[dataPoint.transpiration stringValue]];
    
    // Updating Image
    NSString *imageURLString = [photoBaseURL stringByAppendingString:dataPoint.photoURLPathString];
    [self.photoImageView setImageWithURL:[NSURL URLWithString:imageURLString]];
    
    [self.mediaFocusManager installOnView:self.photoImageView];
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - ASMediasFocusDelegate
// Returns the view controller in which the focus controller is going to be added. This can be any view controller, full screen or not.
- (UIViewController *)parentViewControllerForMediaFocusManager:(ASMediaFocusManager *)mediaFocusManager {
    return self;
}

// Returns the URL where the media (image or video) is stored. The URL may be local (file://) or distant (http://).
- (NSURL *)mediaFocusManager:(ASMediaFocusManager *)mediaFocusManager mediaURLForView:(UIView *)view {
    NSString *imageURLString = [photoBaseURL stringByAppendingString:self.dataPoint.photoURLPathString];
    return [NSURL URLWithString:imageURLString];
}

// Returns the title for this media view. Return nil if you don't want any title to appear.
- (NSString *)mediaFocusManager:(ASMediaFocusManager *)mediaFocusManager titleForView:(UIView *)view {
    return @"test";
}

- (void)mediaFocusManagerWillAppear:(ASMediaFocusManager *)mediaFocusManager {
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)mediaFocusManagerWillDisappear:(ASMediaFocusManager *)mediaFocusManager {
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

@end
