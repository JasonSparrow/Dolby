//
//  DyReverseVideo.m
//  Dolby
//
//  Created by hr on 2017/12/19.
//  Copyright © 2017年 王腾飞. All rights reserved.
//

#import "DyReverseVideo.h"

@implementation DyReverseVideo
+ (AVAsset *)assetByReversingAsset:(AVAsset *)asset outputURL:(NSURL *)outputURL {
    NSError *error;
    
    // 初始化AVAssetReader
    AVAssetReader *reader = [[AVAssetReader alloc] initWithAsset:asset error:&error];
    AVAssetTrack *videoTrack = [[asset tracksWithMediaType:AVMediaTypeVideo] lastObject];
    
    NSDictionary *readerOutputSettings = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:kCVPixelFormatType_420YpCbCr8BiPlanarFullRange], kCVPixelBufferPixelFormatTypeKey, nil];
    AVAssetReaderTrackOutput* readerOutput = [AVAssetReaderTrackOutput assetReaderTrackOutputWithTrack:videoTrack
                                                                                        outputSettings:readerOutputSettings];
    [reader addOutput:readerOutput];
    [reader startReading];
    
    // 读取样本数据
    NSMutableArray *samples = [[NSMutableArray alloc] init];
    
    CMSampleBufferRef sample = [readerOutput copyNextSampleBuffer];
    
    int count = 0;
    while(sample) {
        [samples addObject:(__bridge id)sample];
        CFRelease(sample);
//        NSLog(@"%d", count++);
    }
    
    // 初始化AVAssetWriter
    AVAssetWriter *writer = [[AVAssetWriter alloc] initWithURL:outputURL
                                                      fileType:AVFileTypeMPEG4
                                                         error:&error];
    NSDictionary *videoCompressionProps = [NSDictionary dictionaryWithObjectsAndKeys:
                                           @(videoTrack.estimatedDataRate), AVVideoAverageBitRateKey,
                                           nil];
    NSDictionary *writerOutputSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                          AVVideoCodecH264, AVVideoCodecKey,
                                          [NSNumber numberWithInt:videoTrack.naturalSize.width], AVVideoWidthKey,
                                          [NSNumber numberWithInt:videoTrack.naturalSize.height], AVVideoHeightKey,
                                          videoCompressionProps, AVVideoCompressionPropertiesKey,
                                          nil];
    AVAssetWriterInput *writerInput = [[AVAssetWriterInput alloc] initWithMediaType:AVMediaTypeVideo
                                                                     outputSettings:writerOutputSettings
                                                                   sourceFormatHint:(__bridge CMFormatDescriptionRef)[videoTrack.formatDescriptions lastObject]];
    //如果数据源是时时的, 需要设置为YES, 例如从摄像机获取数据, 否则设置为NO
    [writerInput setExpectsMediaDataInRealTime:NO];
    
    [writer addInput:writerInput];
    [writer startWriting];
    //创建一个新的写入回话, 参数为资源样本开始的时间
    [writer startSessionAtSourceTime:CMSampleBufferGetPresentationTimeStamp((__bridge CMSampleBufferRef)samples[0])];
    
    //下面翻转并保存文件
    // 我们创建一个AVAssetWriterInputPixelBufferAdaptor对象作为写入器输入的适配器。这将允许输入读入每帧的像素缓冲区。
    AVAssetWriterInputPixelBufferAdaptor *pixelBufferAdaptor = [[AVAssetWriterInputPixelBufferAdaptor alloc] initWithAssetWriterInput:writerInput sourcePixelBufferAttributes:nil];
    
    //每个样本（CMSampleBufferRef）的结构都包含两个关键信息。CVPixelBufferRef描述帧的像素数据的像素缓冲器（），以及描述何时显示的显示时间戳。
    // Append the frames to the output.
    // Notice we append the frames from the tail end, using the timing of the frames from the front.
    for(NSInteger i = 0; i < samples.count; i++) {
        
        // 获取帧显示的时间范围
        CMTime presentationTime = CMSampleBufferGetPresentationTimeStamp((__bridge CMSampleBufferRef)samples[i]);
        
        // 从数组的尾部获取 image/pixel buffer
        CVPixelBufferRef imageBufferRef = CMSampleBufferGetImageBuffer((__bridge CMSampleBufferRef)samples[samples.count - i - 1]);
        
        while (!writerInput.isReadyForMoreMediaData) {
            [NSThread sleepForTimeInterval:0.1];
        }
        
        [pixelBufferAdaptor appendPixelBuffer:imageBufferRef withPresentationTime:presentationTime];
        
    }
    
    [writer finishWritingWithCompletionHandler:^{
        
    }];
    
    return [AVAsset assetWithURL:outputURL];
}
@end
