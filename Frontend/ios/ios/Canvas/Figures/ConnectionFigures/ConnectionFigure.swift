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
    private let fontSize: CGFloat = 12
    
    var points: [Vertice: CGPoint] = [:]
    var anchors: [Vertice: ConnectionAnchor] = [:]
    var nameLabel: UILabel!
    var sourceLabel: UILabel!
    var destinationLabel: UILabel!
    
    init(origin: CGPoint, destination: CGPoint, itemType: ItemTypeEnum) {
        let frameOrigin = CGPoint(x: 0, y: 0)
        let frameSize = CGSize(width: 774, height: 698)
        let frame = CGRect(origin: frameOrigin, size: frameSize)
        super.init(frame: frame)
        self.backgroundColor = UIColor.init(white: 0.0, alpha: 0.0)
        self.itemType = itemType
        self.firstPoint = origin
        self.lastPoint = destination
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
        self.name = drawViewModel.ShapeTitle!
        self.destinationName = drawViewModel.DestinationTitle!
        self.sourceName = drawViewModel.SourceTitle!
        self.firstPoint = firstPoint
        self.lastPoint = lastPoint
        self.uuid = UUID(uuidString: drawViewModel.Guid!)
        self.itemType = drawViewModel.ItemType!
        self.lineColor = drawViewModel.BorderColor?.getUIColor()
        self.lineWidth = CGFloat(drawViewModel.BorderThickness!)
        self.isBorderDashed = (drawViewModel.BorderStyle! == "dash") ? true : false
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
    
    override func translate(by: CGPoint) {
        let newOrigin: CGPoint = CGPoint(x: self.points[.ORIGIN]!.x + by.x, y: self.points[.ORIGIN]!.y + by.y)
        let newElbow: CGPoint = CGPoint(x: self.points[.ELBOW]!.x + by.x, y: self.points[.ELBOW]!.y + by.y)
        let newDestination: CGPoint = CGPoint(x: self.points[.DESTINATION]!.x + by.x, y: self.points[.DESTINATION]!.y + by.y)
        self.points.updateValue(newOrigin, forKey: .ORIGIN)
        self.points.updateValue(newElbow, forKey: .ELBOW)
        self.points.updateValue(newDestination, forKey: .DESTINATION)
        self.updateElbowAnchor(point: newElbow)
        setNeedsDisplay()
    }
    
    func updateOrigin(point: CGPoint) {
        self.points.updateValue(point, forKey: .ORIGIN)
        setNeedsDisplay()
    }
    
    func updateDestination(point: CGPoint) {
        self.points.updateValue(point, forKey: .DESTINATION)

        setNeedsDisplay()
    }
    
    func updateElbowAnchor(point: CGPoint) {
        self.anchors[.ELBOW]!.removeFromSuperlayer()
        self.anchors[.ELBOW]! = ConnectionAnchor(position: point)
        self.layer.addSublayer(self.anchors[.ELBOW]!)
        self.points[.ELBOW]! = point
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
    
    func isOriginAnchored(umlFigures: [UmlFigure]) -> Bool {
        for umlFigure in umlFigures {
            if (umlFigure.outgoingConnections[self] != nil) {
                return true
            }
        }
        return false
    }
    
    func isDestinationAnchored(umlFigures: [UmlFigure]) -> Bool {
        for umlFigure in umlFigures {
            if (umlFigure.incomingConnections[self] != nil) {
                return true
            }
        }
        return false
    }
    
    func removeFromConnectedFigures(umlFigures: [UmlFigure]) {
        for umlFigure in umlFigures {
            umlFigure.removeConnection(connection: self)
        }
    }
    
    func isPointOnElbow(point: CGPoint) -> Bool{
        for layer in self.layer.sublayers!{
            if (layer is CAShapeLayer) {
                if let path = (layer as! CAShapeLayer).path, path.contains(point) {
                    return true
                }
            }
        }
        return false
    }
    
    func drawNameLabel() {
        if (self.nameLabel != nil) {
            self.nameLabel.removeFromSuperview()
        }
        let labelOrigin = CGPoint(x: self.points[.ELBOW]!.x, y: self.points[.ELBOW]!.y - 15)
        let labeSize = CGSize(width: 75, height: 15)
        let labelFrame = CGRect(origin: labelOrigin, size: labeSize)
        
        self.nameLabel = UILabel(frame: labelFrame)
        self.nameLabel.isUserInteractionEnabled = false
        self.nameLabel.text = self.name
        self.nameLabel.font = self.nameLabel.font.withSize(fontSize)
        self.nameLabel.textAlignment = .left
        self.nameLabel.backgroundColor = UIColor.clear
        
        let dx = points[.DESTINATION]!.x - points[.ELBOW]!.x
        let dy = points[.DESTINATION]!.y - points[.ELBOW]!.y
        let angle = atan2(dy, dx)
        self.nameLabel.setAnchorPoint(CGPoint(x: 0, y: 1))
        self.nameLabel.transform = CGAffineTransform(rotationAngle: angle)
        
        self.addSubview(self.nameLabel)
    }
    
    func drawSourceLabel() {
        if (self.sourceLabel != nil) {
            self.sourceLabel.removeFromSuperview()
        }
        let labelOrigin = CGPoint(x: self.points[.ORIGIN]!.x, y: self.points[.ORIGIN]!.y - 15)
        let labeSize = CGSize(width: 75, height: 15)
        let labelFrame = CGRect(origin: labelOrigin, size: labeSize)
        
        self.sourceLabel = UILabel(frame: labelFrame)
        self.sourceLabel.isUserInteractionEnabled = false
        self.sourceLabel.text = "self.name"
        self.sourceLabel.font = self.nameLabel.font.withSize(fontSize)
        self.sourceLabel.textAlignment = .right
        self.sourceLabel.backgroundColor = UIColor.clear
        
        let dx = points[.ELBOW]!.x - points[.ORIGIN]!.x
        let dy = points[.ELBOW]!.y - points[.ORIGIN]!.y
        let angle = atan2(dy, dx)
        self.sourceLabel.setAnchorPoint(CGPoint(x: 0, y: 1))
        self.sourceLabel.transform = CGAffineTransform(rotationAngle: angle)
        
        self.addSubview(self.sourceLabel)
    }
    
    func drawDestinationLabel() {
        if (self.destinationLabel != nil) {
            self.destinationLabel.removeFromSuperview()
        }
        let labelOrigin = CGPoint(x: self.points[.DESTINATION]!.x - 75, y: self.points[.DESTINATION]!.y - 15)
        let labeSize = CGSize(width: 75, height: 15)
        let labelFrame = CGRect(origin: labelOrigin, size: labeSize)
        
        self.destinationLabel = UILabel(frame: labelFrame)
        self.destinationLabel.isUserInteractionEnabled = false
        self.destinationLabel.text = "self.name"
        self.destinationLabel.font = self.nameLabel.font.withSize(fontSize)
        self.destinationLabel.textAlignment = .left
        self.destinationLabel.backgroundColor = UIColor.clear
        
        let dx = points[.DESTINATION]!.x - points[.ELBOW]!.x
        let dy = points[.DESTINATION]!.y - points[.ELBOW]!.y
        let angle = atan2(dy, dx)
        self.destinationLabel.setAnchorPoint(CGPoint(x: 1, y: 1))
        self.destinationLabel.transform = CGAffineTransform(rotationAngle: angle)
        
        self.addSubview(self.destinationLabel)
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
        for layer in self.layer.sublayers!{
            if (layer is CAShapeLayer) {
                if let path = (layer as! CAShapeLayer).path, path.contains(point) {
                    return true
                }
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
        drawViewModel.FillColor = PolyPaintColor(color: UIColor.clear)
        drawViewModel.BorderColor = PolyPaintColor(color: self.lineColor)
        drawViewModel.BorderThickness = Double(self.lineWidth)
        drawViewModel.BorderStyle = (self.isBorderDashed) ? "dash" : "solid"
        drawViewModel.ShapeTitle = self.name
        drawViewModel.Methods = nil
        drawViewModel.Properties = nil
        drawViewModel.SourceTitle = self.sourceName
        drawViewModel.DestinationTitle = self.destinationName
        drawViewModel.ChannelId = canvasId
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
//        let touch = touches.first
//        guard let point = touch?.location(in: self.superview) else { return }
//        self.points[.ELBOW]! = point
//        self.updateElbowAnchor(point: point)
//        setNeedsDisplay()
    }
    
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        guard let point = touch?.location(in: self.superview) else { return }
        self.delegate?.notifyTouchEnded(point: point, figure: self)
    }
    
    public override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {}
}

extension UIView {
    func setAnchorPoint(_ point: CGPoint) {
        var newPoint = CGPoint(x: bounds.size.width * point.x, y: bounds.size.height * point.y)
        var oldPoint = CGPoint(x: bounds.size.width * layer.anchorPoint.x, y: bounds.size.height * layer.anchorPoint.y);
        
        newPoint = newPoint.applying(transform)
        oldPoint = oldPoint.applying(transform)
        
        var position = layer.position
        
        position.x -= oldPoint.x
        position.x += newPoint.x
        
        position.y -= oldPoint.y
        position.y += newPoint.y
        
        layer.position = position
        layer.anchorPoint = point
    }
}
