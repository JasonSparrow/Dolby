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
    var playItem:AVPlayerItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let url1 = Bundle.main.url(forResource: "1513822721", withExtension: "mp4")
        let asset1 = AVAsset(url: url1!)
        let url2 = Bundle.main.url(forResource: "1513823108", withExtension: "mp4")
        let asset2 = AVAsset(url: url2!)
        let url3 = Bundle.main.url(forResource: "1513822721", withExtension: "mp4")
        let asset3 = AVAsset(url: url3!)
        let url4 = Bundle.main.url(forResource: "1513823108", withExtension: "mp4")
        let asset4 = AVAsset(url: url4!)
        
        let videoAssets = [asset1, asset2, asset3, asset4]
        
//        var transition:TransitionCompositionBuilder = TransitionCompositionBuilder.init(assets: videoAssets, transitionDuration: 0.5)!
//        let transitionComposition = transition.buildComposition()
//         playItem = transitionComposition.makePlayable()
        
        let dy:DyVideoTransition = DyVideoTransition(assets: videoAssets)
        playItem = dy.makePlayable()
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
    
    
    deinit {
        playItem.removeObserver(self, forKeyPath: "status", context: nil)
    }
    
    
}
