//
//  CreditsViewController.swift
//  Yangola
//
//  Created by Lasith Hettiarachchi on 7/23/17.
//  Copyright © 2017 Lasith Hettiarachchi. All rights reserved.
//

import UIKit

class CreditsViewController: ParentViewController, UITableViewDataSource {

    var credits: [Library] = [Library]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Credits"
        
        super.logEvent(with: "Credits")
        
        self.fillCredits()
        
        self.navigationController?.navigationBar.viewWithTag(10)?.removeFromSuperview()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    fileprivate func fillCredits() {
        credits.append(Library(name: "MobileVLCKit", url: "https://code.videolan.org/videolan/VLCKit", desc: "MobileVLCKit is open-source software licensed under LGPLv2.1 or later"))
        
        credits.append(Library(name: "LIHAlert", url: "https://github.com/Lasithih/LIHAlert", desc: "Advance animated alerts for iOS written in Swift"))
        
        credits.append(Library(name: "OLCOrm", url: "https://github.com/LakithaRav/OLCOrm", desc: "Objective-C Object Relational Mapping library iOS"))
        
        credits.append(Library(name: "MAThemeKit", url: "https://github.com/mamaral/MAThemeKit", desc: "Create an iOS app color theme using a single line of code."))
        
        credits.append(Library(name: "NVActivityIndicatorView", url: "https://github.com/ninjaprox/NVActivityIndicatorView", desc: "A collection of awesome loading animations"))
        
        credits.append(Library(name: "MZFormSheetPresentationController", url: "https://github.com/m1entus/MZFormSheetPresentationController", desc: "MZFormSheetPresentationController provides an alternative to the native iOS UIModalPresentationFormSheet, adding support for iPhone and additional opportunities to setup UIPresentationController size and feel form sheet."))
        
        credits.append(Library(name: "Ionicons", url: "https://github.com/sweetmandm/ionicons-iOS", desc: "Easily use ionicons in your native SDK iOS projects"))
        
        credits.append(Library(name: "Onboard", url: "https://github.com/mamaral/Onboard", desc: "An iOS framework to easily create a beautiful and engaging onboarding experience with only a few lines of code."))
        
        credits.append(Library(name: "DZNEmptyDataSet", url: "https://github.com/dzenbot/DZNEmptyDataSet", desc: "A drop-in UITableView/UICollectionView superclass category for showing empty datasets whenever the view has no content to display."))
        
        credits.append(Library(name: "InAppSettingsKit", url: "https://github.com/futuretap/InAppSettingsKit", desc: "This iOS framework allows settings to be in-app in addition to or instead of being in the Settings app."))
        
        credits.append(Library(name: "Firebase", url: "https://firebase.google.com/", desc: "Firebase is Google's mobile platform that helps you quickly develop high-quality apps and grow your business."))
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.credits.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Credits") as! CreditsTableViewCell
        cell.setData(library: self.credits[indexPath.row], delegate: self)
        return cell
    }
}

extension CreditsViewController: CreditsCellDelegate {
    
    func visitUrl(url: String) {
        
        if let urlToVisit = URL(string: url) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(urlToVisit, options: [:], completionHandler: nil)
            } else {
                // Fallback on earlier versions
                UIApplication.shared.openURL(urlToVisit)
            }
        }
    }
}
