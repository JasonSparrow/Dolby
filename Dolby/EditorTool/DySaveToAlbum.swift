//
//  DySaveToAlbum.swift
//  Dolby
//
//  Created by hr on 2017/12/20.
//  Copyright © 2017年 王腾飞. All rights reserved.
//

import UIKit
import AssetsLibrary

class DySaveToAlbum: NSObject {

    class func saveToAlbum(outputURL: URL) {
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
                print("\(title)\(message)")
            })
        }
    }
}
