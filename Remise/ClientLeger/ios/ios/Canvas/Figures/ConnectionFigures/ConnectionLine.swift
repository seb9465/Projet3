//
//  ConnectionLine.swift
//  ios
//
//  Created by William Sevigny on 2019-04-06.
//  Copyright © 2019 LOG3000 equipe 12. All rights reserved.
//

import UIKit

class ConnectionLine : ConnectionFigure {
    override func draw(_ rect: CGRect) {
        let bezierPath = UIBezierPath()
        bezierPath.move(to: points[.ORIGIN]!)
        bezierPath.addLine(to: points[.ELBOW]!)
        bezierPath.addLine(to: points[.DESTINATION]!)
        
        self.lineColor.setStroke()
        if (self.isBorderDashed) {
            bezierPath.setLineDash([4,4], count: 1, phase: 0)
        }

        bezierPath.lineWidth = self.lineWidth
        bezierPath.stroke()
        
        self.drawNameLabel()
        self.drawSourceLabel()
        self.drawDestinationLabel()
    }
}
