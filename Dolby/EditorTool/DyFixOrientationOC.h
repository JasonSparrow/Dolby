//
//  DyFixOrientationOC.h
//  Dolby
//
//  Created by hr on 2017/12/25.
//  Copyright © 2017年 王腾飞. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface DyFixOrientationOC : NSObject
+ (AVMutableVideoCompositionLayerInstruction *)layerInstructionAfterFixingOrientationForAsset:(AVAsset *)inAsset
                                                                                     forTrack:(AVMutableCompositionTrack *)inTrack
                                                                                       atTime:(CMTime)inTime;

@end

@interface DyOrientationModel : NSObject
@property (nonatomic, assign)UIImageOrientation orientation;
@property (nonatomic, assign)BOOL isPortrait;
@end
