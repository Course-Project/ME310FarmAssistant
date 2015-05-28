//
//  FMRootNavigationController.m
//  ME310FarmAssistant
//
//  Created by Tom Hu on 5/28/15.
//  Copyright (c) 2015 Tom Hu. All rights reserved.
//

#import "FMRootNavigationController.h"
#import <REFrostedViewController/REFrostedViewController.h>

@interface FMRootNavigationController ()

@end

@implementation FMRootNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognized:)]];
}

#pragma mark -
#pragma mark Gesture recognizer
- (void)panGestureRecognized:(UIPanGestureRecognizer *)sender {
    // Dismiss keyboard (optional)
    //
    [self.view endEditing:YES];
    [self.frostedViewController.view endEditing:YES];
    
    // Present the view controller
    //
    [self.frostedViewController panGestureRecognized:sender];
}

@end
