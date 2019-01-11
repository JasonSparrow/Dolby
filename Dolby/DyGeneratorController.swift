//
//  DyGeneratorController.swift
//  Dolby
//
//  Created by 王腾飞 on 2019/1/11.
//  Copyright © 2019 王腾飞. All rights reserved.
//

import UIKit

class DyGeneratorController: UITableViewController {

    var list:[UIImage] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        let url = URL.init(string: "https://file.shangjinuu.com/content/video/20190111092715512.mp4")!
        let asset = AVAsset.init(url: url)
        
        let generate = DyGenerateThumbnails()
        generate.generateThumbnails(asset)
        generate.callback = { list in
            self.list = list!
            self.tableView.reloadData()
        }
        
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.layer.contents = list[indexPath.row].cgImage!
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }

}
