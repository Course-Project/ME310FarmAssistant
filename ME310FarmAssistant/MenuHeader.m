//
//  MenuHeader.m
//  ME310FarmAssistant
//
//  Created by Nathan on 5/29/15.
//  Copyright (c) 2015 Tom Hu. All rights reserved.
//

#import "MenuHeader.h"


@interface MenuHeader()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UISlider *soilMoistureSlider;
@property (weak, nonatomic) IBOutlet UISlider *transpirationSlider;

@property (strong, nonatomic) NSDate *startDate;
@property (strong, nonatomic) NSDate *endDate;

@property (weak, nonatomic) IBOutlet UITextField *dateStartTextField;
@property (weak, nonatomic) IBOutlet UITextField *dateEndTextField;

@property (weak, nonatomic) IBOutlet UIView *shadowView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicator;

@property (weak, nonatomic) IBOutlet UILabel *moistureLabel;
@property (weak, nonatomic) IBOutlet UILabel *transpirationLabel;

@end

@implementation MenuHeader

- (void)awakeFromNib{
    self.backgroundColor = UIColorFromRGB(0x067AB5);
    self.dateStartTextField.delegate = self;
    self.dateEndTextField.delegate = self;
    
    [self configureDatePicker];
    [self configureNotification];
}

#pragma mark - Notification

- (void)configureNotification{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(moistureHeatMapWillGenerate:) name:@"WillGenerateMoistureHeatMap" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(moistureHeatMapDidGenerate:) name:@"DidGenerateMoistureHeatMap" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(transpirationHeatMapWillGenerate:) name:@"WillGenerateTranspirationHeatMap" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(transpirationHeatMapDidGenerate:) name:@"DidGenerateTranspirationHeatMap" object:nil];
    
}

#pragma mark - UI Configure
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


#pragma mark - Action
- (void)startDatePickerValueChanged:(UIDatePicker *)picker{
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm";
    self.dateStartTextField.text = [dateFormatter stringFromDate:picker.date];
    self.startDate = picker.date;
}

- (void)endDatePickerValueChanged:(UIDatePicker *)picker{
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm";
    self.dateEndTextField.text = [dateFormatter stringFromDate:picker.date];
    self.endDate = picker.date;
}

- (void)barbuttonDidPressed: (UIBarButtonItem *)button{
    [self.dateStartTextField resignFirstResponder];
    [self.dateEndTextField resignFirstResponder];
    
    if (self.startDate && self.endDate) {
        [[NSNotificationCenter defaultCenter]postNotificationName:@"HistoryDateSelected" object:[NSArray arrayWithObjects:self.startDate,self.endDate,nil]];
    }
    
}
- (IBAction)soilMoistureSliderTouchUpInside:(UISlider *)slider {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SoilMoisureSliderValue" object:[NSNumber numberWithUnsignedInteger:slider.value]];
    [self.moistureLabel setText:[NSString stringWithFormat:@"%d", (int)slider.value]];
}
- (IBAction)transpirationSliderTouchUpInside:(UISlider *)slider {
    [[NSNotificationCenter defaultCenter]postNotificationName:@"TranspirationSliderValue" object:[NSNumber numberWithUnsignedInteger:slider.value]];
    [self.transpirationLabel setText:[NSString stringWithFormat:@"%d", (int)slider.value]];
}

- (void)moistureHeatMapWillGenerate:(id)sender{
    [self closeUserInteraction];
}
- (void)moistureHeatMapDidGenerate:(id)sender{
    [self openUserInteraction];
}
- (void)transpirationHeatMapWillGenerate:(id)sender{
    [self closeUserInteraction];
}
- (void)transpirationHeatMapDidGenerate:(id)sender{
    [self openUserInteraction];
}

#pragma mark - Util

- (void)openUserInteraction{
    self.shadowView.hidden = YES;
    self.soilMoistureSlider.userInteractionEnabled = YES;
    self.transpirationSlider.userInteractionEnabled = YES;
    self.dateEndTextField.userInteractionEnabled = YES;
    self.dateStartTextField.userInteractionEnabled = YES;
    [self.indicator stopAnimating];
}

- (void)closeUserInteraction{
    self.shadowView.hidden = NO;
    self.soilMoistureSlider.userInteractionEnabled = NO;
    self.transpirationSlider.userInteractionEnabled = NO;
    self.dateEndTextField.userInteractionEnabled = NO;
    self.dateStartTextField.userInteractionEnabled = NO;
    [self.indicator startAnimating];
}
@end
