//
//  ButtonViewInterface.swift
//  ios
//
//  Created by Sebastien Cadorette on 2019-02-12.
//  Copyright © 2019 LOG3000 equipe 12. All rights reserved.
//

import UIKit

protocol ButtonViewInterface: class {
    func tapFigureButton();
    func tapPenButton();
    func tapClearButton();
    func tapUndoButton();
    func tapRedoButton();
}

class ButtonView: UIView {
    var delegate: ButtonViewInterface?;
    
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
    
    @IBAction func tapFigureButton(_ sender: Any) {
        delegate?.tapFigureButton();
    }
    @IBAction func tapPenButton(_ sender: Any) {
        delegate?.tapPenButton();
    }
    @IBAction func tapClearButton(_ sender: Any) {
        delegate?.tapClearButton();
    }
    @IBAction func tapUndoButton(_ sender: Any) {
        delegate?.tapUndoButton();
    }
    @IBAction func tapRedoButton(_ sender: Any) {
        delegate?.tapRedoButton()
    }
}
