//
//  FMRootViewController.m
//  ME310FarmAssistant
//
//  Created by Tom Hu on 5/28/15.
//  Copyright (c) 2015 Tom Hu. All rights reserved.
//

#import "FMRootViewController.h"

@interface FMRootViewController ()

@end

@implementation FMRootViewController

- (void)awakeFromNib {
    self.contentViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"contentController"];
    self.menuViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"menuViewController"];
    
    self.direction = REFrostedViewControllerDirectionRight;
    self.limitMenuViewSize = YES;
    NSLog(@"%@", NSStringFromCGSize(self.menuViewSize));
    
    CGSize size = [UIScreen mainScreen].bounds.size;
    size.width *= 0.33;
    size.height = 0;
    
    self.menuViewSize = size;
}

@end
