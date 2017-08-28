//
//  PopupParentViewController.swift
//  Yangola
//
//  Created by Lasith Hettiarachchi on 8/24/17.
//  Copyright © 2017 Lasith Hettiarachchi. All rights reserved.
//

import UIKit

class PopupParentViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupNavigationBar()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func setupNavigationBar() {
        
        self.navigationController?.navigationBar.tintColor = UIColor.black
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
    }
}
