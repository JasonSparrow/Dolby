//
//  DyReverseViewController.swift
//  Dolby
//
//  Created by hr on 2017/12/19.
//  Copyright © 2017年 王腾飞. All rights reserved.
//

import UIKit

class DyReverseViewController: UIViewController {
    
    var play:AVPlayer!
    var playItem:AVPlayerItem!
    
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
                self.playItem = AVPlayerItem(asset: asset!)
                self.playItem.addObserver(self, forKeyPath: "status", options: NSKeyValueObservingOptions.new, context: nil)
                self.play = AVPlayer(playerItem: self.playItem)
                
                let playLayer = AVPlayerLayer(player: self.play)
                playLayer.backgroundColor = UIColor.red.cgColor
                playLayer.frame = self.view.bounds
                self.view.layer.addSublayer(playLayer)
            }

        }
        print("结束 - \(Date().timeIntervalSince(date))")
        
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        switch play.status {
        case .readyToPlay:
            play.play()
            print("play")
        case .failed:
            print("fail")
        default:
            print("unknow")
        }
    }
    
    deinit {
        playItem.removeObserver(self, forKeyPath: "status", context: nil)
    }
   
}
