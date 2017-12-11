//
//  DyBridege.h
//  Dolby
//
//  Created by hr on 2017/12/11.
//  Copyright © 2017年 王腾飞. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>

@interface DyBridege : NSObject
- (void)generateThumbnails:(AVAsset *)asset;
@end
