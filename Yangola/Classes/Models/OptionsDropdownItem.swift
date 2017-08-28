//
//  OptionsDropdownItem.swift
//  Yangola
//
//  Created by Lasith Hettiarachchi on 2/10/17.
//  Copyright © 2017 Lasith Hettiarachchi. All rights reserved.
//

import Foundation
import UIKit

class OptionsDropdownItem {
    
    var optionTitle: String?
    var optionImage: UIImage?
    
    
    required init(title: String, image: UIImage?) {
        self.optionTitle = title
        self.optionImage = image
        
    }
}
