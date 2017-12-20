//
//  DyExportURL.swift
//  Dolby
//
//  Created by hr on 2017/12/18.
//  Copyright © 2017年 王腾飞. All rights reserved.
//

import UIKit

class DyExportURL: NSObject {
    
    class func exportURL() -> NSURL {
        // 4 -获取路径
        let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let dateString:String = "\(Date().timeIntervalSince1970)".replacingOccurrences(of: ".", with: "")
        let savePath = (documentDirectory as NSString).appendingPathComponent("\(dateString).mov")
        let url = NSURL(fileURLWithPath: savePath)
        print(url)
        return url
    }
}
