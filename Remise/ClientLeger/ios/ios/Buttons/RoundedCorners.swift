//
//  Register.swift
//  ios
//
//  Created by William Sevigny on 2019-01-30.
//  Copyright © 2019 LOG3000 equipe 12. All rights reserved.
//

import UIKit

public class RoundedCorners: UIButton {
    
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.layer.cornerRadius = 5;
    }
    
}
