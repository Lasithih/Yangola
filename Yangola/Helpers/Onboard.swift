//
//  Onboard.swift
//  Yangola
//
//  Created by Lasith Hettiarachchi on 8/13/17.
//  Copyright © 2017 Lasith Hettiarachchi. All rights reserved.
//

import Foundation
import Onboard

enum OnboardType {
    case addMedia, all, videoControls
}

class Onboard {
    
    func getVC(title: String, body: String, image: UIImage?, buttonText: String, scale: Bool = false) -> OnboardingContentViewController {
        
        let page = OnboardingContentViewController(title: title, body: body, image: image, buttonText: buttonText) { () -> Void in
            // do something here when users press the button, like ask for location services permissions, register for push notifications, connect to social media, or finish the onboarding process
        }
        
        page.iconImageView.contentMode = UIViewContentMode.scaleAspectFit
        page.topPadding = UIScreen.main.bounds.height / 667 * 100
        page.iconImageView.clipsToBounds = true
        page.titleLabel.font = UIFont.systemFont(ofSize: 25)
        page.bodyLabel.font = UIFont.systemFont(ofSize: 20)
        page.bodyLabel.textAlignment = NSTextAlignment.center
        
        if scale {
            page.iconWidth = UIScreen.main.bounds.width - 50
            page.iconHeight = self.getHeight(for: page.iconWidth)
        }
        
        return page
    }
    
    func getOnboardViewController(type: OnboardType) -> UIViewController? {
        
        var vcs: [OnboardingContentViewController] = []
        
        if type == OnboardType.addMedia || type == OnboardType.all {
            
            let firstPage = OnboardingContentViewController(title: "Welcome", body: "Swipe to learn how to add your media", image: UIImage(named: "yangolalogo_light_withbg"), buttonText: "") { () -> Void in
                // do something here when users press the button, like ask for location services permissions, register for push notifications, connect to social media, or finish the onboarding process
            }
            
            firstPage.iconImageView.contentMode = UIViewContentMode.scaleAspectFit
            firstPage.iconImageView.clipsToBounds = true
            firstPage.bodyLabel.textAlignment = NSTextAlignment.center
            vcs.append(firstPage)
            
            let secondPage = getVC(title: "Connect to iTunes", body: "•  Connect your iPhone/iPad to your Mac or PC\n"+"•  Open iTunes", image: UIImage(named: "connectItunes"), buttonText: "")
            vcs.append(secondPage)
            
            let thirdPage = getVC(title: "", body: "•  Select your device\n•  Go to Apps tab", image: UIImage(named: "selectiphone"), buttonText: "")
            vcs.append(thirdPage)
            
            var fourthMessage = ""
            if type == OnboardType.addMedia {
                fourthMessage = "Got it!"
            }
            let fourthPage = getVC(title: "", body: "•  Scroll down to File Sharing\n•  Select Yangola\n•  Click Add", image: UIImage(named: "selectyangola"), buttonText: fourthMessage)
            
            if type == OnboardType.addMedia {
                fourthPage.buttonActionHandler = {vc in
                    vc.dismiss(animated: true, completion: nil)
                }
            }
            
            vcs.append(fourthPage)
            
        }
        
        if type == OnboardType.videoControls || type == OnboardType.all {
            
            
            let secondPage = getVC(title: "Player controls", body: "", image: UIImage(named: "welcome_player1"), buttonText: "", scale: true)
            vcs.append(secondPage)
            
            let thirdPage = getVC(title: "Double tap", body: "Double tap your screen to \nplay/pause \njump forward \njump backward", image: UIImage(named: "welcome_player2"), buttonText: "", scale: true)
            vcs.append(thirdPage)
            
            let fourthPage = getVC(title: "Swipe up/down", body: "Swipe your screen up/down to adjust \nvoulume \nbrightness", image: UIImage(named: "welcome_player3"), buttonText: "", scale: true)
            vcs.append(fourthPage)
            
            let fifthPage = getVC(title: "Swipe left/right", body: "Swipe your screen left/right to seek", image: UIImage(named: "welcome_player4"), buttonText: "Got it!", scale: true)
            if type == OnboardType.addMedia {
                fifthPage.buttonActionHandler = {vc in
                    vc.dismiss(animated: true, completion: nil)
                }
            }
            fifthPage.buttonActionHandler = {vc in
                vc.dismiss(animated: true, completion: nil)
            }
            vcs.append(fifthPage)
            
        }
        
        
        
        // Image
        let onboardingVC = OnboardingViewController(backgroundImage: UIImage(named: "welcomeBg"), contents: vcs)
        onboardingVC?.allowSkipping = true
        onboardingVC?.skipHandler = {
            onboardingVC?.dismiss(animated: true, completion: nil)
        }
        
        return onboardingVC
    }
    
    
    
    fileprivate func getHeight(for width: CGFloat) -> CGFloat {
        
        return width / 507 * 285;
    }
}
