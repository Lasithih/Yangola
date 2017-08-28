//
//  FilesFooterCollectionReusableView.swift
//  Yangola
//
//  Created by Lasith Hettiarachchi on 8/7/17.
//  Copyright © 2017 Lasith Hettiarachchi. All rights reserved.
//

import UIKit

class FilesFooterCollectionReusableView: UICollectionReusableView {
    
    @IBOutlet weak var totalSize: UILabel!
    @IBOutlet weak var totalFiles: UILabel!
    
    func setData(size: String, files: String) {
        
        self.totalSize.text = size
        self.totalFiles.text = files
    }
}
