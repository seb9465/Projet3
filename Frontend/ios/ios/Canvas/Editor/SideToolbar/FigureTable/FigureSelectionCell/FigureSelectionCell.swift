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
    @IBOutlet weak var UMLClassButton: RoundedCorners!
    
    @IBOutlet weak var DashedLineButton: RoundedCorners!
    weak var delegate: FigureCellProtocol?
    
    @IBOutlet weak var ActivityClassButton: RoundedCorners!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = UITableViewCell.SelectionStyle.none
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        self.selectionStyle = UITableViewCell.SelectionStyle.none
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func UMLClassSelected(_ sender: Any) {
        self.delegate?.setSelectedFigureType(itemType: ItemTypeEnum.UMLClass)
    }
    @IBAction func ActivitySelected(_ sender: Any) {
        self.delegate?.setSelectedFigureType(itemType: ItemTypeEnum.Actor)
    }
    
    @IBAction func setSelectedLineStraigth(_ sender: Any) {
        self.StraightLineButton.layer.borderColor = UIColor.blue.cgColor
        self.StraightLineButton.layer.borderWidth = 1.0
        self.delegate?.setSelectedLineType(itemType: ItemTypeEnum.StraightLine)
        
    }
    @IBAction func setSelectedLineDashed(_ sender: Any) {
        self.DashedLineButton.layer.borderColor = UIColor.blue.cgColor
        self.DashedLineButton.layer.borderWidth = 1.0
        self.delegate?.setSelectedFigureType(itemType: ItemTypeEnum.DashedLine)
    }
}
