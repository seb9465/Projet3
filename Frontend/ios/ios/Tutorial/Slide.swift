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
    
    // MARK: - Outlets
    
    @IBOutlet var imageView: UIImageView!;
    @IBOutlet var labelTitle: UILabel!;
    @IBOutlet var labelDesc: UILabel!;
    @IBOutlet var getStartedButon: UIButton!
    
    // MARK: - Constructors
    
    override init(frame: CGRect) {
        self.labelTitle.textColor = Constants.RED_COLOR;
        self.labelDesc.textColor = Constants.RED_COLOR;
        
        
        
        super.init(frame: frame);
        
        self.initGetStartedButton();
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Timing functions
    
    // MARK: - Public functions
    
    // MARK: - Private functions
    
    private func initGetStartedButton() -> Void {
        self.getStartedButon.tintColor = UIColor.white.cgColor;
        self.getStartedButon.layer.backgroundColor = Constants.RED_COLOR;
        
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
