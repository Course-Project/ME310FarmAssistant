//
//  FAMapOverlayView.h
//  ME310FarmAssistant
//
//  Created by Nathan on 5/4/15.
//  Copyright (c) 2015 Tom Hu. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface FAMapOverlayView : MKOverlayView

@property (nonatomic, strong) UIImage *heatMapImage;
@property (nonatomic, assign) float widthRatio;
@property (nonatomic, assign) float heightRatio;

@end
