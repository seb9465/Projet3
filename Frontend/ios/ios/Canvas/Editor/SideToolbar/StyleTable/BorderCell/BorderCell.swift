//
//  BorderCell.swift
//  ios
//
//  Created by William Sevigny on 2019-03-14.
//  Copyright © 2019 LOG3000 equipe 12. All rights reserved.
//

import UIKit
import SwiftHUEColorPicker

class BorderCell: UITableViewCell {
    var delegate: SideToolbarDelegate?
    @IBOutlet weak var borderColorPicker: SwiftHUEColorPicker!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.borderColorPicker.delegate = self
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        self.selectionStyle = UITableViewCell.SelectionStyle.none

        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func fullLineSelected(_ sender: UIButton) {
    }
    @IBAction func dashedLineSelected(_ sender: UIButton) {
    }
}

extension BorderCell: SwiftHUEColorPickerDelegate {
    func valuePicked(_ color: UIColor, type: SwiftHUEColorPicker.PickerType) {
        self.delegate?.setSelectedFigureBorderColor(color: color)
    }
}
