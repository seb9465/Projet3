//
//  ConnectionFigure.swift
//  ios
//
//  Created by William Sevigny on 2019-03-12.
//  Copyright © 2019 LOG3000 equipe 12. All rights reserved.
//

import UIKit

enum Vertice {
    case ORIGIN
    case ELBOW
    case DESTINATION
}

class ConnectionFigure : Figure {
    
    var points: [Vertice: CGPoint] = [:]
    var anchors: [Vertice: ConnectionAnchor] = [:]
    var itemType: ItemTypeEnum = ItemTypeEnum.UniderectionalAssoication
    
    init(origin: CGPoint, destination: CGPoint, itemType: ItemTypeEnum) {
        let frameOrigin = CGPoint(x: 0, y: 0)
        let frameSize = CGSize(width: 774, height: 698)
        let frame = CGRect(origin: frameOrigin, size: frameSize)
        super.init(frame: frame)
        self.backgroundColor = UIColor.init(white: 0.0, alpha: 0.0)
        self.itemType = itemType
        self.initializePoints(origin: origin, destination: destination)
        self.initializeAnchors()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initializePoints(origin: CGPoint, destination: CGPoint) {
        let elbow: CGPoint = CGPoint(x: (origin.x + destination.x)/2, y: (origin.y + destination.y)/2)
        self.points.updateValue(origin, forKey: .ORIGIN)
        self.points.updateValue(destination, forKey: .DESTINATION)
        self.points.updateValue(elbow, forKey: .ELBOW)
    }
    
    private func initializeAnchors() {
        self.anchors.updateValue(ConnectionAnchor(position: self.points[.ORIGIN]!), forKey: .ORIGIN)
        self.anchors.updateValue(ConnectionAnchor(position: self.points[.ELBOW]!), forKey: .ELBOW)
        self.anchors.updateValue(ConnectionAnchor(position: self.points[.DESTINATION]!), forKey: .DESTINATION)
        
        for pair in self.anchors {
            self.layer.addSublayer(pair.value)
        }
    }
    
    func updateOrigin(point: CGPoint) {
        self.points.updateValue(point, forKey: .ORIGIN)
        self.anchors[.ORIGIN]!.removeFromSuperlayer()
        self.anchors[.ORIGIN]! = ConnectionAnchor(position: point)
        self.layer.addSublayer(self.anchors[.ORIGIN]!)
        setNeedsDisplay()
    }
    
    func updateDestination(point: CGPoint) {
        self.points.updateValue(point, forKey: .DESTINATION)
        self.anchors[.DESTINATION]!.removeFromSuperlayer()
        self.anchors[.DESTINATION]! = ConnectionAnchor(position: point)
        self.layer.addSublayer(self.anchors[.DESTINATION]!)
        setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        //// Bezier Drawing
        let bezierPath = UIBezierPath()
        bezierPath.move(to: points[.ORIGIN]!)
        bezierPath.addLine(to: points[.ELBOW]!)
        bezierPath.addLine(to: points[.DESTINATION]!)
        UIColor.black.setStroke()
        bezierPath.lineWidth = 2
        bezierPath.stroke()
    }
    
    // Only fire touchedBegan when user taps on an anchor
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        guard let sublayers = self.layer.sublayers as? [CAShapeLayer] else { return false }
        for layer in sublayers{
            if let path = layer.path, path.contains(point) {
                return true
            }
        }
        return false
    }
}

// Touch Interaction Logic
extension ConnectionFigure {
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("ELBOW TOUCHED")
    }
    
    public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        guard let point = touch?.location(in: self.superview) else { return }
        self.points[.ELBOW]! = point
        self.anchors[.ELBOW]!.removeFromSuperlayer()
        self.anchors[.ELBOW]! = ConnectionAnchor(position: point)
        self.layer.addSublayer(self.anchors[.ELBOW]!)
        setNeedsDisplay()
    }
    
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {}
    
    public override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {}
}
