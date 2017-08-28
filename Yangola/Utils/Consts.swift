//
//  Consts.swift
//  Yangola
//
//  Created by Lasith Hettiarachchi on 1/23/17.
//  Copyright © 2017 Lasith Hettiarachchi. All rights reserved.
//

import Foundation
import UIKit
import MAThemeKit

let THEME_COLOR = UIColor(red: 87/255, green: 3/255, blue: 105/255, alpha: 1)
let THEME_TRANSPARENT_COLOR = UIColor(red: 87/255, green: 3/255, blue: 105/255, alpha: 0.9)
let THEME_BACKGROUND_COLOR = MAThemeKit.color(withHexString: "#050006")

let ICON_DELETE = UIImage(named: "DeleteIcon")!

let DIR_ARCHIVES = ".Archives"
let DIR_AIRDROP = "Received"
let DIR_INBOX = "Inbox"
let DIR_THUMB = "MediaThumbnails"

let EXT_YANGOLA = "yangola"

let CLEAR_GARBAGE_INTERVAL: Double = 60 * 60 //in seconds

let FIRTOPIC_EVERYONE = "/topics/everyone"
let FIRTOPIC_DEV = "/topics/dev"

let ADMOB_APPID = "ca-app-pub-0243236756104316~7026016270"

enum AddUnitID: String {
    case HomeListTop = "ca-app-pub-0243236756104316/2534739940"
}

enum AdMobTestDevice: String {
    case LIHiPhone7="9e131fb834e448cffa6fbae65860ec46", SrimathisiPadMini3 = "e37f9d5aaa4025cf5af6fa26c66191b0"
}
