//
//  MenuViewController.swift
//  Yangola
//
//  Created by Lasith Hettiarachchi on 8/15/17.
//  Copyright © 2017 Lasith Hettiarachchi. All rights reserved.
//

import UIKit
import ionicons

enum MenuItem: String {
    case download="Download(coming soon)",settings="Settings",Instructions="How to use - Instructions",credits="Credits",contact="Contact"
}

protocol MenuDelegate {
    func menuItemSeleceted(item: MenuItem)
}

class MenuViewController: ParentViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var btnClose: UIBarButtonItem!
    
    var delegate: MenuDelegate?
    
    var items1: [MenuItem] = [MenuItem(rawValue: "Download(coming soon)")!]
    var items2: [MenuItem] = [MenuItem(rawValue: "Settings")!,MenuItem(rawValue: "How to use - Instructions")!,MenuItem(rawValue: "Credits")!,MenuItem(rawValue: "Contact")!]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        super.logEvent(with: "Menu")
        
        self.btnClose.image = IonIcons.image(withIcon: ion_ios_close_empty, size: 35, color: UIColor.white)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0 {
            return items1.count
        } else {
            return items2.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "MenuCell")!
        if indexPath.section == 0 {
            cell.textLabel?.text = self.items1[indexPath.row].rawValue
        } else if indexPath.section == 1 {
            cell.textLabel?.text = self.items2[indexPath.row].rawValue
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        DispatchQueue.main.async {
            if indexPath.section == 0 {
                self.delegate?.menuItemSeleceted(item: self.items1[indexPath.row])
            } else {
                self.delegate?.menuItemSeleceted(item: self.items2[indexPath.row])
            }
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if section == 0 {
            return 0
        } else {
            return 50
        }
    }
    
    
    @IBAction func close(_ sender: UIBarButtonItem) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
}

