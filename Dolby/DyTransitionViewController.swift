//
//  DyTransitionViewController.swift
//  Dolby
//
//  Created by hr on 2017/12/19.
//  Copyright © 2017年 王腾飞. All rights reserved.
//

import UIKit
import AVFoundation

class DyTransitionViewController: UIViewController {

    var play:AVPlayer!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        let dy:DyAnimation = DyAnimation()
        dy.item?.addObserver(self, forKeyPath: "status", options: NSKeyValueObservingOptions.new, context: nil)
        play = AVPlayer(playerItem: dy.item)
        
        
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
