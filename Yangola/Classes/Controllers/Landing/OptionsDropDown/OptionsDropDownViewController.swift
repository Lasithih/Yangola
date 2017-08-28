//
//  OptionsDropDownViewController.swift
//  Yangola
//
//  Created by Lasith Hettiarachchi on 2/10/17.
//  Copyright © 2017 Lasith Hettiarachchi. All rights reserved.
//

import UIKit
import ionicons

protocol OptionsDropdownDelegate {
    func itemSelected(item: OptionsDropdownItem)
}

class OptionsDropDownViewController: UIViewController {

    var dropdownItems: [OptionsDropdownItem] = []
    var delegate: OptionsDropdownDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let itemSelect = OptionsDropdownItem(title: OptionsDropdownOption.Select.rawValue, image: IonIcons.image(withIcon: ion_ios_checkmark_outline, size: 30, color: UIColor.white))
        self.dropdownItems.append(itemSelect)
        
        let itemSort = OptionsDropdownItem(title: OptionsDropdownOption.Sort.rawValue, image: IonIcons.image(withIcon: ion_ios_arrow_down, size: 30, color: UIColor.white))
        self.dropdownItems.append(itemSort)
        
        let newFolder = OptionsDropdownItem(title: OptionsDropdownOption.NewFolder.rawValue, image: IonIcons.image(withIcon: ion_ios_plus_outline, size: 30, color: UIColor.white))
        self.dropdownItems.append(newFolder)
        
    }
}


extension OptionsDropDownViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.dropdownItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "dropdownItem") as! OptionsDropdownItemTableViewCell
        
        cell.setValues(dropdownItem: self.dropdownItems[indexPath.row])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let selected = self.dropdownItems[indexPath.row]
        self.delegate?.itemSelected(item: selected)
    }
}
