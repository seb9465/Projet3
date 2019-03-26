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
    var itemType: ItemTypeEnum = ItemTypeEnum.UniderectionalAssoication
    
    init(origin: CGPoint, destination: CGPoint, itemType: ItemTypeEnum) {
        self.points.append(origin)
        self.points.append(destination)
        self.itemType = itemType
        
        // Initialize the UIView Frame
//        let frameOrigin = CGPoint(x: self.points.map { $0.x }.min()!, y: self.points.map { $0.y }.min()!)
//        let frameSize = CGSize(width: abs(destination.x - origin.x), height: abs(destination.y - origin.y))
        let frameOrigin = CGPoint(x: 0, y: 0)
        let frameSize = CGSize(width: 774, height: 698)
        let frame = CGRect(origin: frameOrigin, size: frameSize)
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.init(white: 0.0, alpha: 0.0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func getLocalInitialPoint() -> CGPoint {
        let x = (self.points[0].x < self.points[1].x) ? self.frame.width : 0
        let y = (self.points[0].y < self.points[1].y) ? self.frame.height : 0
        
        return CGPoint(x: x, y: y)
    }
    
    public func getLocalFinalPoint() -> CGPoint {
        let x = (self.points[0].x < self.points[1].x) ? 0 : self.frame.width
        let y = (self.points[0].y < self.points[1].y) ? 0 : self.frame.height
        
        return CGPoint(x: x, y: y)
    }
    
    override func draw(_ rect: CGRect) {
        //// Bezier Drawing
        let bezierPath = UIBezierPath()
        bezierPath.move(to: points[0])
        bezierPath.addLine(to: points[1])
        UIColor.black.setStroke()
        bezierPath.lineWidth = 2
        bezierPath.stroke()
//        if let context = UIGraphicsGetCurrentContext() {
//            context.setStrokeColor(UIColor.blue.cgColor)
//            context.setLineWidth(2)
//            context.beginPath()
//            context.move(to: self.getLocalInitialPoint())
//            context.addLine(to: self.getLocalFinalPoint())
//            if(itemType == ItemTypeEnum.DashedLine) {
//                context.setLineDash(phase: 0, lengths: [4,4])
//            }
//            context.strokePath()
//        }
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        return false
    }
}
