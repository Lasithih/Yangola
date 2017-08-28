//
//  ListItemTableViewCell.swift
//  Yangola
//
//  Created by Lasith Hettiarachchi on 8/10/17.
//  Copyright © 2017 Lasith Hettiarachchi. All rights reserved.
//

import UIKit
import ionicons

class ListItemTableViewCell: UITableViewCell {

    @IBOutlet weak var listItemName: UILabel!
    @IBOutlet weak var imgSelecetd: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let check = IonIcons.image(withIcon: ion_ios_checkmark_empty, size: 100, color: UIColor.white)
        self.imgSelecetd.image = check
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func setData(item: ListItem) {
        
        self.listItemName.text = item.name
        self.imgSelecetd.isHidden = !item.selected
    }
    
}
