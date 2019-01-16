//
//  BYLoadingLayer.swift
//  Circle
//
//  Created by 王腾飞 on 2019/1/6.
//  Copyright © 2019 王腾飞. All rights reserved.
//

import UIKit

class BYLoadingLayer: UIView {

    override var isHidden: Bool {
        didSet {
            if isHidden {
                
            }else {
                loadingAnimation()
            }
        }
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
    
        let loadingLayer = CALayer()
        loadingLayer.backgroundColor = UIColor.clear.cgColor
        loadingLayer.frame = CGRect.init(x: 0, y: 0, width: frame.size.width, height: frame.size.height)
        
        let bezierPath = UIBezierPath.init(arcCenter: CGPoint.init(x: loadingLayer.frame.size.width / 2, y: loadingLayer.frame.size.height / 2), radius: (loadingLayer.frame.size.width - 2) / 2, startAngle: 0, endAngle: CGFloat(Double.pi * 2), clockwise: true)
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = UIColor.white.cgColor
        shapeLayer.lineWidth = 2
        shapeLayer.strokeStart = 0
        shapeLayer.strokeEnd = 1
        shapeLayer.lineCap = CAShapeLayerLineCap.round
        shapeLayer.lineDashPhase = 1
        shapeLayer.path = bezierPath.cgPath
        self.layer.addSublayer(shapeLayer)
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.shadowPath = bezierPath.cgPath
        gradientLayer.frame = CGRect.init(x: 0, y: 0, width: loadingLayer.frame.size.width, height: loadingLayer.frame.size.height / 2)
        gradientLayer.startPoint = CGPoint.init(x: 1, y: 0)
        gradientLayer.endPoint = CGPoint.init(x: 0, y: 0)
        gradientLayer.colors = [UIColor.white.cgColor, UIColor.gray.withAlphaComponent(0.7).cgColor]
        loadingLayer.addSublayer(gradientLayer)
        loadingLayer.mask = shapeLayer
        self.layer.addSublayer(loadingLayer)
        
        let gradientLayer1 = CAGradientLayer()
        gradientLayer1.shadowPath = bezierPath.cgPath
        gradientLayer1.frame = CGRect.init(x: 0, y: loadingLayer.frame.size.height / 2, width: loadingLayer.frame.size.width, height: loadingLayer.frame.size.height / 2)
        gradientLayer1.startPoint = CGPoint.init(x: 0, y: 1)
        gradientLayer1.endPoint = CGPoint.init(x: 1, y: 1)
        gradientLayer1.colors = [UIColor.gray.withAlphaComponent(0.7).cgColor, UIColor.gray.withAlphaComponent(0.2).cgColor]
        loadingLayer.addSublayer(gradientLayer1)
        loadingLayer.mask = shapeLayer
        self.layer.addSublayer(loadingLayer)
        
        loadingAnimation()
        
    }
    
    
    func loadingAnimation() {
        let rotationAnimation:CABasicAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotationAnimation.fromValue = 0
        rotationAnimation.toValue = Double.pi * 2
        rotationAnimation.repeatCount = MAXFLOAT
        rotationAnimation.duration = 1
        rotationAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        self.layer.add(rotationAnimation, forKey: "rotationAnnimation")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
