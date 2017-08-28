//
//  FolderCollectionViewCell.swift
//  Yangola
//
//  Created by Lasith Hettiarachchi on 7/22/16.
//  Copyright © 2016 Lasith Hettiarachchi. All rights reserved.
//

import UIKit
import ionicons

class FolderCollectionViewCell: UICollectionViewCell {
    
    //IBOutlets
    @IBOutlet weak var selectedView: UIView!
    @IBOutlet weak var imgThumb: UIImageView!
    @IBOutlet weak var thumbnail1: UIImageView!
    @IBOutlet weak var thumbnail2: UIImageView!
    @IBOutlet weak var thumbnail3: UIImageView!
    @IBOutlet weak var thumbnail4: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    
    @IBOutlet weak var thumb1WidthHalf: NSLayoutConstraint!
    @IBOutlet weak var thumb1HeightHalf: NSLayoutConstraint!
    
    
    
    //Private variables
    var item: FileFolder?
    
    override func awakeFromNib() {
        
        
    }
    
    func setItem(_ fileFolder: FileFolder, selected: Bool) {
        
        self.item = fileFolder
        self.selectedView.isHidden = !selected
        
        self.lblName.text = fileFolder.Name

        
        self.clearThumbnails()
        if fileFolder.thumbnails.count > 0 {
            self.thumbnail1.image = fileFolder.thumbnails[0]
        }
        if fileFolder.thumbnails.count > 1 {
            self.thumbnail2.image = fileFolder.thumbnails[1]
        }
        if fileFolder.thumbnails.count > 2 {
            self.thumbnail3.image = fileFolder.thumbnails[2]
        }
        if fileFolder.thumbnails.count > 3 {
            self.thumbnail4.image = fileFolder.thumbnails[3]
        }
        
        
        self.imgThumb.image = IonIcons.image(withIcon: ion_ios_checkmark, size: 30, color: UIColor.white)
    }
    
    
    fileprivate func clearThumbnails() {
        
        self.thumbnail1.image = nil
        self.thumbnail2.image = nil
        self.thumbnail3.image = nil
        self.thumbnail4.image = nil
    }
}
