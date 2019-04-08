//
//  CanvasResizePoints.swift
//  ios
//
//  Created by William Sevigny on 2019-03-12.
//  Copyright © 2019 LOG3000 equipe 12. All rights reserved.
//

import UIKit

class CanvasAnchor: CAShapeLayer {
    private let width: CGFloat = 30;
    
    var cornerAnchors: [CAShapeLayer] = []
    
    init(position: CGPoint) {
        super.init()
        self.path = UIBezierPath(rect: CGRect(
            x: position.x - width,
            y: position.y - width,
            width: width,
            height: width
        )).cgPath
        self.fillColor = UIColor.black.cgColor
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
