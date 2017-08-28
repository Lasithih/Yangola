//
//  ListViewController.swift
//  Yangola
//
//  Created by Lasith Hettiarachchi on 8/10/17.
//  Copyright © 2017 Lasith Hettiarachchi. All rights reserved.
//

import UIKit
import ionicons

protocol ListDelegate {
    func itemSelected(at index: Int, of type: ListType?)
}

enum ListType {
    case sub, sort
}


class ListViewController: PopupParentViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var btnClose: UIBarButtonItem!
    
    var items:[ListItem] = []
    var delegate: ListDelegate?
    var type: ListType?
    
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        
        let cur = UIApplication.shared.statusBarOrientation
        if cur == UIInterfaceOrientation.landscapeLeft {
            return UIInterfaceOrientationMask.landscapeLeft
        } else if cur == UIInterfaceOrientation.landscapeRight {
            return UIInterfaceOrientationMask.landscapeRight
        } else if cur == UIInterfaceOrientation.portrait {
            return UIInterfaceOrientationMask.portrait
        } else if cur == UIInterfaceOrientation.portraitUpsideDown {
            return UIInterfaceOrientationMask.portraitUpsideDown
        }
        
        return UIInterfaceOrientationMask.all
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        self.btnClose.image = IonIcons.image(withIcon: ion_ios_close_empty, size: 35, color: UIColor.white)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ListItem", for: indexPath) as! ListItemTableViewCell
        cell.setData(item: self.items[indexPath.row])
        
        let tableSelectedView = UIView()
        tableSelectedView.backgroundColor = THEME_BACKGROUND_COLOR?.withAlphaComponent(0.3)
        cell.selectedBackgroundView = tableSelectedView
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        self.delegate?.itemSelected(at: indexPath.row, of: self.type)
        self.dismiss(animated: true, completion: nil)
    }
    

    @IBAction func close(_ sender: UIBarButtonItem) {
        
        self.dismiss(animated: true, completion: nil)
    }
    

}


