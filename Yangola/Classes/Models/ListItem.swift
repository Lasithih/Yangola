//
//  ListItem.swift
//  Yangola
//
//  Created by Lasith Hettiarachchi on 8/14/17.
//  Copyright © 2017 Lasith Hettiarachchi. All rights reserved.
//

import Foundation

class ListItem {
    
    var id: Any?
    var name: String
    var selected = false
    
    init(name: String) {
        
        self.name = name
    }
    
    init(name: String, selected: Bool) {
        
        self.name = name
        self.selected = selected
    }
}
