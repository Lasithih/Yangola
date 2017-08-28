//
//  UserData.swift
//  Yangola
//
//  Created by Lasith Hettiarachchi on 8/14/17.
//  Copyright © 2017 Lasith Hettiarachchi. All rights reserved.
//

import Foundation

enum UserDefaultKey: String {
    case firstLaunchFinished, jumpInterval, welcomeScreens, continuePlayback, playPause, jumpForward, jumpBackward, swipeVolume, swipeBrightness, swipeSeek
}

enum JumpInterval: String {
    case extraShort, short, medium, long
}

enum ContinuePlayback: String {
    case ask, `continue`, never
}


class UserData {
    
    //string
    fileprivate static func setStringUserData(value: String?, forKey key: UserDefaultKey) {
        UserDefaults.standard.set(value, forKey: key.rawValue)
    }
    
    fileprivate static func getStringUserData(forKey key: UserDefaultKey) -> String? {
        return UserDefaults.standard.string(forKey: key.rawValue)
    }
    
    
    //bool
    static func setBoolUserData(value: Bool, forKey key: UserDefaultKey) {
        UserDefaults.standard.set(value, forKey: key.rawValue)
    }
    
    static func getBoolUserData(forKey key: UserDefaultKey) -> Bool {
        return UserDefaults.standard.bool(forKey: key.rawValue)
    }
    
    
    //Jump interval
    static func setJumpInterval(jumpInterval: JumpInterval) {
        setStringUserData(value: jumpInterval.rawValue, forKey: UserDefaultKey.jumpInterval)
    }
    
    static func getJumpInterval() -> JumpInterval? {
        if let raw = getStringUserData(forKey: UserDefaultKey.jumpInterval) {
            return JumpInterval(rawValue: raw)
        }
        return nil
    }
    
    //welcome screens
    static func setWelcomescreensWatched(watched: Bool) {
        setBoolUserData(value: watched, forKey: UserDefaultKey.welcomeScreens)
    }
    
    static func welcomeScreensWatched() -> Bool {
        
        return getBoolUserData(forKey: UserDefaultKey.welcomeScreens)
    }
    
    //continue playback
    static func setContinuePlayback(continuePlayback: ContinuePlayback) {
        setStringUserData(value: continuePlayback.rawValue, forKey: UserDefaultKey.continuePlayback)
    }
    
    static func getContinuePlayback() -> ContinuePlayback? {
        if let raw = getStringUserData(forKey: UserDefaultKey.continuePlayback) {
            return ContinuePlayback(rawValue: raw)
        }
        return nil
    }
}
