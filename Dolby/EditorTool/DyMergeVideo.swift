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
            
            
            //1.1  - 创建AVMutableComposition对象。这个对象将保存你的AVMutableCompositionTrack实例。
            let mixComposition:AVMutableComposition = AVMutableComposition()
            
            //2.1  - 视频轨道
            //生成一个视轨道
            let firstTrack:AVMutableCompositionTrack = mixComposition.addMutableTrack(withMediaType: AVMediaType.video,
                                                                                      preferredTrackID: Int32(kCMPersistentTrackID_Invalid))!
            
            
            //2.2把视频资源插入到视频轨道里面
            do {
                try firstTrack.insertTimeRange(CMTimeRangeMake(kCMTimeZero, firstAsset.duration), //设置时间
                    of: firstAsset.tracks(withMediaType: AVMediaType.video)[0] , //获取视频轨道
                    at: kCMTimeZero)
            } catch _ {
                print("Failed to load first track")
            }
            
            let secondTrack = mixComposition.addMutableTrack(withMediaType: AVMediaType.video,
                                                             preferredTrackID: Int32(kCMPersistentTrackID_Invalid))
            do {
                try secondTrack?.insertTimeRange(CMTimeRangeMake(kCMTimeZero, secondAsset.duration),
                                                 of: secondAsset.tracks(withMediaType: AVMediaType.video)[0] ,
                                                at: firstAsset.duration)
            } catch _ {
                print("Failed to load second track")
            }
            
            // 2.1
            //AVMutableVideoCompositionInstruction：一个指令，决定一个timeRange内每个轨道的状态，包含多个layerInstruction；
            let mainInstruction = AVMutableVideoCompositionInstruction()
            //设置时间
            mainInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, CMTimeAdd(firstAsset.duration, secondAsset.duration))
            
            // 2.2
            let firstInstruction = videoCompositionInstructionForTrack(track: firstTrack, asset: firstAsset)
            firstInstruction.setOpacity(0.0, at: firstAsset.duration)
            let secondInstruction = videoCompositionInstructionForTrack(track: secondTrack!, asset: secondAsset)
            
            // 2.3
            mainInstruction.layerInstructions = [firstInstruction, secondInstruction]
            //AVMutableVideoComposition：用来生成video的组合指令，包含多段instruction。可以决定最终视频的尺寸，裁剪需要在这里进行；
            let mainComposition = AVMutableVideoComposition()
            mainComposition.instructions = [mainInstruction]
            //设置视频帧率为30帧
            mainComposition.frameDuration = CMTimeMake(1, 30)
            mainComposition.renderSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
            
            // 3 -音轨
            if let loadedAudioAsset = audioAsset {
                let audioTrack = mixComposition.addMutableTrack(withMediaType: AVMediaType.audio, preferredTrackID: 0)
                do {
                    try audioTrack?.insertTimeRange(CMTimeRangeMake(kCMTimeZero, CMTimeAdd(firstAsset.duration, secondAsset.duration)),
                                                    of: loadedAudioAsset.tracks(withMediaType: AVMediaType.audio)[0] ,
                                                   at: kCMTimeZero)
                } catch _ {
                    print("Failed to load audio track")
                }
                
            }
            
            // 4 -获取路径
            let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .long
            dateFormatter.timeStyle = .short
            let date = dateFormatter.string(from: Date())
            let savePath = (documentDirectory as NSString).appendingPathComponent("mergeVideo-\(date).mov")
            let url = NSURL(fileURLWithPath: savePath)
            
            // 5  - 创建导出器
            guard let exporter = AVAssetExportSession(asset: mixComposition, presetName: AVAssetExportPresetHighestQuality) else {
                return
            }
            exporter.outputURL = url as URL
            exporter.outputFileType = AVFileType.mov
            exporter.shouldOptimizeForNetworkUse = true
            exporter.videoComposition = mainComposition
            
            // 6  - 执行导出
            exporter.exportAsynchronously(completionHandler: {
                DispatchQueue.main.async(execute: {
                    self.exportDidFinish(session: exporter)
                })
            })
        }
    }
    
    
    func orientationFromTransform(transform: CGAffineTransform) -> (orientation: UIImageOrientation, isPortrait: Bool) {
        var assetOrientation = UIImageOrientation.up
        var isPortrait = false
        if transform.a == 0 && transform.b == 1.0 && transform.c == -1.0 && transform.d == 0 {
            assetOrientation = .right
            isPortrait = true
        } else if transform.a == 0 && transform.b == -1.0 && transform.c == 1.0 && transform.d == 0 {
            assetOrientation = .left
            isPortrait = true
        } else if transform.a == 1.0 && transform.b == 0 && transform.c == 0 && transform.d == 1.0 {
            assetOrientation = .up
        } else if transform.a == -1.0 && transform.b == 0 && transform.c == 0 && transform.d == -1.0 {
            assetOrientation = .down
        }
        return (assetOrientation, isPortrait)
    }
    
    func videoCompositionInstructionForTrack(track: AVCompositionTrack, asset: AVAsset) -> AVMutableVideoCompositionLayerInstruction {
        let instruction = AVMutableVideoCompositionLayerInstruction(assetTrack: track)
        let assetTrack = asset.tracks(withMediaType: AVMediaType.video)[0]
        
        let transform = assetTrack.preferredTransform
        let assetInfo = orientationFromTransform(transform: transform)
        
        var scaleToFitRatio = UIScreen.main.bounds.width / assetTrack.naturalSize.width
        if assetInfo.isPortrait {
            scaleToFitRatio = UIScreen.main.bounds.width / assetTrack.naturalSize.height
            let scaleFactor = CGAffineTransform(scaleX: scaleToFitRatio, y: scaleToFitRatio)
            instruction.setTransform(assetTrack.preferredTransform.concatenating(scaleFactor),
                                     at: kCMTimeZero)
        } else {
            let scaleFactor = CGAffineTransform(scaleX: scaleToFitRatio, y: scaleToFitRatio)
            var concat = assetTrack.preferredTransform.concatenating(scaleFactor).concatenating(CGAffineTransform(translationX: 0, y: UIScreen.main.bounds.width / 2))
            if assetInfo.orientation == .down {
                let fixUpsideDown = CGAffineTransform(rotationAngle: CGFloat(Double.pi))
                let windowBounds = UIScreen.main.bounds
                let yFix = assetTrack.naturalSize.height + windowBounds.height
                let centerFix = CGAffineTransform(translationX: assetTrack.naturalSize.width, y: yFix)
                concat = fixUpsideDown.concatenating(centerFix).concatenating(scaleFactor)
            }
            instruction.setTransform(concat, at: kCMTimeZero)
        }
        return instruction
    }
   
    
    func exportDidFinish(session: AVAssetExportSession) {
        if session.status == AVAssetExportSessionStatus.completed {
            let outputURL = session.outputURL
            let library = ALAssetsLibrary()
            if library.videoAtPathIs(compatibleWithSavedPhotosAlbum: outputURL) {
                library.writeVideoAtPath(toSavedPhotosAlbum: outputURL, completionBlock: { (assetURL, error) in
                    var title = ""
                    var message = ""
                    if error != nil {
                        title = "Error"
                        message = "Failed to save video"
                    } else {
                        title = "Success"
                        message = "Video saved"
                    }
                    
                    print("\(title) = \(message)")
                })
            }
        }
        
        firstAsset = nil
        secondAsset = nil
        audioAsset = nil
    }
}


