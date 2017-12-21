//
//  DyStopViewController.m
//  Dolby
//
//  Created by hr on 2017/12/20.
//  Copyright © 2017年 王腾飞. All rights reserved.
//

#import "DyStopViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>
#import <MediaPlayer/MediaPlayer.h>

@interface DyStopViewController ()
@property(nonatomic, strong)NSMutableArray *imageArr;
@property(nonatomic, strong)NSString  *theVideoPath;
@end

@implementation DyStopViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.imageArr =[[NSMutableArray alloc]initWithObjects:
                    [UIImage imageNamed:@"1.jpg"],[UIImage imageNamed:@"2.jpg"],[UIImage imageNamed:@"3.jpg"],[UIImage imageNamed:@"1.jpg"],[UIImage imageNamed:@"2.jpg"],[UIImage imageNamed:@"3.jpg"],[UIImage imageNamed:@"1.jpg"],[UIImage imageNamed:@"2.jpg"],[UIImage imageNamed:@"3.jpg"],[UIImage imageNamed:@"1.jpg"],[UIImage imageNamed:@"2.jpg"],[UIImage imageNamed:@"3.jpg"],[UIImage imageNamed:@"1.jpg"],[UIImage imageNamed:@"2.jpg"],[UIImage imageNamed:@"3.jpg"],[UIImage imageNamed:@"1.jpg"],[UIImage imageNamed:@"2.jpg"],[UIImage imageNamed:@"3.jpg"],nil];
    
    UIButton * button =[UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button setFrame:CGRectMake(100,100, 100,100)];
    [button setTitle:@"合成"forState:UIControlStateNormal];
    [button addTarget:self action:@selector(testCompressionSession)forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    UIButton * button1 =[UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button1 setFrame:CGRectMake(100,200, 100,100)];
    [button1 setTitle:@"播放"forState:UIControlStateNormal];
    [button1 addTarget:self action:@selector(playAction)forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button1];
    // Do any additional setup after loading the view, typically from a nib.
    
    
}
    
-(void)testCompressionSession {
    
    NSLog(@"开始");
    
    NSArray *paths =NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    self.theVideoPath =[[paths objectAtIndex:0]stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mp4",@"2016全球三大超跑宣传片_超清"]];
    
    //定义视频的大小
    CGSize size =CGSizeMake(320,400);
    //[self writeImages:_imageArr ToMovieAtPath:moviePath withSize:size  inDuration:4 byFPS:30];//第2中方法
    
    NSError *error = nil;
    NSLog(@"path->%@",_theVideoPath);
    
    //—-initialize compression engine
    AVAssetWriter *videoWriter =[[AVAssetWriter alloc] initWithURL:[NSURL fileURLWithPath:_theVideoPath] fileType:AVFileTypeQuickTimeMovie error:&error];
    
    NSParameterAssert(videoWriter);
    NSLog(@"error =%@", [error localizedDescription]);

    NSDictionary *videoSettings =[NSDictionary dictionaryWithObjectsAndKeys:AVVideoCodecH264,AVVideoCodecKey,
                                  [NSNumber numberWithInt:size.width],AVVideoWidthKey,
                                  [NSNumber numberWithInt:size.height],AVVideoHeightKey,nil];
    
    AVAssetWriterInput *writerInput =[AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:videoSettings];
    NSDictionary*sourcePixelBufferAttributesDictionary =[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:kCVPixelFormatType_32ARGB],kCVPixelBufferPixelFormatTypeKey,nil];
    
    AVAssetWriterInputPixelBufferAdaptor *adaptor =[AVAssetWriterInputPixelBufferAdaptor assetWriterInputPixelBufferAdaptorWithAssetWriterInput:writerInput sourcePixelBufferAttributes:sourcePixelBufferAttributesDictionary];
    
    [videoWriter addInput:writerInput];
    [videoWriter startWriting];
    [videoWriter startSessionAtSourceTime:kCMTimeZero];

    //合成多张图片为一个视频文件
    dispatch_queue_t dispatchQueue =dispatch_queue_create("mediaInputQueue",NULL);
    
    int __block frame = 0;
    [writerInput requestMediaDataWhenReadyOnQueue:dispatchQueue usingBlock:^{
        while([writerInput isReadyForMoreMediaData]) {
            if(++frame >=[self.imageArr count]*10) {
                [writerInput markAsFinished];
                [videoWriter finishWritingWithCompletionHandler:^{
                    
                }];
                break;
            }
            int idx =frame/10;
            NSLog(@"idx==%d",idx);
            CVPixelBufferRef buffer =(CVPixelBufferRef)[self pixelBufferFromCGImage:[[self.imageArr objectAtIndex:idx]CGImage]size:size];
            if (buffer){
                //
                if(![adaptor appendPixelBuffer:buffer withPresentationTime:CMTimeMake(frame,10)]) {
                    NSLog(@"FAIL");
                }else {
                    NSLog(@"OK");
                }
                CFRelease(buffer);
            }
        }
    }];
}
    
- (CVPixelBufferRef)pixelBufferFromCGImage:(CGImageRef)image size:(CGSize)size{
    
    NSDictionary *options =[NSDictionary dictionaryWithObjectsAndKeys:
                            
                            [NSNumber numberWithBool:YES],kCVPixelBufferCGImageCompatibilityKey,
                            
                            [NSNumber numberWithBool:YES],kCVPixelBufferCGBitmapContextCompatibilityKey,nil];
    
    CVPixelBufferRef pxbuffer =NULL;
    
    CVReturn status =CVPixelBufferCreate(kCFAllocatorDefault,size.width,size.height,kCVPixelFormatType_32ARGB,(__bridge CFDictionaryRef) options,&pxbuffer);
    
    NSParameterAssert(status ==kCVReturnSuccess && pxbuffer !=NULL);
    
    CVPixelBufferLockBaseAddress(pxbuffer,0);
    
    void *pxdata =CVPixelBufferGetBaseAddress(pxbuffer);
    
    NSParameterAssert(pxdata !=NULL);
    
    CGColorSpaceRef rgbColorSpace=CGColorSpaceCreateDeviceRGB();
    
    CGContextRef context =CGBitmapContextCreate(pxdata,size.width,size.height,8,4*size.width,rgbColorSpace,kCGImageAlphaPremultipliedFirst);
    
    NSParameterAssert(context);
    
    CGContextDrawImage(context,CGRectMake(0,0,CGImageGetWidth(image),CGImageGetHeight(image)), image);
    
    CGColorSpaceRelease(rgbColorSpace);
    
    CGContextRelease(context);
    
    CVPixelBufferUnlockBaseAddress(pxbuffer,0);
    
    return pxbuffer;}
    
-(void)playAction{
    
    MPMoviePlayerViewController *theMovie =[[MPMoviePlayerViewController alloc]initWithContentURL:[NSURL fileURLWithPath:self.theVideoPath]];
    
    [self presentMoviePlayerViewControllerAnimated:theMovie];
    
    theMovie.moviePlayer.movieSourceType=MPMovieSourceTypeFile;[theMovie.moviePlayer play];
    
}
    
//第二种方式    
- (void)writeImages:(NSArray *)imagesArray ToMovieAtPath:(NSString *)path withSize:(CGSize)size inDuration:(float)duration byFPS:(int32_t)fps{
    
    //Wire the writer:
    
    NSError *error =nil;
    
    AVAssetWriter *videoWriter =[[AVAssetWriter alloc]initWithURL:[NSURL fileURLWithPath:path]fileType:AVFileTypeQuickTimeMovie error:&error];
    
    NSParameterAssert(videoWriter);
    
    NSDictionary *videoSettings =[NSDictionary dictionaryWithObjectsAndKeys:
                                  
                                  AVVideoCodecH264,AVVideoCodecKey,
                                  
                                  [NSNumber numberWithInt:size.width],AVVideoWidthKey,
                                  
                                  [NSNumber numberWithInt:size.height],AVVideoHeightKey,nil];
    
    AVAssetWriterInput* videoWriterInput =[AVAssetWriterInput
                                           
                                           assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:videoSettings];
    
    AVAssetWriterInputPixelBufferAdaptor *adaptor =[AVAssetWriterInputPixelBufferAdaptor assetWriterInputPixelBufferAdaptorWithAssetWriterInput:videoWriterInput sourcePixelBufferAttributes:nil];
    
    NSParameterAssert(videoWriterInput);
    
    NSParameterAssert([videoWriter canAddInput:videoWriterInput]);
    
    [videoWriter addInput:videoWriterInput];
    
    //Start a session:
    
    [videoWriter startWriting];
    
    [videoWriter startSessionAtSourceTime:kCMTimeZero];
    
    //Write some samples:
    
    CVPixelBufferRef buffer =NULL;
    
    int frameCount =0;
    
    int imagesCount = (int)imagesArray.count;
    
    float averageTime =duration/imagesCount;
    
    int averageFrame =(int)(averageTime * fps);
    
    for(UIImage *img in imagesArray){
        
        buffer=[self pixelBufferFromCGImage:[img CGImage]size:size];
        
        BOOL append_ok =NO;
        
        int j =0;
        
        while (!append_ok && j <= 30)
        
        {
            
            if(adaptor.assetWriterInput.readyForMoreMediaData)
            
            {
                
                printf("appending %d attemp%d\n", frameCount, j);
                
                CMTime frameTime =CMTimeMake(frameCount,(int32_t)fps);float frameSeconds =CMTimeGetSeconds(frameTime);
                
                NSLog(@"frameCount:%d,kRecordingFPS:%d,frameSeconds:%f",frameCount,fps,frameSeconds);
                
                append_ok = [adaptor appendPixelBuffer:buffer withPresentationTime:frameTime];
                
                if(buffer)
                
                [NSThread sleepForTimeInterval:0.05];}else{
                    
                    printf("adaptor not ready %d,%d\n", frameCount, j);
                    
                    [NSThread sleepForTimeInterval:0.1];}
            
            j++;}
        
        if (!append_ok){
            
            printf("error appendingimage %d times %d\n", frameCount, j);}
        
        frameCount = frameCount + averageFrame;}
    
    //Finish the session:
    
    [videoWriterInput markAsFinished];
    
    [videoWriter finishWritingWithCompletionHandler:^{
        
    }];
    NSLog(@"finishWriting");
    
}
    
   
@end
