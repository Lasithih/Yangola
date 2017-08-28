//
//  TransparentNavigationControllerViewController.swift
//  Yangola
//
//  Created by Lasith Hettiarachchi on 1/23/17.
//  Copyright © 2017 Lasith Hettiarachchi. All rights reserved.
//

import UIKit

class TransparentNavigationControllerViewController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationBar.shadowImage = UIImage()
        self.navigationBar.isTranslucent = true
        self.view.backgroundColor = UIColor.clear
        self.navigationBar.backgroundColor =  UIColor.clear
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}
