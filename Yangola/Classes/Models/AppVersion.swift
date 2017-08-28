//
//  AppVersion.swift
//  Yangola
//
//  Created by Lasith Hettiarachchi on 8/27/17.
//  Copyright © 2017 Lasith Hettiarachchi. All rights reserved.
//

import Foundation
import OLCOrm

class AppVersion: OLCModel {
    
    var Id: NSNumber?
    var version: String?
    var noticeShown: Bool = false
}

class UpdateAppNotice: OLCModel {
    
    var Id: NSNumber?
    var lastShownDate: Date = Date()
    var forVersion: String?
}
