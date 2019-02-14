//
//  ButtonViewInterface.swift
//  ios
//
//  Created by Sebastien Cadorette on 2019-02-12.
//  Copyright © 2019 LOG3000 equipe 12. All rights reserved.
//

import UIKit

protocol ButtonViewInterface: class {
    func tapFigureButton(figureButton: UIButton);
    func tapPenButton();
    func tapClearButton();
    func tapUndoButton();
    func tapRedoButton();
}

class ButtonView: UIView {
    var delegate: ButtonViewInterface?;
    @IBOutlet var penButton: UIButton!
    @IBOutlet var figureButton: UIButton!
    
    class func instanceFromNib(_ delegate: ButtonViewInterface?) -> ButtonView {
        let buttonView: ButtonView = UINib(
                nibName: "ButtonView",
                bundle: Bundle.main
            ).instantiate(
                withOwner: self,
                options: nil
            ).first as! ButtonView;
        
        buttonView.delegate = delegate;
        
        return buttonView;
    }
    
    private func clearButtons() -> Void {
        self.penButton.setImage(UIImage(named: "Pen Icon"), for: .normal);
        self.figureButton.setImage(UIImage(named: "Figure Icon"), for: .normal);
    }
    
    @IBAction func tapFigureButton(_ sender: Any) {
        clearButtons();
        delegate?.tapFigureButton(figureButton: self.figureButton);
    }
    @IBAction func tapPenButton(_ sender: Any) {
        clearButtons();
        self.penButton.setImage(UIImage(named: "Pen Icon Black"), for: .normal);
        delegate?.tapPenButton();
    }
    @IBAction func tapClearButton(_ sender: Any) {
        clearButtons();
        delegate?.tapClearButton();
    }
    @IBAction func tapUndoButton(_ sender: Any) {
        clearButtons();
        delegate?.tapUndoButton();
    }
    @IBAction func tapRedoButton(_ sender: Any) {
        clearButtons();
        delegate?.tapRedoButton()
    }
}
