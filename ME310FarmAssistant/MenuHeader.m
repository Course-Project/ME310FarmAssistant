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

@property (weak, nonatomic) IBOutlet UISlider *transpirationSlider;

@property (strong, nonatomic) NSDate *startDate;
@property (strong, nonatomic) NSDate *endDate;

@property (weak, nonatomic) IBOutlet UITextField *dateStartTextField;
@property (weak, nonatomic) IBOutlet UITextField *dateEndTextField;

@property (weak, nonatomic) IBOutlet UIView *shadowView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicator;

@property (weak, nonatomic) IBOutlet UILabel *moistureLowerLabel;

@property (weak, nonatomic) IBOutlet UILabel *moistureUpperLabel;
@property (weak, nonatomic) IBOutlet UILabel *transpirationLabel;
@property (strong, nonatomic) IBOutlet NMRangeSlider *rangeSlider;

@end

@implementation MenuHeader

- (void)awakeFromNib{
    self.backgroundColor = UIColorFromRGB(0x067AB5);
    self.dateStartTextField.delegate = self;
    self.dateEndTextField.delegate = self;
    
    [self configureDatePicker];
    [self configureNotification];
    [self configureSlider];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Notification

- (void)configureNotification{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moistureHeatMapWillGenerate:) name:@"WillGenerateMoistureHeatMap" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moistureHeatMapDidGenerate:) name:@"DidGenerateMoistureHeatMap" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(transpirationHeatMapWillGenerate:) name:@"WillGenerateTranspirationHeatMap" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(transpirationHeatMapDidGenerate:) name:@"DidGenerateTranspirationHeatMap" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getMoistureValueRange:) name:@"MoistureValueRange" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getTranspirationValueRange:) name:@"TranspirationValueRange" object:nil];
    
}

#pragma mark - UI Configure
- (void)configureSlider {
    self.rangeSlider.minimumValue = 0;
    self.rangeSlider.maximumValue = 100;
    self.rangeSlider.upperValue = 80.00;
    self.rangeSlider.lowerValue = 20.00;
    self.moistureLowerLabel.text = [NSString stringWithFormat:@"%d",(int)self.rangeSlider.lowerValue];
    self.moistureUpperLabel.text = [NSString stringWithFormat:@"%d",(int)self.rangeSlider.upperValue];
    self.transpirationLabel.text = [NSString stringWithFormat:@"%d",(int)self.transpirationSlider.value];
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
- (IBAction)rangeSliderTouchUpInside:(id)sender {
    [[NSNotificationCenter defaultCenter]postNotificationName:@"SoilMoisureSliderValue" object:[NSArray arrayWithObjects:[NSNumber numberWithUnsignedInteger:self.rangeSlider.lowerValue],[NSNumber numberWithUnsignedInteger:self.rangeSlider.upperValue], nil]];
    
}
- (IBAction)rangeSliderDragUpInside:(id)sender {

    self.moistureLowerLabel.text = [NSString stringWithFormat:@"%d",(int)self.rangeSlider.lowerValue];
    self.moistureUpperLabel.text = [NSString stringWithFormat:@"%d",(int)self.rangeSlider.upperValue];
    
}

- (IBAction)transpirationSliderTouchUpInside:(UISlider *)slider {
    [[NSNotificationCenter defaultCenter]postNotificationName:@"TranspirationSliderValue" object:[NSNumber numberWithUnsignedInteger:slider.value]];
}
- (IBAction)transpirationSliderValueChanged:(id)sender {
    self.transpirationLabel.text = [NSString stringWithFormat:@"%d",(int)self.transpirationSlider.value];
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

- (void)getMoistureValueRange:(NSNotification *)notification{
    NSArray *moistureValueRange = notification.object;
    float minValue = [[moistureValueRange firstObject] floatValue];
    float maxValue = [[moistureValueRange lastObject] floatValue];
    
    self.rangeSlider.minimumValue = minValue;
    self.rangeSlider.maximumValue = maxValue;
    self.rangeSlider.lowerValue = (maxValue - minValue) * 0.2 + minValue;
    self.rangeSlider.upperValue = maxValue - (maxValue - minValue) * 0.2;
    
}
- (void)getTranspirationValueRange:(NSNotification *)notification{
    NSArray *transpirationValueRange = notification.object;
    float minValue = [[transpirationValueRange firstObject] floatValue];
    float maxValue = [[transpirationValueRange lastObject] floatValue];
    
    self.transpirationSlider.minimumValue = minValue;
    self.transpirationSlider.maximumValue = maxValue;
    self.transpirationSlider.value = (maxValue - minValue) * 0.3 + minValue;
}
#pragma mark - Util

- (void)openUserInteraction{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.shadowView.hidden = YES;
        self.rangeSlider.userInteractionEnabled = YES;
        self.transpirationSlider.userInteractionEnabled = YES;
        self.dateEndTextField.userInteractionEnabled = YES;
        self.dateStartTextField.userInteractionEnabled = YES;
        [self.indicator stopAnimating];
    });
}

- (void)closeUserInteraction{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.shadowView.hidden = NO;
        self.rangeSlider.userInteractionEnabled = NO;
        self.transpirationSlider.userInteractionEnabled = NO;
        self.dateEndTextField.userInteractionEnabled = NO;
        self.dateStartTextField.userInteractionEnabled = NO;
        [self.indicator startAnimating];
    });

}
@end
