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
    
    override func awakeFromNib() {
        super.awakeFromNib()
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
    
    @IBAction func blueSelected(_ sender: UIButton) {
        self.delegate?.setSelectedFigureBorderColor(color: UIColor.blue)
    }
    
    @IBAction func greenSelected(_ sender: UIButton) {
        self.delegate?.setSelectedFigureBorderColor(color: UIColor.green)
    }
    
    @IBAction func yellowSelected(_ sender: UIButton) {
        self.delegate?.setSelectedFigureBorderColor(color: UIColor.yellow)
    }
    
    @IBAction func redSelected(_ sender: UIButton) {
        self.delegate?.setSelectedFigureBorderColor(color: UIColor.red)
    }
    
    @IBAction func blackSelected(_ sender: UIButton) {
        self.delegate?.setSelectedFigureBorderColor(color: UIColor.black)
    }
    
    @IBAction func whiteSelected(_ sender: UIButton) {
        self.delegate?.setSelectedFigureBorderColor(color: UIColor.white)
    }
    
    @IBAction func fullLineSelected(_ sender: UIButton) {
//        self.delegate.se
    }
    
    @IBAction func dashedLineSelected(_ sender: UIButton) {
    }
}

extension BorderCell: SwiftHUEColorPickerDelegate {
    func valuePicked(_ color: UIColor, type: SwiftHUEColorPicker.PickerType) {
        self.applyButton.backgroundColor = color
    }
}
