//
//  ConnectionHeritage.swift
//  ios
//
//  Created by William Sevigny on 2019-03-21.
//  Copyright © 2019 LOG3000 equipe 12. All rights reserved.
//

import UIKit

class ConnectionHeritage: ConnectionFigure {
    override func draw(_ rect: CGRect) {
        self.lineColor.setStroke()
        let bezierPath = UIBezierPath()
        let bezierPath2 = UIBezierPath()
        
        bezierPath.move(to: points[.ORIGIN]!)
        bezierPath.addLine(to: points[.ELBOW]!)
        bezierPath.addLine(to: points[.DESTINATION]!)
        bezierPath.lineWidth = self.lineWidth
        
        
        let arrowLength: CGFloat = 14
        let dx = points[.DESTINATION]!.x - points[.ELBOW]!.x
        let dy = points[.DESTINATION]!.y - points[.ELBOW]!.y
        let theta = atan2(dy, dx)
        let rad1 = CGFloat((Float.pi / 180) * -35)
        let x = points[.DESTINATION]!.x - arrowLength * CGFloat(cos(theta + rad1))
        let y = points[.DESTINATION]!.y - arrowLength * CGFloat(sin(theta + rad1))
        
        let rad2 = CGFloat((Float.pi / 180) * 35)
        let x2 = points[.DESTINATION]!.x - arrowLength * CGFloat(cos(theta + rad2))
        let y2 = points[.DESTINATION]!.y - arrowLength * CGFloat(sin(theta + rad2))
        
        let midx = (x2 + x) / 2
        let midy = (y2 + y) / 2
        
        if (self.isBorderDashed) {
            bezierPath.setLineDash([4,4], count: 1, phase: 0)
            bezierPath2.setLineDash([4,4], count: 1, phase: 0)
        }
        
        bezierPath.stroke()
        
//        bezierPath2.move(to: CGPoint(x: midx - (points[.DESTINATION]!.x - midx), y: midy - (points[.DESTINATION]!.y - midy)))
        bezierPath2.move(to: CGPoint(x: x, y: y))
        bezierPath2.addLine(to: points[.DESTINATION]!)
        bezierPath2.addLine(to: CGPoint(x: x2, y: y2))
        bezierPath2.addLine(to: CGPoint(x: x, y: y))
        bezierPath2.close()
        UIColor.white.setFill()
        bezierPath2.fill()
        bezierPath2.lineWidth = self.lineWidth
        bezierPath2.stroke()
        
        self.drawNameLabel()
        self.drawSourceLabel()
        self.drawDestinationLabel()
    }
}
