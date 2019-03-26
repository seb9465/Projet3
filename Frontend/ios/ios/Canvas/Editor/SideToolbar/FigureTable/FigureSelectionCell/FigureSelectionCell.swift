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
    @IBOutlet weak var ActorButton: RoundedCorners!
    
    @IBOutlet weak var DashedLineButton: RoundedCorners!
    weak var delegate: FigureCellProtocol?
    
    @IBOutlet weak var ActivityButton: RoundedCorners!
    @IBOutlet weak var UMLCommentButton: RoundedCorners!
    @IBOutlet weak var ArtefactButton: RoundedCorners!
    
    @IBOutlet weak var PhaseButton: RoundedCorners!
    
    @IBOutlet weak var textButton: RoundedCorners!
    
    @IBOutlet weak var imageButton: RoundedCorners!
    
    private var lastButtonSelected: RoundedCorners!
    private var lastLineSelected: RoundedCorners!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = UITableViewCell.SelectionStyle.none
        self.lastButtonSelected = UMLClassButton
        self.setSelectedButton(button: lastButtonSelected)
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        self.selectionStyle = UITableViewCell.SelectionStyle.none
        super.setSelected(selected, animated: animated)
    }
    
    public func setSelectedButton(button: RoundedCorners) -> Void {
        self.lastButtonSelected.layer.borderWidth = 0.0
        self.lastButtonSelected = button
        self.lastButtonSelected.layer.borderColor = UIColor.blue.cgColor
        self.lastButtonSelected.layer.borderWidth = 1.0
    }
    
    @IBAction func UMLClassSelected(_ sender: Any) {
        self.delegate?.setSelectedFigureType(itemType: ItemTypeEnum.UmlClass)
        
        self.setSelectedButton(button: self.UMLClassButton)
    }
    @IBAction func ActivitySelected(_ sender: Any) {
        self.delegate?.setSelectedFigureType(itemType: ItemTypeEnum.Activity)
        self.setSelectedButton(button: self.ActivityButton)
    }
    
    @IBAction func ActorSelected(_ sender: Any) {
        self.delegate?.setSelectedFigureType(itemType: ItemTypeEnum.Role)
        self.setSelectedButton(button: self.ActorButton)
    }
    
    @IBAction func ArtefactPressed(_ sender: Any) {
        self.delegate?.setSelectedFigureType(itemType: ItemTypeEnum.Artefact)
        self.setSelectedButton(button: self.ArtefactButton)
    }
    
    @IBAction func setSelectedLineStraigth(_ sender: Any) {
        self.delegate?.setSelectedLineType(itemType: ItemTypeEnum.UniderectionalAssoication)
    }
    @IBAction func setSelectedLineDashed(_ sender: Any) {
        self.DashedLineButton.layer.borderColor = UIColor.blue.cgColor
        self.DashedLineButton.layer.borderWidth = 1.0
        self.delegate?.setSelectedFigureType(itemType: ItemTypeEnum.UniderectionalAssoication)
    }
    @IBAction func UMLCommentSelected(_ sender: Any) {
        self.delegate?.setSelectedFigureType(itemType: ItemTypeEnum.Comment)
        
        self.setSelectedButton(button: self.UMLCommentButton)
    }
    @IBAction func PhaseSelected(_ sender: Any) {
        self.delegate?.setSelectedFigureType(itemType: ItemTypeEnum.Phase)
        self.setSelectedButton(button: self.PhaseButton)
    }
    
    
    @IBAction func textSelected(_ sender: Any) {
        self.delegate?.setSelectedFigureType(itemType: ItemTypeEnum.Text)
        self.setSelectedButton(button: self.textButton)
    }
    
    @IBAction func imageSelected(_ sender: Any) {
        
        self.delegate?.presentImagePicker()
        self.delegate?.setSelectedFigureType(itemType: ItemTypeEnum.Image)
        self.setSelectedButton(button: self.imageButton)
    }
}
