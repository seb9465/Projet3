//
//  ClassAttributeCell.swift
//  ios
//
//  Created by William Sevigny on 2019-03-19.
//  Copyright © 2019 LOG3000 equipe 12. All rights reserved.
//

import UIKit

class ClassAttributeCell: UITableViewCell {
    var delegate: SideToolbarDelegate?
    var attributeIndex: Int!

    @IBOutlet weak var attributeName: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        self.selectionStyle = UITableViewCell.SelectionStyle.none
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func removeButtonPressed(_ sender: UIButton) {
        self.delegate?.removeClassAttribute(name: "not implemented", index: self.attributeIndex)
    }
}
