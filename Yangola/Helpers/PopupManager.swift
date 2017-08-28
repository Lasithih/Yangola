//
//  PopupManager.swift
//  Yangola
//
//  Created by Lasith Hettiarachchi on 8/6/17.
//  Copyright © 2017 Lasith Hettiarachchi. All rights reserved.
//

import Foundation
import MZFormSheetPresentationController

enum PopupType {
    case Move, Rename, SubList, SortBy
}

class PopupManager {
    
    static func createPopup(with vc: UIViewController, type: PopupType) -> MZFormSheetPresentationViewController {
        
        let formsheet = MZFormSheetPresentationViewController(contentViewController: vc)
        
        if type == PopupType.Move {
            formsheet.presentationController?.contentViewSize = getMoveVcSize()
            formsheet.presentationController?.shouldCenterVertically = true
            
            formsheet.presentationController?.blurEffectStyle = UIBlurEffectStyle.dark
            formsheet.presentationController?.shouldApplyBackgroundBlurEffect = true
            let completionHandler:(UIView, CGRect, Bool) -> CGRect = {
                presentedView, currentFrame, isKeyboardVisible in
                let size = getMoveVcSize()
                let screensize = UIScreen.main.bounds
                
                let x = (screensize.width - size.width) / 2
                let y = (screensize.height - size.height) / 2
                
                let origin = CGPoint(x: x, y: y)
                return CGRect(origin: origin, size: size)
            }
            formsheet.presentationController?.frameConfigurationHandler = completionHandler
            
        } else if type == PopupType.Rename {
            formsheet.presentationController?.contentViewSize = getRenameVcSize()
            formsheet.presentationController?.shouldCenterVertically = false
            formsheet.presentationController?.blurEffectStyle = UIBlurEffectStyle.dark
            formsheet.presentationController?.shouldApplyBackgroundBlurEffect = true
            
        } else if type == PopupType.SubList {
            formsheet.presentationController?.contentViewSize = getRenameVcSize()
            formsheet.presentationController?.shouldCenterVertically = true
            formsheet.presentationController?.shouldApplyBackgroundBlurEffect = false
            
        } else if type == PopupType.SortBy {
            formsheet.presentationController?.contentViewSize = getSortByVcSize()
            formsheet.presentationController?.shouldCenterVertically = true
            formsheet.presentationController?.blurEffectStyle = UIBlurEffectStyle.dark
            formsheet.presentationController?.shouldApplyBackgroundBlurEffect = true
        }
        
        formsheet.presentationController?.shouldCenterHorizontally = true
        
        return formsheet
    }
    
    static func getMoveVcSize() -> CGSize {
        let screenSize = UIScreen.main.bounds
        var width = screenSize.width - 20
        let height = screenSize.height - 100
        if width > 500 {
            width = 500
        }
        return CGSize(width: width, height: height)
    }
    
    static func getRenameVcSize() -> CGSize {
        let screenSize = UIScreen.main.bounds
        var width = screenSize.width - 40
        let height: CGFloat = 150
        
        if width > 300 {
            width = 300
        }
        
        return CGSize(width: width, height: height)
    }
    
    static func getSortByVcSize() -> CGSize {
        let screenSize = UIScreen.main.bounds
        var width = screenSize.width - 40
        let height: CGFloat = 300
        
        if width > 300 {
            width = 300
        }
        
        return CGSize(width: width, height: height)
    }
}


