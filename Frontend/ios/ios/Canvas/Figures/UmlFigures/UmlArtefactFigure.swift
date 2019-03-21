//
//  UmlArtefactFigure.swift
//  ios
//
//  Created by Sébastien Labine on 19-03-21.
//  Copyright © 2019 LOG3000 equipe 12. All rights reserved.
//

import UIKit

class UmlArtefactFigure: UmlFigure {
    private var currentAngle: Double = 0
    let BASE_WIDTH: CGFloat = 75
    let BASE_HEIGHT: CGFloat = 100
    
    init(firstPoint: CGPoint, lastPoint: CGPoint) {
        super.init(firstPoint: firstPoint, lastPoint: lastPoint, width: BASE_WIDTH, height: BASE_WIDTH)
    }
    
    init(origin: CGPoint) {
        super.init(touchedPoint: origin, width: BASE_WIDTH, height: BASE_HEIGHT)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func rotate(orientation: RotateOrientation) -> Void {
        if (orientation == RotateOrientation.right) {
            currentAngle += 90
        } else {
            currentAngle -= 90
        }
        
        if (abs(currentAngle) == 360) {
            currentAngle = 0
        }
        
        self.transform = CGAffineTransform.init(rotationAngle: CGFloat(currentAngle * Double.pi/180))
        setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        //// Bezier 2 Drawing
        let bezier2Path = UIBezierPath()
        bezier2Path.move(to: CGPoint(x: 4.5, y: 97.5))
        bezier2Path.addLine(to: CGPoint(x: 69.5, y: 97.5))
        bezier2Path.addLine(to: CGPoint(x: 69.5, y: 23.9))
        bezier2Path.addLine(to: CGPoint(x: 47.83, y: 23.9))
        bezier2Path.addLine(to: CGPoint(x: 47.5, y: 5.5))
        bezier2Path.addLine(to: CGPoint(x: 4.5, y: 5.5))
        bezier2Path.addLine(to: CGPoint(x: 4.5, y: 97.5))
        bezier2Path.close()
        UIColor.black.setStroke()
        bezier2Path.lineWidth = 1
        bezier2Path.stroke()
        
        
        //// Bezier 3 Drawing
        let bezier3Path = UIBezierPath()
        bezier3Path.move(to: CGPoint(x: 47.5, y: 5.5))
        bezier3Path.addLine(to: CGPoint(x: 69.5, y: 23.5))
        UIColor.black.setStroke()
        bezier3Path.lineWidth = 1
        bezier3Path.stroke()
    }
}
