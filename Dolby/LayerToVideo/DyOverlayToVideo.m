//
//  DyOverlayToVideo.m
//  Dolby
//
//  Created by hr on 2017/12/18.
//  Copyright © 2017年 王腾飞. All rights reserved.
//

#import "DyOverlayToVideo.h"
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>

@implementation DyOverlayToVideo
- (void)applyVideoEffectsToComposition:(AVMutableVideoComposition *)composition size:(CGSize)size
    {
        // 1 - set up the overlay
        CALayer *overlayLayer = [CALayer layer];
        UIImage *overlayImage = nil;
        /*
        if (_frameSelectSegment.selectedSegmentIndex == 0) {
            overlayImage = [UIImage imageNamed:@"Frame-1.png"];
        } else if(_frameSelectSegment.selectedSegmentIndex == 1) {
            overlayImage = [UIImage imageNamed:@"Frame-2.png"];
        } else if(_frameSelectSegment.selectedSegmentIndex == 2) {
            overlayImage = [UIImage imageNamed:@"Frame-3.png"];
        }
        */
        [overlayLayer setContents:(id)[overlayImage CGImage]];
        overlayLayer.frame = CGRectMake(0, 0, size.width, size.height);
        [overlayLayer setMasksToBounds:YES];
        
        // 2 - set up the parent layer
        CALayer *videoLayer = [CALayer layer];
        videoLayer.frame = CGRectMake(0, 0, size.width, size.height);
        
        
        CALayer *parentLayer = [CALayer layer];
        parentLayer.frame = CGRectMake(0, 0, size.width, size.height);
        
        [parentLayer addSublayer:videoLayer];
        [parentLayer addSublayer:overlayLayer];
        
        // 3 - apply magic
        composition.animationTool = [AVVideoCompositionCoreAnimationTool
                                     videoCompositionCoreAnimationToolWithPostProcessingAsVideoLayer:videoLayer inLayer:parentLayer];
    }
@end
