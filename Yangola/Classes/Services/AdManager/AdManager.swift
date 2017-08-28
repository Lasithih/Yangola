//
//  AdManager.swift
//  Yangola
//
//  Created by Lasith Hettiarachchi on 8/23/17.
//  Copyright © 2017 Lasith Hettiarachchi. All rights reserved.
//

import Foundation
import GoogleMobileAds

class AdManager {
    
    static let shared = AdManager()
    
    func isAdsEnabled() -> Bool {
        return true
    }
    
    func setupHomeListTopAd(forView: GADNativeExpressAdView, root: UIViewController) {
        
        forView.adUnitID = AddUnitID.HomeListTop.rawValue
        forView.rootViewController = root;
        let req = GADRequest()
        req.testDevices = [kGADSimulatorID, AdMobTestDevice.LIHiPhone7.rawValue, AdMobTestDevice.SrimathisiPadMini3.rawValue]
        forView.load(req)
    }
}
