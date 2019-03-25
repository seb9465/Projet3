//
//  AddMethodCell.swift
//  ios
//
//  Created by William Sevigny on 2019-03-15.
//  Copyright © 2019 LOG3000 equipe 12. All rights reserved.
//

import UIKit

class AddMethodCell: UITableViewCell {
    var delegate: SideToolbarDelegate?
    
    @IBOutlet weak var methodNameField: UITextField!
    
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
        if (self.methodNameField.text == "") {
            return
        }
        
        self.delegate?.addClassMethod(name: self.methodNameField.text!)
        self.methodNameField.text = ""
    }
}
