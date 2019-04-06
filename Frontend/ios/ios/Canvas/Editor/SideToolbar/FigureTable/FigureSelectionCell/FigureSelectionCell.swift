//
//  FigureSelectionCell.swift
//  ios
//
//  Created by William Sevigny on 2019-03-19.
//  Copyright © 2019 LOG3000 equipe 12. All rights reserved.
//

import UIKit

class FigureSelectionCell: UITableViewCell {
    weak var delegate: FigureCellProtocol?

    @IBOutlet weak var UMLClassButton: RoundedCorners!
    @IBOutlet weak var ActorButton: RoundedCorners!
    @IBOutlet weak var ActivityButton: RoundedCorners!
    @IBOutlet weak var UMLCommentButton: RoundedCorners!
    @IBOutlet weak var ArtefactButton: RoundedCorners!
    @IBOutlet weak var PhaseButton: RoundedCorners!
    @IBOutlet weak var textButton: RoundedCorners!
    @IBOutlet weak var imageButton: RoundedCorners!
    @IBOutlet weak var lineButton: RoundedCorners!
    
    // Connection figures
    @IBOutlet weak var heritageButton: RoundedCorners!
    @IBOutlet weak var unidirectButton: RoundedCorners!
    @IBOutlet weak var bidirectButton: RoundedCorners!
    @IBOutlet weak var agregationButton: RoundedCorners!
    @IBOutlet weak var compositionButton: RoundedCorners!
    
    private var lastButtonSelected: RoundedCorners!
    private var lastLineSelected: RoundedCorners!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = UITableViewCell.SelectionStyle.none
        self.lastButtonSelected = nil
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        self.selectionStyle = UITableViewCell.SelectionStyle.none
        super.setSelected(selected, animated: animated)
    }
    
    public func setSelectedButton(button: RoundedCorners) -> Void {
        if (self.lastButtonSelected != nil) {
            self.lastButtonSelected.layer.borderWidth = 0.0
        }
        self.lastButtonSelected = button
        self.lastButtonSelected.layer.borderColor = UIColor.black.cgColor
        self.lastButtonSelected.layer.borderWidth = 2.0
    }
    
    public func deselectButtons() {
        if (self.lastButtonSelected != nil) {
            self.lastButtonSelected.layer.borderWidth = 0.0
        }
        self.lastButtonSelected = nil
    }
    
    @IBAction func UMLClassSelected(_ sender: Any) {
        self.delegate?.setSelectedFigureType(itemType: ItemTypeEnum.UmlClass, isConnection: false)
        self.setSelectedButton(button: self.UMLClassButton)
    }

    @IBAction func ActivitySelected(_ sender: Any) {
        self.delegate?.setSelectedFigureType(itemType: ItemTypeEnum.Activity, isConnection: false)
        self.setSelectedButton(button: self.ActivityButton)
    }
    
    @IBAction func ActorSelected(_ sender: Any) {
        self.delegate?.setSelectedFigureType(itemType: ItemTypeEnum.Role, isConnection: false)
        self.setSelectedButton(button: self.ActorButton)
    }
    
    @IBAction func ArtefactPressed(_ sender: Any) {
        self.delegate?.setSelectedFigureType(itemType: ItemTypeEnum.Artefact, isConnection: false)
        self.setSelectedButton(button: self.ArtefactButton)
    }

    @IBAction func UMLCommentSelected(_ sender: Any) {
        self.delegate?.setSelectedFigureType(itemType: ItemTypeEnum.Comment, isConnection: false)
        
        self.setSelectedButton(button: self.UMLCommentButton)
    }
    
    @IBAction func PhaseSelected(_ sender: Any) {
        self.delegate?.setSelectedFigureType(itemType: ItemTypeEnum.Phase, isConnection: false)
        self.setSelectedButton(button: self.PhaseButton)
    }
    
    @IBAction func textSelected(_ sender: Any) {
        self.delegate?.setSelectedFigureType(itemType: ItemTypeEnum.Text, isConnection: false)
        self.setSelectedButton(button: self.textButton)
    }
    
    @IBAction func imageSelected(_ sender: Any) {
        self.delegate?.presentImagePicker()
        self.delegate?.setSelectedFigureType(itemType: ItemTypeEnum.Image, isConnection: false)
        self.setSelectedButton(button: self.imageButton)
    }
    
    @IBAction func heritageSelected(_ sender: Any) {
        self.delegate?.setSelectedFigureType(itemType: ItemTypeEnum.Inheritance, isConnection: true)
        self.setSelectedButton(button: self.heritageButton)
    }
    
    @IBAction func unidirectSelected(_ sender: Any) {
        self.delegate?.setSelectedFigureType(itemType: ItemTypeEnum.UniderectionalAssoication, isConnection: true)
        self.setSelectedButton(button: self.unidirectButton)
    }
    
    @IBAction func bidirectSelected(_ sender: Any) {
        self.delegate?.setSelectedFigureType(itemType: ItemTypeEnum.BidirectionalAssociation, isConnection: true)
        self.setSelectedButton(button: self.bidirectButton)
    }
    
    @IBAction func agregationSelected(_ sender: Any) {
        self.delegate?.setSelectedFigureType(itemType: ItemTypeEnum.Agregation, isConnection: true)
        self.setSelectedButton(button: self.agregationButton)
    }
    
    @IBAction func compositionSelected(_ sender: Any) {
        self.delegate?.setSelectedFigureType(itemType: ItemTypeEnum.Composition, isConnection: true)
        self.setSelectedButton(button: self.compositionButton)
    }
    @IBAction func lineSelected(_ sender: Any) {
        self.delegate?.setSelectedFigureType(itemType: ItemTypeEnum.Line, isConnection: true)
        self.setSelectedButton(button: self.lineButton)
    }
}

extension FigureSelectionCell: SideToolbarController {
    func update() {
        self.deselectButtons()
    }
}

