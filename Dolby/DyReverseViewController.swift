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
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let url = Bundle.main.url(forResource: "input", withExtension: "mov")
        let asset = AVAsset(url: url!)
        
        print("开始 - \(Date())")
        let reverseAsset:AVAsset = DyReverseVideo.asset(byReversing: asset, outputURL: DyExportURL.exportURL() as URL!)
        print("结束 - \(Date())")

        let playItem = AVPlayerItem(asset: reverseAsset)
        playItem.addObserver(self, forKeyPath: "status", options: NSKeyValueObservingOptions.new, context: nil)
        play = AVPlayer(playerItem: playItem)
        
        let playLayer = AVPlayerLayer(player: play)
        playLayer.backgroundColor = UIColor.red.cgColor
        playLayer.frame = self.view.bounds
        self.view.layer.addSublayer(playLayer)
        
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        switch play.status {
        case .readyToPlay:
            play.play()
        case .failed:
            print("fail")
        default:
            print("unknow")
        }
    }
    
}
