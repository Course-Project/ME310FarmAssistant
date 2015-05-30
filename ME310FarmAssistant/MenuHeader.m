//
//  MenuHeader.m
//  ME310FarmAssistant
//
//  Created by Nathan on 5/29/15.
//  Copyright (c) 2015 Tom Hu. All rights reserved.
//

#import "MenuHeader.h"
#import "NMRangeSlider.h"


@interface MenuHeader()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UISlider *soilMoistureSlider;
@property (weak, nonatomic) IBOutlet UISlider *transpirationSlider;

@property (weak, nonatomic) NSDate *selectedDate;
@property (weak, nonatomic) IBOutlet UITextField *dateStartTextField;
@property (weak, nonatomic) IBOutlet UITextField *dateEndTextField;



@end

@implementation MenuHeader

- (void)awakeFromNib{
    self.backgroundColor = UIColorFromRGB(0x067AB5);
    self.dateStartTextField.delegate = self;
    self.dateEndTextField.delegate = self;
    
    [self configureDatePicker];
}

- (IBAction)soilMoisureSliderValueChanged:(UISlider *)slider {
    [[NSNotificationCenter defaultCenter]postNotificationName:@"SoilMoisureSliderValue" object:[NSNumber numberWithUnsignedInteger:slider.value]];
    
}
- (IBAction)transpirationSliderValueChnaged:(UISlider *)slider {
   [[NSNotificationCenter defaultCenter]postNotificationName:@"TranspirationSliderValue" object:[NSNumber numberWithUnsignedInteger:slider.value]];
    
}

- (void)configureDatePicker{
    UIDatePicker *startDatePicker = [[UIDatePicker alloc]init];
    startDatePicker.datePickerMode = UIDatePickerModeDateAndTime;
    [startDatePicker addTarget:self action:@selector(startDatePickerValueChanged:) forControlEvents:UIControlEventValueChanged];
    
    UIDatePicker *endDatePicker = [[UIDatePicker alloc]init];
    endDatePicker.datePickerMode = UIDatePickerModeDateAndTime;
    [endDatePicker addTarget:self action:@selector(endDatePickerValueChanged:) forControlEvents:(UIControlEventValueChanged)];
    
    UIToolbar *toolBar = [[UIToolbar alloc]init];
    [toolBar sizeToFit];
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(barbuttonDidPressed:)];
    toolBar.items = [NSArray arrayWithObjects:barButton,nil];
    
    self.dateStartTextField.inputView = startDatePicker;
    self.dateEndTextField.inputView = endDatePicker;
    self.dateStartTextField.inputAccessoryView = toolBar;
    self.dateEndTextField.inputAccessoryView = toolBar;
}



- (void)startDatePickerValueChanged:(UIDatePicker *)picker{
    NSLog(@"%@",picker.date);
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm";
    self.dateStartTextField.text = [dateFormatter stringFromDate:picker.date];
}

- (void)endDatePickerValueChanged:(UIDatePicker *)picker{
    NSLog(@"%@",picker.date);
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm";
    self.dateEndTextField.text = [dateFormatter stringFromDate:picker.date];
}

- (void)barbuttonDidPressed: (UIBarButtonItem *)button{
    
    
    [self.dateStartTextField resignFirstResponder];
    [self.dateEndTextField resignFirstResponder];
}

@end
