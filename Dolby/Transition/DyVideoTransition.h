//
//  DyVideoTransition.h
//  Dolby
//
//  Created by hr on 2017/12/21.
//  Copyright © 2017年 王腾飞. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface DyVideoTransition : NSObject
- (instancetype)initWithAssets:(NSArray <AVAsset *>*)videoAssets;
- (AVPlayerItem *)makePlayable;
@end
