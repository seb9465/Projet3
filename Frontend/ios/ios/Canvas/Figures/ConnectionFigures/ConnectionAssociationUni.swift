//
//  ConnectionAssociationUni.swift
//  ios
//
//  Created by William Sevigny on 2019-03-21.
//  Copyright © 2019 LOG3000 equipe 12. All rights reserved.
//

import UIKit

class ConnectionAssociationUni: ConnectionFigure {
    override func draw(_ rect: CGRect) {
        if let context = UIGraphicsGetCurrentContext() {
            context.setStrokeColor(UIColor.blue.cgColor)
            context.setLineWidth(2)
            context.beginPath()
            context.move(to: self.getLocalInitialPoint())
            context.addLine(to: self.getLocalFinalPoint())
            if (itemType == ItemTypeEnum.UniderectionalAssoication) {
                context.setLineDash(phase: 0, lengths: [4,4])
            }
            context.strokePath()
        }
        
        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x: 61.5, y: 44.7))
        bezierPath.addLine(to: CGPoint(x: 75.5, y: 25.5))
        bezierPath.addLine(to: CGPoint(x: 89.5, y: 44.7))
        bezierPath.addLine(to: CGPoint(x: 75.5, y: 65.5))
        bezierPath.addLine(to: CGPoint(x: 61.5, y: 44.7))
        bezierPath.close()
        UIColor.black.setStroke()
        bezierPath.lineWidth = 1
        bezierPath.stroke()
    }
}
