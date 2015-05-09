//
//  FAIndexTableViewCell.m
//  ME310FarmAssistant
//
//  Created by Tom Hu on 5/9/15.
//  Copyright (c) 2015 Tom Hu. All rights reserved.
//

#import "FAIndexTableViewCell.h"
#import "DataPoint.h"

@interface FAIndexTableViewCell ()

@property (nonatomic, weak) IBOutlet UILabel *pointIDLabel;
@property (nonatomic, weak) IBOutlet UILabel *moistureLable;
@property (nonatomic, weak) IBOutlet UILabel *transpirationLable;

@end

@implementation FAIndexTableViewCell

#pragma mark Life Circle
- (instancetype)initWithDataPoint:(DataPoint *)dataPoint {
    self = [super init];
    if (self) {
        [self configureWithDataPoint:dataPoint];
    }
    return self;
}

#pragma mark - UI Methods
- (void)configureWithDataPoint:(DataPoint *)dataPoint {
    _pointID = dataPoint.pointID;
    [self.pointIDLabel setText:[NSString stringWithFormat:@"%tu", dataPoint.pointID]];
    [self.moistureLable setText:[dataPoint.moisture stringValue]];
    [self.transpirationLable setText:[dataPoint.transpiration stringValue]];
}

@end
