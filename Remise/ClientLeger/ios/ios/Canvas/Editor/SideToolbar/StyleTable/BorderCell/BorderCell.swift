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
    @IBOutlet weak var applyButton: RoundedCorners!
    @IBOutlet weak var thicknessSlider: UISlider!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.thicknessSlider.isContinuous = false
        self.borderColorPicker.delegate = self
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        self.selectionStyle = UITableViewCell.SelectionStyle.none
        super.setSelected(selected, animated: animated)
    }
    @IBAction func applyPickerSelected(_ sender: UIButton) {
        self.delegate?.setSelectedFigureBorderColor(color: self.applyButton.backgroundColor!)
    }
    
    @IBAction func blackSelected(_ sender: UIButton) {
        self.delegate?.setSelectedFigureBorderColor(color: UIColor.black)
    }
    
    @IBAction func whiteSelected(_ sender: UIButton) {
        self.delegate?.setSelectedFigureBorderColor(color: UIColor.white)
    }
    
    @IBAction func fullLineSelected(_ sender: UIButton) {
        self.delegate?.setSelectedFigureBorderStyle(isDashed: false)
    }
    
    @IBAction func dashedLineSelected(_ sender: UIButton) {
        self.delegate?.setSelectedFigureBorderStyle(isDashed: true)
    }

    @IBAction func thicknessChanged(_ sender: UISlider) {
        self.delegate?.setSelectedFigureLineWidth(width: CGFloat(sender.value * 10))
    }
}

extension BorderCell: SwiftHUEColorPickerDelegate {
    func valuePicked(_ color: UIColor, type: SwiftHUEColorPicker.PickerType) {
        self.applyButton.backgroundColor = color
    }
}
