//
//  CreditsTableViewCell.swift
//  Yangola
//
//  Created by Lasith Hettiarachchi on 8/8/17.
//  Copyright © 2017 Lasith Hettiarachchi. All rights reserved.
//

import UIKit

protocol CreditsCellDelegate {
    func visitUrl(url: String)
}

class CreditsTableViewCell: UITableViewCell {

    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblDesc: UILabel!
    @IBOutlet weak var lblUrl: UILabel!
    
    var lib: Library?
    var delegate: CreditsCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func setData(library: Library, delegate: CreditsCellDelegate) {
        
        lblName.text = library.name
        lblDesc.text = library.desc
        lblUrl.text = library.url
        self.delegate = delegate
        self.lib = library
    }
    
    @IBAction func visitUrl(_ sender: UIButton) {
        
        if let url = self.lib?.url {
            delegate?.visitUrl(url: url)
        }
    }
}
