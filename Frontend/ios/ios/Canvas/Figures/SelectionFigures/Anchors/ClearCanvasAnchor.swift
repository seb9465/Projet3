//
//  ClearCanvasAnchor.swift
//  ios
//
//  Created by William Sevigny on 2019-04-08.
//  Copyright © 2019 LOG3000 equipe 12. All rights reserved.
//

import UIKit

class ClearCanvasAnchor: CAShapeLayer {
    private var radius: CGFloat = 30;
    
    init(position: CGPoint) {
        super.init()
        self.path = UIBezierPath(ovalIn: CGRect(
            x: position.x - radius,
            y: position.y - radius,
            width: self.radius * 2,
            height: self.radius * 2
        )).cgPath
        self.fillColor = UIColor.clear.cgColor
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
