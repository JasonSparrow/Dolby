//
//  ViewController.swift
//  Dolby
//
//  Created by 王腾飞 on 2017/11/18.
//  Copyright © 2017年 王腾飞. All rights reserved.
//

import UIKit
import CoreMedia
import AVFoundation

class ViewController: UIViewController {

    var play:AVPlayer!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let parentLayer:CALayer = CALayer()
        parentLayer.frame = self.view.bounds;
        parentLayer.backgroundColor = UIColor.blue.cgColor
        
        
        let image:UIImage = UIImage(named:"1.jpg")!
        let imageLayer:CALayer = CALayer()
        
        imageLayer.contents = image.cgImage
        imageLayer.contentsScale = UIScreen.main.scale

        
        let midX:CGFloat = parentLayer.bounds.midX
        let midY:CGFloat = parentLayer.bounds.midY
        
        imageLayer.bounds = CGRect(x: 0, y: 0, width: 200, height: 200)
        imageLayer.position = CGPoint(x: midX, y: midY)
        parentLayer.addSublayer(imageLayer)

        let rotationAnimation:CABasicAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotationAnimation.isRemovedOnCompletion = false
        rotationAnimation.toValue = 2 * CGFloat.pi
        rotationAnimation.duration = 3.0
        rotationAnimation.repeatCount = 100
        imageLayer.add(rotationAnimation, forKey: "rotateAnimation")

        
       

        
        let dy:DyAnimation = DyAnimation()
        
        let syncLayer:AVSynchronizedLayer = AVSynchronizedLayer(playerItem: dy.item)
        syncLayer.addSublayer(parentLayer)
        
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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.navigationController?.pushViewController(DyAnimationViewController(), animated: true)
    }

}

