//
//  DyReverseVideo.h
//  Dolby
//
//  Created by hr on 2017/12/19.
//  Copyright © 2017年 王腾飞. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface DyReverseVideo : NSObject
+ (AVAsset *)assetByReversingAsset:(AVAsset *)asset outputURL:(NSURL *)outputURL;

@end
