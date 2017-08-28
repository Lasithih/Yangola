//
//  FrostyTabBar.swift
//  Yangola
//
//  Created by Lasith Hettiarachchi on 1/22/17.
//  Copyright © 2017 Lasith Hettiarachchi. All rights reserved.
//

import UIKit

class FrostyTabBar: UITabBar {

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    
        self.superview?.backgroundColor = UIColor.clear
        self.backgroundImage = UIImage(named: "foolsHead")
        self.tintColor = UIColor.white
        let frost = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        frost.frame = self.bounds
        frost.autoresizingMask = .flexibleWidth
        self.insertSubview(frost, at: 0)
        
    }

}
