//
//  CustomSyncTileLayer.h
//  ME310FarmAssistant
//
//  Created by Tom Hu on 4/26/15.
//  Copyright (c) 2015 Tom Hu. All rights reserved.
//

#import <GoogleMaps/GoogleMaps.h>

@interface CustomSyncTileLayer : GMSSyncTileLayer

@property (nonatomic, strong) UIImage *heatMapImage;

- (instancetype)initWithHeatMapImage:(UIImage *)heatMapImage zoom:(float)zoom;;

@end
