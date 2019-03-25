//
//  UmlActorFigure.swift
//  ios
//
//  Created by William Sevigny on 2019-03-21.
//  Copyright © 2019 LOG3000 equipe 12. All rights reserved.
//

import UIKit

class UmlActorFigure: UmlFigure {
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
    
    override func draw(_ rect: CGRect) {
        //// Group
        //// Oval Drawing
        let ovalPath = UIBezierPath(ovalIn: CGRect(x: 25, y: 11.5, width: 27, height: 26))
        UIColor.black.setStroke()
        ovalPath.lineWidth = 1
        ovalPath.stroke()
        
        
        //// Bezier Drawing
        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x: 38.26, y: 39.17))
        bezierPath.addLine(to: CGPoint(x: 38.26, y: 73.75))
        UIColor.black.setStroke()
        bezierPath.lineWidth = 1
        bezierPath.stroke()
        
        
        //// Bezier 2 Drawing
        let bezier2Path = UIBezierPath()
        bezier2Path.move(to: CGPoint(x: 38.26, y: 39.17))
        bezier2Path.addLine(to: CGPoint(x: 63.5, y: 39.17))
        UIColor.black.setStroke()
        bezier2Path.lineWidth = 1
        bezier2Path.stroke()
        
        
        //// Bezier 3 Drawing
        let bezier3Path = UIBezierPath()
        bezier3Path.move(to: CGPoint(x: 10.5, y: 39.17))
        bezier3Path.addLine(to: CGPoint(x: 38.26, y: 39.17))
        UIColor.black.setStroke()
        bezier3Path.lineWidth = 1
        bezier3Path.stroke()
        
        
        //// Bezier 4 Drawing
        let bezier4Path = UIBezierPath()
        bezier4Path.move(to: CGPoint(x: 38.26, y: 73.75))
        bezier4Path.addLine(to: CGPoint(x: 18.07, y: 92.19))
        UIColor.black.setStroke()
        bezier4Path.lineWidth = 1
        bezier4Path.stroke()
        
        
        //// Bezier 5 Drawing
        let bezier5Path = UIBezierPath()
        bezier5Path.move(to: CGPoint(x: 38.26, y: 73.75))
        bezier5Path.addLine(to: CGPoint(x: 58.45, y: 94.5))
        UIColor.black.setStroke()
        bezier5Path.lineWidth = 1
        bezier5Path.stroke()
    }
}

