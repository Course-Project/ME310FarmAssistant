//
//  MenuHeader.m
//  ME310FarmAssistant
//
//  Created by Nathan on 5/29/15.
//  Copyright (c) 2015 Tom Hu. All rights reserved.
//

#import "MenuHeader.h"
#import "NMRangeSlider.h"
#import "HSDatePickerViewController.h"

@interface MenuHeader()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UISlider *soilMoistureSlider;
@property (weak, nonatomic) IBOutlet UISlider *transpirationSlider;

@property (weak, nonatomic) NSDate *selectedDate;

@end

@implementation MenuHeader

- (void)awakeFromNib{
    self.backgroundColor = UIColorFromRGB(0x067AB5);
    
}

- (IBAction)soilMoisureSliderValueChanged:(UISlider *)slider {
    [[NSNotificationCenter defaultCenter]postNotificationName:@"SoilMoisureSliderValue" object:[NSNumber numberWithUnsignedInteger:slider.value]];
    
}
- (IBAction)transpirationSliderValueChnaged:(UISlider *)slider {
   [[NSNotificationCenter defaultCenter]postNotificationName:@"TranspirationSliderValue" object:[NSNumber numberWithUnsignedInteger:slider.value]];
    
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
//    HSDatePickerViewController *hsdpvc = [HSDatePickerViewController new];
//    hsdpvc.delegate = self;
//    if (self.selectedDate) {
//        hsdpvc.date = self.selectedDate;
//    }
//    [self presentViewController:hsdpvc animated:YES completion:nil];
    return YES;
}



@end
