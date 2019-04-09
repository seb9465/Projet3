//
//  FillCell.swift
//  ios
//
//  Created by William Sevigny on 2019-03-26.
//  Copyright © 2019 LOG3000 equipe 12. All rights reserved.
//

import UIKit
import SwiftHUEColorPicker

class FillCell: UITableViewCell {
    var delegate: SideToolbarDelegate?

    @IBOutlet weak var fillColorPicker: SwiftHUEColorPicker!
    @IBOutlet weak var applyButtom: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.fillColorPicker.delegate = self
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        self.selectionStyle = UITableViewCell.SelectionStyle.none
        super.setSelected(selected, animated: animated)
    }

    
    @IBAction func blackSelected(_ sender: UIButton) {
        self.delegate?.setSelectedFigureFillColor(color: UIColor.black)
    }
    
    @IBAction func whiteSelected(_ sender: UIButton) {
        self.delegate?.setSelectedFigureFillColor(color: UIColor.white)
    }
    
    @IBAction func applySelected(_ sender: UIButton) {
    self.delegate?.setSelectedFigureFillColor(color: self.applyButtom.backgroundColor!)
    }
    
}

extension FillCell: SwiftHUEColorPickerDelegate {
    func valuePicked(_ color: UIColor, type: SwiftHUEColorPicker.PickerType) {
        self.applyButtom.backgroundColor = color
    }
}
