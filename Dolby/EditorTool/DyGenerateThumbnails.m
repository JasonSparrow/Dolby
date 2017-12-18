//
//  DyGenerateThumbnails.m
//  Dolby
//
//  Created by hr on 2017/12/18.
//  Copyright © 2017年 王腾飞. All rights reserved.
//

#import "DyGenerateThumbnails.h"
#import <UIKit/UIKit.h>
#import <CoreMedia/CoreMedia.h>

@interface DyGenerateThumbnails ()
@property (nonatomic, strong)AVAssetImageGenerator *imageGenerator;
@end

@implementation DyGenerateThumbnails

- (void)generateThumbnails:(AVAsset *)asset {
    
    //1. 创建一个AVAssetImageGenerator
    self.imageGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:asset];
    
    // 默认情况下, 捕捉的图片都是原始大小, 如果处理的是高清视频, 这会导致图片会非常大, 设置该属性是为了提高性能, 指定一个宽的值为200, 高度为0, 这样可以确保生成的图片都是按照一定的宽度, 并且会根据视频的宽高比自动设置高度的值
    self.imageGenerator.maximumSize = CGSizeMake(200.0f, 0.0f);
    
    //获取资源的全部时间
    CMTime duration = asset.duration;
    
    NSMutableArray *times = [NSMutableArray array];
    //将视频时间轴平均分成20个CMTime值, 步长
    //increment = 300
    CMTimeValue increment = duration.value / 20;
    
    //开始的时间, 开始循环遍历整个资源的时间点. 值为0则代表从资源的开头开始遍历
    CMTimeValue currentValue = 0;
    /*
     timescale到底代表什么喃？它表示1秒的时间被分成了多少份。因为整个CMTime的精度是由它控制的所以它显的尤为重要。当timescale为1000的时候，每秒钟便被分成了1000份，CMTime的value便代表了多少毫秒。
     */
    //2.0 * duration.timescale;
    
    // 循环遍历视频的duration, 获取21个时间段, times这个操作是用来计算生成CMTime值的集合, 这些值用来指定视频中的捕捉位置
    while (currentValue <= duration.value) {
        //创建一个新的时间
        CMTime time = CMTimeMake(currentValue, duration.timescale);
        NSLog(@"%lld", currentValue);
        [times addObject:[NSValue valueWithCMTime:time]];
        currentValue += increment;//300
    }
    
    //所以图片处理完成的时间
    __block NSUInteger imageCount = times.count;
    //用于保存生成的图片合集
    __block NSMutableArray *images = [NSMutableArray array];
    
    AVAssetImageGeneratorCompletionHandler handler = ^(CMTime requestedTime, //请求的最初时间, 它对应于生成图像的调用中指定的times数组中的值.
                                                       CGImageRef imageRef, //生成CGImageRef, 如果在给定的时间点没有生成图片则赋值NULL
                                                       CMTime actualTime, //图片实际生成的时间
                                                       AVAssetImageGeneratorResult result, //图片生成的状态, 成功或者失败
                                                       NSError *error) {
        
        if (result == AVAssetImageGeneratorSucceeded) {
            UIImage *image = [UIImage imageWithCGImage:imageRef];
            [images addObject:image];
        } else {
            NSLog(@"Error: %@", [error localizedDescription]);
        }
        
        // If the decremented image count is at 0, we're all done.
        if (--imageCount == 0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"%@", images);
            });
        }
    };
    
    [self.imageGenerator generateCGImagesAsynchronouslyForTimes:times
                                              completionHandler:handler];
    
    //    [self.imageGenerator generateCGImagesAsynchronouslyForTimes:times completionHandler:^(CMTime requestedTime, CGImageRef  _Nullable image, CMTime actualTime, AVAssetImageGeneratorResult result, NSError * _Nullable error) {
    //
    //    }];
}
@end
