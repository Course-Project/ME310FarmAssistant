//
//  CustomSyncTileLayer.m
//  ME310FarmAssistant
//
//  Created by Tom Hu on 4/26/15.
//  Copyright (c) 2015 Tom Hu. All rights reserved.
//

#import "CustomSyncTileLayer.h"

@interface CustomSyncTileLayer ()

@property (nonatomic) double cropRectWidth;
@property (nonatomic) double cropRectHeight;

@end

@implementation CustomSyncTileLayer

- (instancetype)initWithHeatMapImage:(UIImage *)heatMapImage zoom:(float)zoom {
    self = [super init];
    if (self) {
        _heatMapImage = heatMapImage;
        _cropRectWidth = heatMapImage.size.width / 4;
        _cropRectHeight = heatMapImage.size.height / 4;
    }
    return self;
}

- (UIImage *)tileForX:(NSUInteger)x y:(NSUInteger)y zoom:(NSUInteger)zoom {
    if (self.heatMapImage) {
        return _heatMapImage;
    }
    return kGMSTileLayerNoTile;
}

@end
