//
//  FMRootViewController.m
//  ME310FarmAssistant
//
//  Created by Tom Hu on 5/28/15.
//  Copyright (c) 2015 Tom Hu. All rights reserved.
//

#import "FMRootViewController.h"
#import "FAMenuHeaderViewController.h"

@interface FMRootViewController ()<UIGestureRecognizerDelegate>

@end

@implementation FMRootViewController

- (void)awakeFromNib {
    self.panGestureRecognizer.delegate = self;
    self.contentViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"contentController"];
    self.menuViewController = [[FAMenuHeaderViewController alloc]init];
    
    self.direction = REFrostedViewControllerDirectionRight;
    self.limitMenuViewSize = YES;
    NSLog(@"%@", NSStringFromCGSize(self.menuViewSize));
    
    CGSize size = [UIScreen mainScreen].bounds.size;
    size.width *= 0.33;
    size.height = 0;
    
    self.menuViewSize = size;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    if([NSStringFromClass([touch.view class]) isEqualToString:@"NMRangeSlider"]) {
        return NO;
    }
    else{
        return YES;
    }
}
@end
