//
//  RenameViewController.swift
//  Yangola
//
//  Created by Lasith Hettiarachchi on 8/6/17.
//  Copyright © 2017 Lasith Hettiarachchi. All rights reserved.
//

import UIKit
import ionicons

protocol RenameDelegate {
    func nameChanged(to: String)
}

class RenameViewController: ParentViewController {
    
    @IBOutlet weak var txtName: UITextField!
    
    var delegate: RenameDelegate?
    var name: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let menuIcon = IonIcons.image(withIcon: ion_ios_close_empty, size: 30, color: UIColor.white)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: menuIcon, style: UIBarButtonItemStyle.plain, target: self, action: #selector(RenameViewController.close(_:)))
        
        self.txtName.text = name
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func close(_ sender: Any) {
        
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func done(_ sender: Any) {
        
        if let name = self.txtName.text, name.characters.count > 0 {
            self.delegate?.nameChanged(to: name)
            dismiss(animated: true, completion: nil)
        } else {
            
        }
    }
}
