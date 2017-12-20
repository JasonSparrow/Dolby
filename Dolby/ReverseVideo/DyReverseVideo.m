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
    NSMutableArray *sampleBuffer = [[NSMutableArray alloc] init];
    
    
    //int count = 0;
    while(1) {
        CMSampleBufferRef sample = [readerOutput copyNextSampleBuffer];
        
        if (sample == NULL) {
            break;
        }
        //NSLog(@"取样本 = %d", count++);
        [sampleBuffer addObject:(__bridge id)sample];
        CFRelease(sample);
        
    }
    
    // 初始化AVAssetWriter
    AVAssetWriter *writer = [[AVAssetWriter alloc] initWithURL:outputURL
                                                      fileType:AVFileTypeQuickTimeMovie
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
    
    
    //下面翻转并保存文件
    // 我们创建一个AVAssetWriterInputPixelBufferAdaptor对象作为写入器输入的适配器。这将允许输入读入每帧的像素缓冲区。
    AVAssetWriterInputPixelBufferAdaptor *pixelBufferAdaptor = [[AVAssetWriterInputPixelBufferAdaptor alloc] initWithAssetWriterInput:writerInput sourcePixelBufferAttributes:nil];
    
    
    [writer addInput:writerInput];
    [writer startWriting];
    //创建一个新的写入回话, 参数为资源样本开始的时间
    [writer startSessionAtSourceTime:CMSampleBufferGetPresentationTimeStamp((__bridge CMSampleBufferRef)sampleBuffer[0])];
    
    //每个样本（CMSampleBufferRef）的结构都包含两个关键信息。CVPixelBufferRef描述帧的像素数据的像素缓冲器（），以及描述何时显示的显示时间戳。
    // Append the frames to the output.
    // Notice we append the frames from the tail end, using the timing of the frames from the front.
    for(NSInteger i = 0; i < sampleBuffer.count; i++) {
        
        // 获取帧显示的时间范围
        CMTime presentationTime = CMSampleBufferGetPresentationTimeStamp((__bridge CMSampleBufferRef)sampleBuffer[i]);
        
        // 从数组的尾部获取 image/pixel buffer
        CVPixelBufferRef imageBufferRef = CMSampleBufferGetImageBuffer((__bridge CMSampleBufferRef)sampleBuffer[sampleBuffer.count - i - 1]);
        
        while (!writerInput.isReadyForMoreMediaData) {
            [NSThread sleepForTimeInterval:0.1];
        }
        
        [pixelBufferAdaptor appendPixelBuffer:imageBufferRef withPresentationTime:presentationTime];
        //NSLog(@"倒转 = %ld", (long)i);
    }
    
    [writer finishWritingWithCompletionHandler:^{
        
    }];
    
    return [AVAsset assetWithURL:outputURL];
}
    
    
+ (AVAsset *)assetByReversingAsset1:(AVAsset *)asset outputURL:(NSURL *)outputURL {
    NSURL *tmpFileURL = outputURL;
    NSError *error;
    
    // initialize the AVAssetReader that will read the input asset track
    AVAssetReader *reader = [[AVAssetReader alloc] initWithAsset:asset error:&error];
    AVAssetTrack *videoTrack = [[asset tracksWithMediaType:AVMediaTypeVideo] lastObject];
    
    AVAssetReaderTrackOutput* readerOutput = [AVAssetReaderTrackOutput assetReaderTrackOutputWithTrack:videoTrack outputSettings:nil];
    [reader addOutput:readerOutput];
    [reader startReading];
    
    // Read in the samples into an array
    NSMutableArray *samples = [[NSMutableArray alloc] init];
    
    int count = 0;
    while(1) {
        CMSampleBufferRef sample = [readerOutput copyNextSampleBuffer];
        
        if (sample == NULL) {
            break;
        }
        NSLog(@"%d", count++);
        [samples addObject:(__bridge id)sample];
        CFRelease(sample);
        
    }
    
    // initialize the the writer that will save to our temporary file.
    CMFormatDescriptionRef formatDescription = CFBridgingRetain([videoTrack.formatDescriptions lastObject]);
    AVAssetWriterInput *writerInput = [[AVAssetWriterInput alloc] initWithMediaType:AVMediaTypeVideo outputSettings:nil sourceFormatHint:formatDescription];
    CFRelease(formatDescription);
    
    AVAssetWriter *writer = [[AVAssetWriter alloc] initWithURL:tmpFileURL
                                                      fileType:AVFileTypeMPEG4
                                                         error:&error];
    [writerInput setExpectsMediaDataInRealTime:NO];
    [writer addInput:writerInput];
    [writer startSessionAtSourceTime:CMSampleBufferGetPresentationTimeStamp((__bridge CMSampleBufferRef)samples[0])];
    [writer startWriting];
    
    
    // Traverse the sample frames in reverse order
    for(NSInteger i = samples.count-1; i >= 0; i--) {
        CMSampleBufferRef sample = (__bridge CMSampleBufferRef)samples[i];
        
        // Since the timing information is built into the CMSampleBufferRef
        // We will need to make a copy of it with new timing info. Will copy
        // the timing data from the mirror frame at samples[samples.count - i -1]
        
        CMItemCount numSampleTimingEntries;
        CMSampleBufferGetSampleTimingInfoArray((CMSampleBufferRef)samples[samples.count - i -1], 0, nil, &numSampleTimingEntries);
        CMSampleTimingInfo *timingInfo = malloc(sizeof(CMSampleTimingInfo) * numSampleTimingEntries);
        CMSampleBufferGetSampleTimingInfoArray((CMSampleBufferRef)sample, numSampleTimingEntries, timingInfo, &numSampleTimingEntries);
        
        CMSampleBufferRef sampleWithCorrectTiming;
        CMSampleBufferCreateCopyWithNewTiming(
                                              kCFAllocatorDefault,
                                              sample,
                                              numSampleTimingEntries,
                                              timingInfo,
                                              &sampleWithCorrectTiming);
        
        if (writerInput.readyForMoreMediaData)  {
            [writerInput appendSampleBuffer:sampleWithCorrectTiming];
        }
        
        CFRelease(sampleWithCorrectTiming);
        free(timingInfo);
    }
    
    [writer finishWritingWithCompletionHandler:^{
        
    }];
    
    return [AVAsset assetWithURL:tmpFileURL];
}
@end
