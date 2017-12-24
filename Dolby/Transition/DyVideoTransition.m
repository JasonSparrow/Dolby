//
//  DyVideoTransition.m
//  Dolby
//
//  Created by hr on 2017/12/21.
//  Copyright © 2017年 王腾飞. All rights reserved.
//

#import "DyVideoTransition.h"
/*
 * OC 中使用Swift 必须要添加的头文件, 这个头文件是系统自动创建的, 只需引入即可. 
 */
#import "Dolby-Swift.h"

@interface DyVideoTransition()
{
    CMTime transitionDuration;
}
@property(nonatomic, strong)AVMutableComposition *composition;
@property(nonatomic, strong)NSArray <AVMutableCompositionTrack *>*compositionVideoTracks;
@property(nonatomic, strong)AVMutableVideoComposition *videoComposition;
@property(nonatomic, strong)NSArray <AVAsset *>*videoAssets;

@end

@implementation DyVideoTransition

- (instancetype)initWithAssets:(NSArray <AVAsset *>*)videoAssets
{
    self = [super init];
    if (self) {
        _videoAssets = videoAssets;
    }
    return self;
}

- (NSArray <AVMutableCompositionTrack *>*)getVideoTracks {
    //设置两个视频轨道
    self.composition = [AVMutableComposition composition];
    
    AVMutableCompositionTrack *trackA = [_composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    
    AVMutableCompositionTrack *trackB = [_composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    
    NSArray *compositionVideoTracks = @[trackA, trackB];
    return compositionVideoTracks;
}

- (NSArray <AVAsset *>*)setA_BTrack {
    self.compositionVideoTracks = [self getVideoTracks];
    /*
     这个方法是来设置A-B模式
     */
    
    NSArray *videoAssets = _videoAssets;
    
    CMTime cursorTime = kCMTimeZero;
    transitionDuration = CMTimeMake(3, 10);
    for (int i = 0; i < videoAssets.count; i++) {
        NSUInteger trackIndex = i % 2; //求余
        
        AVMutableCompositionTrack *currentTrack = _compositionVideoTracks[trackIndex];
        AVAsset *asset = videoAssets[i];
        AVAssetTrack *assetTrack = [asset tracksWithMediaType:AVMediaTypeVideo].firstObject;
        CMTimeRange timeRange = CMTimeRangeMake(kCMTimeZero, asset.duration);
        //timeRange 表示assetTrack所代表的资源的时间范围
        //assetTrack 资源的资源轨道
        //cursorTime 插入currentTrack的时间轴位置
        [currentTrack insertTimeRange:timeRange ofTrack:assetTrack atTime:cursorTime error:nil];
        cursorTime = CMTimeAdd(cursorTime, timeRange.duration);
        cursorTime = CMTimeSubtract(cursorTime, transitionDuration);
    }
    return videoAssets;
}

- (void)calculatePassAndTransition {
    NSArray *videoAssets = [self setA_BTrack];
    CMTime cursorTime = kCMTimeZero;
    
    //示例中组合的视频集进行了遍历, 对每个视频都创建了一个初始时间范围, 之后根据其原始位置, 对时间范围的起点和持续时间进行修改, 计算出cursorTime后, 基于cursorTime和transitionDuration创建相关的过渡时间范围
    NSMutableArray *passThroughTimeRanges = [NSMutableArray array];
    NSMutableArray *transitionTimeRanges = [NSMutableArray array];
    
    NSUInteger videoCount = [videoAssets count];
    
    for (int i = 0; i < videoCount; i++) {
        AVAsset *asset = videoAssets[i];
        
        //设置资源的时间轴区间
        CMTimeRange timeRange = CMTimeRangeMake(cursorTime, asset.duration);
        
        //第一个不计算
        if (i > 0) {
            timeRange.start = CMTimeAdd(timeRange.start, transitionDuration);
            timeRange.duration = CMTimeSubtract(timeRange.duration, transitionDuration);
        }
        
        //最后一个不计算
        if (i + 1 < videoCount) {
            //计算通过的范围
            timeRange.duration = CMTimeSubtract(timeRange.duration, transitionDuration);
        }
        
        //把通过的范围加入数组
        [passThroughTimeRanges addObject:[NSValue valueWithCMTimeRange:timeRange]];
        
        //获取下一个游标的范围
        cursorTime = CMTimeAdd(cursorTime, asset.duration);
        cursorTime = CMTimeSubtract(cursorTime, transitionDuration);
        
        if (i + 1 < videoCount) {
            //计算过渡的时间段
            timeRange = CMTimeRangeMake(cursorTime, transitionDuration);
            NSValue *timeRangeValue = [NSValue valueWithCMTimeRange:timeRange];
            //把过渡的时间段加入数组
            [transitionTimeRanges addObject:timeRangeValue];
        }
    }
    
    [self buildVideoCompositionAndInstructions:passThroughTimeRanges transition:transitionTimeRanges];
    
}

- (void)buildVideoCompositionAndInstructions:(NSArray *)passThroughTimeRanges transition:(NSArray *)transitionTimeRanges {
    
    //创建组合和指令图层
    NSMutableArray <AVMutableVideoCompositionInstruction *>*instructions = [NSMutableArray array];
    //查看composition资源的所有轨道, 有两个轨道, trackA和trackB
    //    NSArray *tracks = [_composition tracksWithMediaType:AVMediaTypeVideo];
    NSArray *videoTracks = _compositionVideoTracks;
    
    AVMutableVideoComposition *videoComposition = [AVMutableVideoComposition videoCompositionWithPropertiesOfAsset:_composition];
    
    
    CGFloat videoWidth = 0;
    CGFloat videoHeight = 0;
    CGAffineTransform transform;
    
    AVMutableCompositionTrack *track = videoTracks[0];
    CGFloat videoAngleInDegree  = atan2(track.preferredTransform.b, track.preferredTransform.a) * 180 / M_PI;
    if (videoAngleInDegree == 90) {
        videoWidth = _composition.naturalSize.height;
        videoHeight = _composition.naturalSize.width;
        CGAffineTransform tran = track.preferredTransform;
        transform = CGAffineTransformConcat(tran, CGAffineTransformMakeTranslation(videoWidth, 0.0));
    } else {
        videoWidth = _composition.naturalSize.width;
        videoHeight = _composition.naturalSize.height;
        transform = track.preferredTransform;
    }
    
    //1. 首先遍历之前计算的所有通过时间范围, 循环在两个需要创建所需指令的视频轨道间前后切换
    for (int i = 0; i < passThroughTimeRanges.count; i++) {
        //奇偶切换, 0, 1, 0, 1, etc
        NSUInteger trackIndex = i % 2;
        //获取对应的轨道
        AVMutableCompositionTrack *currentVideoTrack = videoTracks[trackIndex];
        
        //2. 创建一个新的AVMutableVideoCompositionInstruction实例, 设置当前通过的CMTimeRange为它的timeRange值
        AVMutableVideoCompositionInstruction *passThroughInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
        passThroughInstruction.timeRange = [passThroughTimeRanges[i] CMTimeRangeValue];
        
        //3. 为活动组合创建一个新的AVMutableVideoCompositionLayerInstruction, 将它添加到数组中, 并设置它作为组合指令的layerInstructions属性, 组合的通过时间范围区域只需要一个与要呈现视频的轨道相关的单独层指令
        AVMutableVideoCompositionLayerInstruction *passThroughLayerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:currentVideoTrack];
        

        [passThroughLayerInstruction setTransform:currentVideoTrack.preferredTransform atTime:kCMTimeZero];
        
        passThroughInstruction.layerInstructions = @[passThroughLayerInstruction];
        [instructions addObject:passThroughInstruction];
        
        if (i < transitionTimeRanges.count) {
            
            //4. 要创建过度时间范围指令, 需要得到前一个轨道的引用和后一个轨道的引用, 按这种方式查找轨道可以确保轨道的引用顺序始终正确
            AVCompositionTrack *foregroundTrack = videoTracks[trackIndex];
            AVCompositionTrack *backgroundTrack = videoTracks[1 - trackIndex];
            
            //5. 创建另一个AVMutableVideoCompositionInstruction实例, 设置当前过渡时间范围的CMTimeRange为它的timeRange值
            AVMutableVideoCompositionInstruction *transitionInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
            //过渡的时间范围
            CMTimeRange timeRange = [transitionTimeRanges[i] CMTimeRangeValue];
            transitionInstruction.timeRange = timeRange;
            
            //6. 为每一个轨道创建一个AVMutableVideoCompositionLayerInstruction实例, 在这些层指令上定义从一个场景到另一个场景的过渡效果, 本利中没有使用过渡效果, 在后面的示例中使用了.
            AVMutableVideoCompositionLayerInstruction *fromLayerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:foregroundTrack];
            [fromLayerInstruction setTransform:foregroundTrack.preferredTransform atTime:kCMTimeZero];
            
            AVMutableVideoCompositionLayerInstruction *toLayerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:backgroundTrack];
            
            [toLayerInstruction setTransform:backgroundTrack.preferredTransform atTime:kCMTimeZero];
            
            
            //--------------------------
            // Define starting and ending transforms                        // 1
            CGAffineTransform identityTransform = CGAffineTransformIdentity;

            CGFloat videoWidth = videoComposition.renderSize.width;

            CGAffineTransform fromDestTransform =                           // 2
            CGAffineTransformMakeTranslation(-videoWidth, 0.0);

            CGAffineTransform toStartTransform =
            CGAffineTransformMakeTranslation(videoWidth, 0.0);

            [fromLayerInstruction setTransformRampFromStartTransform:identityTransform // 3
                                           toEndTransform:fromDestTransform
                                                timeRange:timeRange];

            [toLayerInstruction setTransformRampFromStartTransform:toStartTransform    // 4
                                         toEndTransform:identityTransform
                                              timeRange:timeRange];
            //--------------------------
            
            
            //7. 将两个层指令都添加到数组中, 并设置他们作为当前组合指令的layerInstructions属性值, 对这一数组中的元素排序非常重要, 因为它定义了组合输出中视频图层的Z轴顺序
            transitionInstruction.layerInstructions = @[fromLayerInstruction, toLayerInstruction];
            
            [instructions addObject:transitionInstruction];
            
        }
    }
    
    videoComposition.instructions = instructions;
    videoComposition.renderSize = CGSizeMake(videoWidth, videoHeight);
    videoComposition.frameDuration = CMTimeMake(1, 30);
    videoComposition.renderScale = 1.0f;
    
    _videoComposition = videoComposition;
    
    
}

- (AVPlayerItem *)makePlayable {
    [self calculatePassAndTransition];
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:[_composition copy]];
    playerItem.videoComposition = _videoComposition;
    return playerItem;
}

@end
