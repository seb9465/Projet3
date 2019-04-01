//
//  UmlActivityFigure.swift
//  ios
//
//  Created by William Sevigny on 2019-03-21.
//  Copyright © 2019 LOG3000 equipe 12. All rights reserved.
//

import UIKit

class UmlActivityFigure: UmlFigure {
    let BASE_WIDTH: CGFloat = 125
    let BASE_HEIGHT: CGFloat = 80
    
    init(firstPoint: CGPoint, lastPoint: CGPoint) {
        super.init(firstPoint: firstPoint, lastPoint: lastPoint, width: BASE_WIDTH, height: BASE_WIDTH)
        self.figureID = Constants.figureIDCounter;
        Constants.figureIDCounter += 1;
    }
    
    init(origin: CGPoint) {
        super.init(touchedPoint: origin, width: BASE_WIDTH, height: BASE_HEIGHT)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        //// Bezier Drawing
        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x: 7.5, y: 41.11))
        bezierPath.addLine(to: CGPoint(x: 22.53, y: 10.5))
        bezierPath.addLine(to: CGPoint(x: 104.5, y: 10.5))
        bezierPath.addLine(to: CGPoint(x: 89.47, y: 41.11))
        bezierPath.addLine(to: CGPoint(x: 104.5, y: 68.5))
        bezierPath.addLine(to: CGPoint(x: 22.53, y: 68.5))
        bezierPath.addLine(to: CGPoint(x: 7.5, y: 41.11))
        bezierPath.close()
        UIColor.black.setStroke()
        bezierPath.lineWidth = 1
        bezierPath.stroke()
    }
}

