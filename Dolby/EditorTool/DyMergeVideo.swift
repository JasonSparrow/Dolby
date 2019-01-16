//
//  DyMergeVideo.swift
//  Dolby
//
//  Created by hr on 2017/12/18.
//  Copyright © 2017年 王腾飞. All rights reserved.
//

import UIKit
import AVFoundation
import AssetsLibrary
import CoreMedia

/*
 合并视频
 */
class DyMergeVideo: NSObject {
    
    var firstAsset: AVAsset?
    var secondAsset: AVAsset?
    var audioAsset: AVAsset?
    var loadingAssetOne = false
    
    func merge() {
        
        if let firstAsset = firstAsset, let secondAsset = secondAsset {
            
            /*
             其中 AVMutableComposition 可以用来操作音频和视频的组合，AVMutableVideoComposition 可以用来对视频进行操作，AVMutableAudioMix 类是给视频添加音频的，AVMutableVideoCompositionInstruction和AVMutableVideoCompositionLayerInstruction 一般都是配合使用，用来给视频添加水印或者旋转视频方向，AVAssetExportSession 是用来进行视频导出操作的。
             */
            //1.1  - 创建AVMutableComposition对象。这个对象将保存你的AVMutableCompositionTrack实例。
            let mixComposition:AVMutableComposition = AVMutableComposition()
            
            //2.1  - 视频轨道
            //生成一个视轨道
            let firstTrack:AVMutableCompositionTrack = mixComposition.addMutableTrack(withMediaType: AVMediaType.video,
                                                                                      preferredTrackID: Int32(kCMPersistentTrackID_Invalid))!
            
            //2.2把视频资源插入到视频轨道里面
            do {
                try firstTrack.insertTimeRange(CMTimeRangeMake(start: CMTime.zero, duration: firstAsset.duration), //设置时间
                    of: firstAsset.tracks(withMediaType: AVMediaType.video)[0] , //获取视频轨道
                    at: CMTime.zero)
            } catch _ {
                print("Failed to load first track")
            }
            
            let secondTrack = mixComposition.addMutableTrack(withMediaType: AVMediaType.video,
                                                             preferredTrackID: Int32(kCMPersistentTrackID_Invalid))
            do {
                try secondTrack?.insertTimeRange(CMTimeRangeMake(start: CMTime.zero, duration: secondAsset.duration),
                                                 of: secondAsset.tracks(withMediaType: AVMediaType.video)[0] ,
                                                at: firstAsset.duration)
            } catch _ {
                print("Failed to load second track")
            }
            
            // 2.1
            //AVMutableVideoCompositionInstruction：一个指令，决定一个timeRange内每个轨道的状态，包含多个layerInstruction；
            let mainInstruction = AVMutableVideoCompositionInstruction()
            //设置时间
            mainInstruction.timeRange = CMTimeRangeMake(start: CMTime.zero, duration: CMTimeAdd(firstAsset.duration, secondAsset.duration))
            
            // 2.2
            //修正方向
            let firstInstruction = DyFixOrientation.videoCompositionInstructionForTrack(track: firstTrack, asset: firstAsset)
            firstInstruction.setOpacity(0.0, at: firstAsset.duration)
            let secondInstruction = DyFixOrientation.videoCompositionInstructionForTrack(track: secondTrack!, asset: secondAsset)
            
            // 2.3 设置修正之后的指令层
            mainInstruction.layerInstructions = [firstInstruction, secondInstruction]
            
            //AVMutableVideoComposition：用来生成video的组合指令，包含多段instruction。可以决定最终视频的尺寸，裁剪需要在这里进行；
            let mainComposition = AVMutableVideoComposition()
            mainComposition.instructions = [mainInstruction]
            //设置视频帧率为30帧
            mainComposition.frameDuration = CMTimeMake(value: 1, timescale: 30)
            mainComposition.renderSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
            
            
            // 3 -音轨
            if let loadedAudioAsset = audioAsset {
                let audioTrack = mixComposition.addMutableTrack(withMediaType: AVMediaType.audio, preferredTrackID: 0)
                do {
                    try audioTrack?.insertTimeRange(CMTimeRangeMake(start: CMTime.zero, duration: CMTimeAdd(firstAsset.duration, secondAsset.duration)),
                                                    of: loadedAudioAsset.tracks(withMediaType: AVMediaType.audio)[0] ,
                                                    at: CMTime.zero)
                } catch _ {
                    print("Failed to load audio track")
                }
            }
            
            // 4 -获取路径
            let url = DyExportURL.exportURL()
            
            // 5  - 创建导出器
            DyAssetExportSession.exportSession(url: url as URL, composition: mixComposition, videoComposition: mainComposition)
            
        }
    }
    

}


