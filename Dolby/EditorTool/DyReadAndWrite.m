//
//  DyReadAndWrite.m
//  Dolby
//
//  Created by hr on 2017/12/18.
//  Copyright © 2017年 王腾飞. All rights reserved.
//

#import "DyReadAndWrite.h"
#import <AVFoundation/AVFoundation.h>

@interface DyReadAndWrite ()
@property (nonatomic, strong)AVAssetReader *assetReader;
@property (nonatomic, strong)AVAssetWriter *assetWriter;
@end

@implementation DyReadAndWrite

- (void)read {
    NSURL *assetURL = [[NSBundle mainBundle] URLForResource:@"IMG_3692" withExtension:@"m4v"];
    AVAsset *asset = [AVAsset assetWithURL:assetURL];
    /*
     * 配置 AVAssetReader
     */
    //设置视频资源轨道
    AVAssetTrack * track = [asset tracksWithMediaType:AVMediaTypeVideo].firstObject;
    self.assetReader = [[AVAssetReader alloc] initWithAsset:asset error:nil];
    //将视频帧解压缩为BGRA格式
    NSDictionary *readerOutputSettings = @{(id)kCVPixelBufferPixelFormatTypeKey:@(kCVPixelFormatType_32BGRA)};
    //从视频的资源轨道中读取样本
    AVAssetReaderTrackOutput *trackOutput = [[AVAssetReaderTrackOutput alloc] initWithTrack:track outputSettings:readerOutputSettings];
    //添加到读取器
    [self.assetReader addOutput:trackOutput];
    //开始读取
    [self.assetReader startReading];
    
   
}
    
- (void)write:(AVAssetReaderTrackOutput *)trackOutput {
    
    /*
     * 配置 AVAssetWriter
     */
    NSURL *outputURL = [NSURL URLWithString:@""];
    self.assetWriter = [[AVAssetWriter alloc] initWithURL:outputURL fileType:AVFileTypeQuickTimeMovie error:nil];
    
    NSDictionary *writerOutputSettings = @{
                                           AVVideoCodecKey:AVVideoCodecH264,
                                           AVVideoWidthKey:@1280,
                                           AVVideoHeightKey:@720,
                                           AVVideoCompressionPropertiesKey:@{
                                                   AVVideoMaxKeyFrameIntervalKey:@1,
                                                   AVVideoAverageBitRateKey:@10500000,
                                                   AVVideoProfileLevelKey:AVVideoProfileLevelH264Main31
                                                   }
                                           };
    AVAssetWriterInput *writerInput = [[AVAssetWriterInput alloc] initWithMediaType:AVMediaTypeVideo outputSettings:writerOutputSettings
                                       ];
    [self.assetWriter addInput:writerInput];
    [self.assetWriter startWriting];
    //创建一个新的写入回话, 传递kCMTimeZero参数作为资源样本开始的时间
    [self.assetWriter startSessionAtSourceTime:kCMTimeZero];
    
    
    // serial queue
    dispatch_queue_t dispatchQueue = dispatch_queue_create("com.tap.write", NULL);
    //请求读取
    [writerInput requestMediaDataWhenReadyOnQueue:dispatchQueue usingBlock:^{
        BOOL complete = NO;
        while ([writerInput isReadyForMoreMediaData] && !complete) {
            CMSampleBufferRef sampleBuffer = [trackOutput copyNextSampleBuffer];
            if (sampleBuffer) {
                BOOL result = [writerInput appendSampleBuffer:sampleBuffer];
                CFRelease(sampleBuffer);
                complete = !result;
            }else {
                [writerInput markAsFinished];
                complete = YES;
            }
        }
        if (complete) {
            [self.assetWriter finishWritingWithCompletionHandler:^{
                AVAssetWriterStatus status = self.assetWriter.status;
                if (status == AVAssetWriterStatusCompleted) {
                    //处理成功
                }else {
                    //处理失败
                }
            }];
        }
    }];
}
@end
