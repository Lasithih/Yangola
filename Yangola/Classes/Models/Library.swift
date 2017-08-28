//
//  Library.swift
//  Yangola
//
//  Created by Lasith Hettiarachchi on 8/8/17.
//  Copyright © 2017 Lasith Hettiarachchi. All rights reserved.
//

import Foundation

class Library {
    
    var name: String
    var url: String
    var desc: String?
    
    init(name: String, url: String, desc: String?) {
        self.name = name
        self.url = url
        self.desc = desc
    }
}
