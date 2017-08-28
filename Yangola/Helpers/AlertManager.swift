//
//  AlertManager.swift
//  Yangola
//
//  Created by Lasith Hettiarachchi on 7/21/16.
//  Copyright © 2016 Lasith Hettiarachchi. All rights reserved.
//

import Foundation
import UIKit

class AlertManager {
    
    func getProcessingAlert(withMessage message: String) -> LIHAlert {
        
        let alert =  LIHAlertManager.getProcessingAlert(message: message)
        self.applyCommonConfig(alert: alert)
        return alert
    }
    
    func getSuccessAlert(withMessage message: String) -> LIHAlert {
        
        return LIHAlertManager.getSuccessAlert(message: message)
    }
    
    func getErrorAlert(withMessage message: String) -> LIHAlert {
        
        let alert = LIHAlertManager.getErrorAlert(message: message)
        self.applyCommonConfig(alert: alert)
        return alert
    }
    
    fileprivate func applyCommonConfig(alert: LIHAlert) {
        
        alert.hasNavigationBar = true
        alert.alertHeight = 40
        alert.contentTextFont = UIFont.systemFont(ofSize: 14)
        alert.alertAlpha = 0.85
    }
}
