//
//  DyReverseViewController.swift
//  Dolby
//
//  Created by hr on 2017/12/19.
//  Copyright © 2017年 王腾飞. All rights reserved.
//

import UIKit
import AVKit

class DyReverseViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        
        let url = Bundle.main.url(forResource: "input", withExtension: "mov")
        let asset = AVAsset(url: url!)
        
        let date = Date()
        print("开始 - \(Date())")
        DyReverseVideo.asset(byReversing: asset, outputURL: DyExportURL.exportURL() as URL) { (asset) in

            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
                
//                DySaveToAlbum.saveToAlbum(outputURL: DyExportURL.exportURL() as URL)
                let playItem = AVPlayerItem(asset: asset!)
                let play = AVPlayer(playerItem: playItem)
                let player = AVPlayerViewController.init()
                player.player = play
                self.present(player, animated: true, completion: {
                    
                })
            }
        }
        print("结束 - \(Date().timeIntervalSince(date))")
    }

   
}
