//
//  MenuHeader.h
//  ME310FarmAssistant
//
//  Created by Nathan on 5/29/15.
//  Copyright (c) 2015 Tom Hu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ARSegmentPageController.h"
#import "HSDatePickerViewController.h"

@interface MenuHeader : UIView<ARSegmentPageControllerHeaderProtocol>

typedef NS_ENUM(NSUInteger, TimeRange) {
    TimeRangeStart,
    TimeRangeEnd,
    TimeRangeNone,
};

@property (nonatomic, assign) TimeRange currentTimeRange;

@property (weak, nonatomic) UIViewController<HSDatePickerViewControllerDelegate> *currentViewController;

@property (weak, nonatomic) IBOutlet UIView *contentView;

@property (weak, nonatomic) IBOutlet UILabel *settingTitleLabel;

@end
