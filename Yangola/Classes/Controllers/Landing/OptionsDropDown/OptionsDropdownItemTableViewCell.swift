//
//  OptionsDropdownItemTableViewCell.swift
//  Yangola
//
//  Created by Lasith Hettiarachchi on 2/10/17.
//  Copyright © 2017 Lasith Hettiarachchi. All rights reserved.
//

import UIKit

class OptionsDropdownItemTableViewCell: UITableViewCell {

    @IBOutlet weak var droptownTitle: UILabel!
    @IBOutlet weak var dropdownImage: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    
    func setValues(dropdownItem: OptionsDropdownItem) {
        
        self.droptownTitle.text = dropdownItem.optionTitle
        self.dropdownImage.image = dropdownItem.optionImage
    }
}
