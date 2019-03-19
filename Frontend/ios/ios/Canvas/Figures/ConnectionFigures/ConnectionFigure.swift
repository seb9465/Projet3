//
//  ConnectionFigure.swift
//  ios
//
//  Created by William Sevigny on 2019-03-12.
//  Copyright © 2019 LOG3000 equipe 12. All rights reserved.
//

import UIKit

class ConnectionFigure : Figure {
    
    var points: [CGPoint] = []

    init(origin: CGPoint, destination: CGPoint) {
        self.points.append(origin)
        self.points.append(destination)

        // Initialize the UIView Frame
        let frameOrigin = CGPoint(x: self.points.map { $0.x }.min()!, y: self.points.map { $0.y }.min()!)
        let frameSize = CGSize(width: abs(destination.x - origin.x), height: abs(destination.y - origin.y))
        let frame = CGRect(origin: frameOrigin, size: frameSize)
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.init(white: 0.0, alpha: 0.0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        if let context = UIGraphicsGetCurrentContext() {
            context.setStrokeColor(UIColor.blue.cgColor)
            context.setLineWidth(2)
            context.beginPath()
            context.move(to: self.getLocalInitialPoint())
            context.addLine(to: self.getLocalFinalPoint())
            context.strokePath()
        }
    }
    
    private func getLocalInitialPoint() -> CGPoint {
        let x = (self.points[0].x < self.points[1].x) ? self.frame.width : 0
        let y = (self.points[0].y < self.points[1].y) ? self.frame.height : 0
        
        return CGPoint(x: x, y: y)
    }
    
    private func getLocalFinalPoint() -> CGPoint {
        let x = (self.points[0].x < self.points[1].x) ? 0 : self.frame.width
        let y = (self.points[0].y < self.points[1].y) ? 0 : self.frame.height
        
        return CGPoint(x: x, y: y)
    }
}
