//
//  DetailViewController.h
//  ME310FarmAssistant
//
//  Created by Tom Hu on 4/6/15.
//  Copyright (c) 2015 Tom Hu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailTableViewController : UITableViewController

@property (nonatomic) NSUInteger pointID;
@property (nonatomic, strong) DataPoint *dataPoint;

@end
