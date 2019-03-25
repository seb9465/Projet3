//
//  AddAttributeCell.swift
//  ios
//
//  Created by William Sevigny on 2019-03-19.
//  Copyright © 2019 LOG3000 equipe 12. All rights reserved.
//

import UIKit

class AddAttributeCell: UITableViewCell {
    var delegate: SideToolbarDelegate?
    @IBOutlet weak var attibuteNameField: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        self.selectionStyle = UITableViewCell.SelectionStyle.none
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func addButtonPressed(_ sender: UIButton) {
        if (self.attibuteNameField.text == "") {
            return
        }
        
        self.delegate?.addClassAttribute(name: self.attibuteNameField.text!)
        self.attibuteNameField.text = ""
    }
}
