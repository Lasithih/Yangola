//
//  Enums.swift
//  Yangola
//
//  Created by Lasith Hettiarachchi on 7/21/16.
//  Copyright © 2016 Lasith Hettiarachchi. All rights reserved.
//

import Foundation


enum LandingScreenIndex: Int {
    case folders=0,files=1,favourites=2,recents=3,recentlyAdded=4,mostViewed=5
}

enum FileFolderType {
    case file, folder
}

enum OptionsDropdownOption: String {
    case Select, Sort, NewFolder
}

enum RemoteConfigKey: String {
    case forceUpdate = "force_update", laterstVersion = "latest_version"
}

