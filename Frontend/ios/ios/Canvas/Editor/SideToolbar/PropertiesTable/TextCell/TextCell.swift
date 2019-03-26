//
//  TextCellTableViewCell.swift
//  ios
//
//  Created by Sébastien Labine on 19-03-26.
//  Copyright © 2019 LOG3000 equipe 12. All rights reserved.
//

import UIKit

class TextCell: UITableViewCell {

    @IBOutlet weak var TextBoxField: UITextField!
    
    var delegate: SideToolbarDelegate?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBAction func TextChanged(_ sender: UITextField) {
        delegate?.setSelectedText(text: sender.text!)
    }
    
}
