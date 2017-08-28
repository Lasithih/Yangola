//
//  FileCollectionViewCell.swift
//  Yangola
//
//  Created by Lasith Hettiarachchi on 7/22/16.
//  Copyright © 2016 Lasith Hettiarachchi. All rights reserved.
//

import UIKit
import ionicons
import NVActivityIndicatorView

class FileCollectionViewCell: UICollectionViewCell {
    
    //IBOutlets
    @IBOutlet weak var selectedView: UIView!
    @IBOutlet weak var completionViewWidth: NSLayoutConstraint!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var imgThumb: UIImageView!
    @IBOutlet weak var mediaThumb: UIImageView!
    @IBOutlet weak var imgSub: UIImageView!
    @IBOutlet weak var lblSize: UILabel!
    @IBOutlet weak var lblLength: UILabel!
    @IBOutlet weak var indicator: NVActivityIndicatorView!
    
    //Private variables
    var item: FileFolder?
    
    override func awakeFromNib() {
        
    }
    
    func setItem(_ fileFolder: FileFolder, selected: Bool, cellWidth: CGFloat) {
        
        self.item = fileFolder
        
        self.selectedView.isHidden = !selected
        
        self.lblName.text = fileFolder.Name
        
        
        if let thumb = fileFolder.thumbnail {
            self.mediaThumb.image = thumb
            self.indicator.isHidden = true
            self.indicator.stopAnimating()
        } else {
            self.mediaThumb.image = nil
            self.indicator.isHidden = false
            self.indicator.startAnimating()
        }
        
        if fileFolder.Type == FileFolderType.file, let _ = fileFolder.subtitle {
            self.imgSub.image = IonIcons.image(withIcon: ion_closed_captioning, size: 15, color: UIColor.white)
        } else {
            self.imgSub.image = nil
        }
        
        self.lblLength.text = fileFolder.length
        self.lblSize.text = fileFolder.sizeString
        self.imgThumb.image = IonIcons.image(withIcon: ion_ios_checkmark, size: 30, color: UIColor.white)
        
        if let pos = fileFolder.mediaInfo?.posision {
            
            self.completionViewWidth.constant = CGFloat(pos) * cellWidth
            
            layoutIfNeeded()
        }
    }
}
