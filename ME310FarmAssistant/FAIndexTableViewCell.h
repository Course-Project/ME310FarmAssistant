//
//  FAIndexTableViewCell.h
//  ME310FarmAssistant
//
//  Created by Tom Hu on 5/9/15.
//  Copyright (c) 2015 Tom Hu. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DataPoint;

@interface FAIndexTableViewCell : UITableViewCell

@property (nonatomic, readonly) NSUInteger pointID;

- (instancetype)initWithDataPoint:(DataPoint *)dataPoint;
- (void)configureWithDataPoint:(DataPoint *)dataPoint;

@end
