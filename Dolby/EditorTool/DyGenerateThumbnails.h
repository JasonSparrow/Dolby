//
//  DyGenerateThumbnails.h
//  Dolby
//
//  Created by hr on 2017/12/18.
//  Copyright © 2017年 王腾飞. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

/*
 生成一视频的缩略图
 */
@interface DyGenerateThumbnails : NSObject
- (void)generateThumbnails:(AVAsset *)asset;
@end
