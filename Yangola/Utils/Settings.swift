//
//  Settings.swift
//  Yangola
//
//  Created by Lasith Hettiarachchi on 8/21/16.
//  Copyright © 2016 Lasith Hettiarachchi. All rights reserved.
//

import Foundation


let YGColorSchemeKey: String = "colorScheme"

enum ColorScheme {
    case dark, light
}

class Settings {
    
    fileprivate let darkKey = "dark"
    fileprivate let lightKey = "light"
    
    func getColorScheme() -> ColorScheme? {
        let preferences = UserDefaults.standard
        
        let key = YGColorSchemeKey
        
        if preferences.object(forKey: key) == nil {
            return ColorScheme.dark
        } else {
            let scheme = preferences.string(forKey: key) as String!
            if scheme == self.darkKey {
                return ColorScheme.dark
            } else {
                return ColorScheme.light
            }
        }
    }
    
    func setColorScheme(_ scheme: ColorScheme){
        
        let preferences = UserDefaults.standard
        
        let key = YGColorSchemeKey
        
        var schemeKey = self.darkKey
        if scheme == ColorScheme.light {
            schemeKey = self.lightKey
        }
        
        preferences.set(schemeKey, forKey: key)
        
        preferences.synchronize()
        
    }
}
