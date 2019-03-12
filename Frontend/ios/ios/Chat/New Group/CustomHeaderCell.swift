//
//  CustomHeaderCell.swift
//  ios
//
//  Created by Sebastien Cadorette on 2019-03-10.
//  Copyright © 2019 LOG3000 equipe 12. All rights reserved.
//

import UIKit

class CustomHeaderCell: UITableViewCell {

    @IBOutlet var customHeaderCell: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.customHeaderCell.backgroundColor = UIColor.white;
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
