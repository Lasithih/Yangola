//
//  SplashViewController.swift
//  Yangola
//
//  Created by Lasith Hettiarachchi on 2/26/17.
//  Copyright © 2017 Lasith Hettiarachchi. All rights reserved.
//

import UIKit

class SplashViewController: UIViewController {

    //IBOutlets
    
    
    //private members
    
    
    
    //public members
    
    
    
    
    
    //////////////////////////////////////////////////////
    //MARK: - View Controller Methods
    //////////////////////////////////////////////////////
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.performSegue(withIdentifier: "ShowHome", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let vc = segue.destination as? UINavigationController {
            
            vc.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        }
    }
    
    
    //////////////////////////////////////////////////////
    //MARK: - Private Methods
    //////////////////////////////////////////////////////
    
    
    
    //////////////////////////////////////////////////////
    //MARK: - Events
    //////////////////////////////////////////////////////

    
    
    //////////////////////////////////////////////////////
    //MARK: - Delegate Methods
    //////////////////////////////////////////////////////

}
