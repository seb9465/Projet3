//
//  ConnectionAssociationBi.swift
//  ios
//
//  Created by William Sevigny on 2019-03-21.
//  Copyright © 2019 LOG3000 equipe 12. All rights reserved.
//

import UIKit

class ConnectionAssociationBi: ConnectionFigure {
    override func draw(_ rect: CGRect) {
        self.lineColor.setStroke()
        let bezierPath = UIBezierPath()
        let bezierPath2 = UIBezierPath()
        let bezierPath3 = UIBezierPath()
        
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
        
        if (self.isBorderDashed) {
            bezierPath.setLineDash([4,4], count: 1, phase: 0)
            bezierPath2.setLineDash([4,4], count: 1, phase: 0)
            bezierPath3.setLineDash([4,4], count: 1, phase: 0)
        }
        bezierPath.stroke()
        
        bezierPath2.move(to: CGPoint(x: x, y: y))
        bezierPath2.addLine(to: points[.DESTINATION]!)
        bezierPath2.addLine(to: CGPoint(x: x2, y: y2))
        bezierPath2.lineWidth = self.lineWidth
        bezierPath2.stroke()
        
        let dx_origin = points[.ELBOW]!.x - points[.ORIGIN]!.x
        let dy_origin = points[.ELBOW]!.y - points[.ORIGIN]!.y
        let theta_origin = atan2(dy_origin, dx_origin)
        let rad1_origin = CGFloat((Float.pi / 180) * -35)
        let x_origin = points[.ORIGIN]!.x + arrowLength * CGFloat(cos(theta_origin + rad1_origin))
        let y_origin = points[.ORIGIN]!.y + arrowLength * CGFloat(sin(theta_origin + rad1_origin))
        
        let rad2_origin = CGFloat((Float.pi / 180) * 35)
        let x2_origin = points[.ORIGIN]!.x + arrowLength * CGFloat(cos(theta_origin + rad2_origin))
        let y2_origin = points[.ORIGIN]!.y + arrowLength * CGFloat(sin(theta_origin + rad2_origin))
        
        bezierPath3.move(to: CGPoint(x: x_origin, y: y_origin))
        bezierPath3.addLine(to: points[.ORIGIN]!)
        bezierPath3.addLine(to: CGPoint(x: x2_origin, y: y2_origin))
        bezierPath3.lineWidth = self.lineWidth
        bezierPath3.stroke()
        
        self.drawNameLabel()
        self.drawSourceLabel()
        self.drawDestinationLabel()
    }
}
