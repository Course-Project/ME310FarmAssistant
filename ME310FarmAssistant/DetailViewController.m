//
//  DetailViewController.m
//  ME310FarmAssistant
//
//  Created by Tom Hu on 4/6/15.
//  Copyright (c) 2015 Tom Hu. All rights reserved.
//

#import "DetailViewController.h"
#import "DataPoint.h"

@interface DetailViewController ()

@property (nonatomic, weak) IBOutlet UILabel *moistureLabel;
@property (nonatomic, weak) IBOutlet UILabel *airTemperatureLabel;
@property (nonatomic, weak) IBOutlet UILabel *leafTemperatureLabel;
@property (nonatomic, weak) IBOutlet UILabel *humidityLabel;
@property (nonatomic, weak) IBOutlet UILabel *transpirationLabel;
@property (nonatomic, weak) IBOutlet UIImageView *photoImageView;

@end

@implementation DetailViewController

#pragma mark Life Circle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Configure Status Bar
    [self configureStatusBar];
    
    WEAKSELF_T weakSelf = self;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [[AssistantClient sharedClient] getDetailIndoWithDataPointID:self.pointID success:^(NSDictionary *dict) {
        DataPoint *dataPoint = [[DataPoint alloc] initWithDictionary:dict];
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        
        // Updating UI
        [weakSelf displayData:dataPoint];
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.navigationController setNavigationBarHidden:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UI Methods
- (void)configureStatusBar {
    //Status Bar
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
}

- (void)displayData:(DataPoint *)dataPoint {
    [self.moistureLabel setText:[dataPoint.moisture stringValue]];
    [self.airTemperatureLabel setText:[dataPoint.airTemperature stringValue]];
    [self.leafTemperatureLabel setText:[dataPoint.leafTemperature stringValue]];
    [self.humidityLabel setText:[dataPoint.humidity stringValue]];
    [self.transpirationLabel setText:[dataPoint.transpiration stringValue]];
    
    // TODO
    // Updating Image
    // self.photoImageView
}

@end
