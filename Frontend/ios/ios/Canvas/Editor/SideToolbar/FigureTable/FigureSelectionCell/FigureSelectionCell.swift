//
//  FigureSelectionCell.swift
//  ios
//
//  Created by William Sevigny on 2019-03-19.
//  Copyright © 2019 LOG3000 equipe 12. All rights reserved.
//

import UIKit

class FigureSelectionCell: UITableViewCell {
    @IBOutlet weak var StraightLineButton: RoundedCorners!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = UITableViewCell.SelectionStyle.none
    }

    @IBAction func setSelectedLineDashed(_ sender: Any) {
        self.StraightLineButton.layer.borderColor = UIColor.blue.cgColor
        self.StraightLineButton.layer.borderWidth = 1.0
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
