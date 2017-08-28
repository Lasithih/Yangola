//
//  ParentViewController.swift
//  Yangola
//
//  Created by Lasith Hettiarachchi on 8/21/16.
//  Copyright © 2016 Lasith Hettiarachchi. All rights reserved.
//

import UIKit
import MAThemeKit
import Firebase

enum AnalyticsUserProperty: String {
    case folderName, videoExtension, videoName, videoLength, videoSize, subCount
}

class ParentViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.tintColor = THEME_COLOR
        self.configBackgroundColor()
        self.setupNavigationBar()
        
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupNavigationBar() {
        
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
    }
    
    func logEvent(with name: String) {
        
        Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
            AnalyticsParameterItemID: "id-\(name)" as NSObject,
            AnalyticsParameterItemName: name as NSObject,
            AnalyticsParameterContentType: "page" as NSObject
        ])
    }
    
    func setUserProperty(value: String, name: String) {
        
        Analytics.setUserProperty(value, forName: name)
    }

    func configBackgroundColor() {
        
//        var myDict: NSDictionary?
//        if let path = Bundle.main.path(forResource: "ColorSchemes", ofType: "plist") {
//            myDict = NSDictionary(contentsOfFile: path)
//        }
//        
//        if let dict = myDict {
//            
//            if Settings().getColorScheme() == ColorScheme.dark {
//                
//                if let darkdictionary = dict.value(forKey: "Dark Scheme") as? NSDictionary {
//                    
//                    if let bg = darkdictionary.value(forKey: "Background") as? String {
//                        self.view.backgroundColor = MAThemeKit.color(withHexString: bg)
//                    }
//                }
//                
//            } else {
//                
//                if let darkdictionary = dict.value(forKey: "Light Scheme") as? NSDictionary {
//                    
//                    if let bg = darkdictionary.value(forKey: "Background") as? String {
//                        self.view.backgroundColor = MAThemeKit.color(withHexString: bg)
//                    }
//                }
//            }
//        }
        
        self.view.backgroundColor = MAThemeKit.color(withHexString: "050006")
    }

}
