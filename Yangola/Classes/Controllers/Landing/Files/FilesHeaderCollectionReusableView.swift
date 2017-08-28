//
//  FilesHeaderCollectionReusableView.swift
//  Yangola
//
//  Created by Lasith Hettiarachchi on 8/7/17.
//  Copyright © 2017 Lasith Hettiarachchi. All rights reserved.
//

import UIKit

class FilesHeaderCollectionReusableView: UICollectionReusableView {
        
    @IBOutlet weak var currentPath: UILabel!
    
    func setData(path: String) {
        
        currentPath.text = path
    }
}
