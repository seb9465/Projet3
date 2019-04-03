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
    
    init(drawViewModel: DrawViewModel) {
        let firstPoint: CGPoint = drawViewModel.StylusPoints![0].getCGPoint()
        let lastPoint: CGPoint = drawViewModel.StylusPoints![1].getCGPoint()
        let frameOrigin = CGPoint(x: 0, y: 0)
        let frameSize = CGSize(width: 774, height: 698)
        let frame = CGRect(origin: frameOrigin, size: frameSize)
        super.init(frame: frame)
        self.firstPoint = firstPoint
        self.lastPoint = lastPoint
        self.uuid = UUID(uuidString: drawViewModel.Guid!)
        self.itemType = drawViewModel.ItemType!
        self.lineColor = drawViewModel.BorderColor?.getUIColor()
        self.lineWidth = CGFloat(drawViewModel.BorderThickness!)
        self.backgroundColor = UIColor.clear
        self.initializePoints(origin: firstPoint, destination: lastPoint)
        self.points.updateValue(drawViewModel.LastElbowPosition!.getCGPoint(), forKey: .ELBOW)
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
        self.anchors.updateValue(ConnectionAnchor(position: self.points[.ELBOW]!), forKey: .ELBOW)
    
        for pair in self.anchors {
            self.layer.addSublayer(pair.value)
        }
    }
    
    func updateOrigin(point: CGPoint) {
        self.points.updateValue(point, forKey: .ORIGIN)
        setNeedsDisplay()
    }
    
    func updateDestination(point: CGPoint) {
        self.points.updateValue(point, forKey: .DESTINATION)

        setNeedsDisplay()
    }
    
    override func getSelectionFrame() -> CGRect{
        var xi: CGFloat = 999999
        var yi: CGFloat = 999999
        var xf: CGFloat = -999999
        var yf: CGFloat = -999999

        // Gets origin and max point for frame
        for pair in self.points {
            if (pair.value.x < xi) {
                xi = pair.value.x
            }
            if (pair.value.y < yi) {
                yi = pair.value.y
            }
            if (pair.value.x > xf) {
                xf = pair.value.x
            }
            if (pair.value.y > yf) {
                yf = pair.value.y
            }
        }
        let origin: CGPoint = CGPoint(x: xi - 5, y: yi - 5)
        let size: CGSize = CGSize(width: abs(xf - xi) + 10, height: abs(yf - yi) + 10)

        return CGRect(origin: origin, size: size)
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
    
    override func exportViewModel() -> DrawViewModel? {
        let point1 = PolyPaintStylusPoint(point: self.points[.ORIGIN]!)
        let point2 = PolyPaintStylusPoint(point: self.points[.DESTINATION]!)
        
        var drawViewModel: DrawViewModel = DrawViewModel()
        drawViewModel.Guid = self.uuid.uuidString.lowercased()
        drawViewModel.Owner = UserDefaults.standard.string(forKey: "username")
        drawViewModel.ItemType = self.itemType
        drawViewModel.StylusPoints = [point1, point2]
        drawViewModel.FillColor = nil
        drawViewModel.BorderColor = PolyPaintColor(color: self.lineColor)
        drawViewModel.BorderThickness = Double(self.lineWidth)
        drawViewModel.BorderStyle = (self.isBorderDashed) ? "dash" : "solid"
        drawViewModel.ShapeTitle = self.name
        drawViewModel.Methods = nil
        drawViewModel.Properties = nil
        drawViewModel.SourceTitle = nil
        drawViewModel.DestinationTitle = nil
        drawViewModel.ChannelId = "general"
        drawViewModel.OutilSelectionne = nil
        drawViewModel.LastElbowPosition = PolyPaintStylusPoint(point: self.points[.ELBOW]!)
        drawViewModel.ImageBytes = nil
        drawViewModel.Rotation = nil
        return drawViewModel
    }
}

// Touch Interaction Logic
extension ConnectionFigure {
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {}
    
    public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        guard let point = touch?.location(in: self.superview) else { return }
        self.points[.ELBOW]! = point
        self.anchors[.ELBOW]!.removeFromSuperlayer()
        self.anchors[.ELBOW]! = ConnectionAnchor(position: point)
        self.layer.addSublayer(self.anchors[.ELBOW]!)
        setNeedsDisplay()
    }
    
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        guard let point = touch?.location(in: self.superview) else { return }
        self.delegate?.notifyTouchEnded(point: point, figure: self)
    }
    
    public override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {}
}
