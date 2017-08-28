//
//  AppData.swift
//  Yangola
//
//  Created by Lasith Hettiarachchi on 8/26/17.
//  Copyright © 2017 Lasith Hettiarachchi. All rights reserved.
//

import Foundation

class AppData {
    
    static func getAppVersion() -> String? {
        
        var versionString: String? = nil
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            versionString = version
        }
        return versionString
    }
    
    static func getAppBuild() -> String? {
        
        var buildString: String? = nil
        if let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
            buildString = build
        }
        
        return buildString
    }
    
    static func getAppEnvironment() -> AppEnvironment {
        
        return AppEnvironment.Live
    }
}

enum AppEnvironment {
    case Dev, Live, Beta
}
