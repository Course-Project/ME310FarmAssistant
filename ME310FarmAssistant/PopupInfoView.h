//
//  PopupInfoView.h
//  ME310FarmAssistant
//
//  Created by Tom Hu on 4/6/15.
//  Copyright (c) 2015 Tom Hu. All rights reserved.
//

#import <UIKit/UIKit.h>

IB_DESIGNABLE
@interface PopupInfoView : UIView

@property (nonatomic) IBInspectable CGFloat radius;
@property (nonatomic, weak) IBOutlet UILabel *label;

@end
