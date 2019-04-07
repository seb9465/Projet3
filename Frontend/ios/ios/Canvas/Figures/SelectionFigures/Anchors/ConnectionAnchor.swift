//
//  AnchorPoint.swift
//  ios
//
//  Created by William Sevigny on 2019-03-29.
//  Copyright © 2019 LOG3000 equipe 12. All rights reserved.
//

import UIKit

class ConnectionAnchor: CAShapeLayer {
    private var radius: CGFloat = 10;
    
    init(position: CGPoint) {
        super.init()
        self.path = UIBezierPath(ovalIn: CGRect(
            x: position.x - radius,
            y: position.y - radius,
            width: self.radius * 2,
            height: self.radius * 2
        )).cgPath
        self.fillColor = UIColor.red.cgColor
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
