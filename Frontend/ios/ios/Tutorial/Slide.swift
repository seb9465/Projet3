//
//  Slide.swift
//  ios
//
//  Created by Sebastien Cadorette on 2019-04-07.
//  Copyright © 2019 LOG3000 equipe 12. All rights reserved.
//

import UIKit

class Slide: UIView {

    // MARK: - Attributes
    
    private var _getStartedBtnAction: (() -> ())!;
    
    // MARK: - Getter - Setter
    
    public var getStartedBtnAction: (() -> ()) {
        get { return self._getStartedBtnAction }
        set { self._getStartedBtnAction = newValue }
    }
    
    // MARK: - Outlets
    
    @IBOutlet var imageView: UIImageView!;
    @IBOutlet var labelTitle: UILabel!;
    @IBOutlet var labelDesc: UILabel!;
    @IBOutlet var getStartedButon: UIButton!
    
    // MARK: - Timing functions
    
    // MARK: - Public functions
    
    public func initSlide() -> Void {
        self.initLabels();
        self.initGetStartedButton();
    }
    
    // MARK: - Private functions
    
    private func initLabels() -> Void {
        self.labelTitle.textColor = Constants.Colors.RED_COLOR;
        self.labelDesc.textColor = Constants.Colors.RED_COLOR;
    }
    
    private func initGetStartedButton() -> Void {
        self.getStartedButon.tintColor = UIColor.white;
        self.getStartedButon.layer.backgroundColor = Constants.Colors.RED_COLOR.cgColor;
        self.getStartedButon.layer.cornerRadius = 5.0;
        self.getStartedButon.layer.borderWidth = 0.0;
        self.getStartedButon.layer.borderColor = UIColor.clear.cgColor;
        self.getStartedButon.isHidden = true;
    }
    
    // MARK: - Action functions
    
    @IBAction func getStartedButton(_ sender: Any) {
        self._getStartedBtnAction();
    }
}
