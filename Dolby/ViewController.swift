//
//  ViewController.swift
//  Dolby
//
//  Created by 王腾飞 on 2017/11/18.
//  Copyright © 2017年 王腾飞. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    }

    @IBAction func picToVideo(_ sender: Any) {
        self.navigationController?.pushViewController(DyStopViewController(), animated: true)
    }
    
    @IBAction func playBack(_ sender: Any) {
        self.navigationController?.pushViewController(DyReverseViewController(), animated: true)
    }
    
    @IBAction func animation(_ sender: Any) {
        self.navigationController?.pushViewController(DyAnimationViewController(), animated: true)
    }
    
    @IBAction func transition(_ sender: Any) {
        self.navigationController?.pushViewController(DyTransitionViewController(), animated: true)
    }
    
}

