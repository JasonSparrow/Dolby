//
//  DyAssetExportSession.swift
//  Dolby
//
//  Created by hr on 2017/12/18.
//  Copyright © 2017年 王腾飞. All rights reserved.
//

import UIKit
import AVFoundation
import AssetsLibrary

class DyAssetExportSession: NSObject {
    
   
    class func exportSession(url:URL, mixComposition:AVMutableComposition, mainComposition:AVMutableVideoComposition) {
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
                DyAssetExportSession.exportDidFinish(session: exporter)
            })
        })
    }
    
    class func exportDidFinish(session: AVAssetExportSession) {
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
    }
  
}
