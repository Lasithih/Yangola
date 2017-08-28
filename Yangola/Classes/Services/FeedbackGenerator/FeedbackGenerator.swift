//
//  FeedbackGenerator.swift
//  Yangola
//
//  Created by Lasith Hettiarachchi on 8/26/17.
//  Copyright © 2017 Lasith Hettiarachchi. All rights reserved.
//

import Foundation

class FeedbackGenerator {
    
    static let shared = FeedbackGenerator()
    
    func generateError() {
        
        if #available(iOS 10.0, *) {
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.error)
        }
    }
    
    func generateSuccess() {
        
        if #available(iOS 10.0, *) {
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
        }
    }
    
    func generateImpact() {
        
        if #available(iOS 10.0, *) {
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
        }
    }
    
    func generateSelectionChanged() {
        
        if #available(iOS 10.0, *) {
            let generator = UISelectionFeedbackGenerator()
            generator.selectionChanged()
        }
    }
}
