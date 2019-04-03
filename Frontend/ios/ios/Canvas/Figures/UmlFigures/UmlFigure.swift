//
//  BaseFigure.swift
//  ios
//
//  Created by William Sevigny on 2019-03-11.
//  Copyright © 2019 LOG3000 equipe 12. All rights reserved.
//

import UIKit
import GLKit
protocol TouchInputDelegate {
    func notifyTouchBegan(action: String, point: CGPoint, figure: Figure?)
    func notifyTouchMoved(point: CGPoint, figure: Figure)
    func notifyTouchEnded(point: CGPoint, figure: Figure?)
}

class UmlFigure : Figure {
//    var delegate: TouchInputDelegate?
    
    // DrawViewModel common attributes
//    var name: String!
    var figureColor: UIColor!
//    var lineColor: UIColor!
//    var lineWidth: CGFloat!
//    var oldTouchedPoint: CGPoint!
    
    var incomingConnections : [ConnectionFigure: String] = [:]
    var outgoingConnections : [ConnectionFigure: String] = [:]
    
    var currentAngle: Double = 0

    var anchorPoints: AnchorPoints?;
    
    init(firstPoint: CGPoint, lastPoint: CGPoint, width: CGFloat, height: CGFloat) {
        
        let frameSize = CGSize(width: abs(firstPoint.x - lastPoint.x), height: abs(firstPoint.y - lastPoint.y))
        let frame = CGRect(origin: firstPoint, size: frameSize)
        
        super.init(frame: frame)
        self.firstPoint = firstPoint
        self.lastPoint = lastPoint
        self.initializeBaseStyle()
        self.initializeAnchorPoints()
    }
    
    // Alternate init to create UmlFigures on user tap
    init(touchedPoint: CGPoint, width: CGFloat, height: CGFloat) {
        let frameSize = CGSize(width: width, height: height)
        let frame = CGRect(origin: CGPoint(x: touchedPoint.x - width/2, y: touchedPoint.y - height/2), size: frameSize)
        super.init(frame: frame);
        self.firstPoint = CGPoint(x: touchedPoint.x - width/2, y: touchedPoint.y - height/2)
        self.lastPoint = CGPoint(x: touchedPoint.x + width/2, y: touchedPoint.y + height/2)
        self.initializeBaseStyle()
        self.initializeAnchorPoints()
    }
    
    init(drawViewModel: DrawViewModel) {
        let firstPoint: CGPoint = drawViewModel.StylusPoints![0].getCGPoint()
        let lastPoint: CGPoint = drawViewModel.StylusPoints![1].getCGPoint()
        let frameSize = CGSize(width: abs(firstPoint.x - lastPoint.x), height: abs(firstPoint.y - lastPoint.y))
        let frame = CGRect(origin: firstPoint, size: frameSize)
        super.init(frame: frame)
        self.firstPoint = firstPoint
        self.lastPoint = lastPoint
        self.uuid = UUID(uuidString: drawViewModel.Guid!)
        self.itemType = drawViewModel.ItemType!
        self.figureColor = drawViewModel.FillColor?.getUIColor()
        self.lineColor = drawViewModel.BorderColor?.getUIColor()
        self.currentAngle = drawViewModel.Rotation!
        self.lineWidth = CGFloat(drawViewModel.BorderThickness!)
        self.backgroundColor = UIColor.clear
        self.initializeAnchorPoints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initializeBaseStyle() {
        self.figureColor = UIColor.clear
        self.lineWidth = 2
        self.lineColor = UIColor.black
        self.backgroundColor = UIColor.clear;
    }
    
    private func initializeAnchorPoints() {
        self.anchorPoints = AnchorPoints(width: self.frame.width, height: self.frame.height)
        self.layer.addSublayer((self.anchorPoints?.anchorPointsBottom)!)
        self.layer.addSublayer((self.anchorPoints?.anchorPointsTop)!)
        self.layer.addSublayer((self.anchorPoints?.anchorPointsLeft)!)
        self.layer.addSublayer((self.anchorPoints?.anchorPointsRight)!)
    }
    
    public func setFillColor(fillColor: UIColor) -> Void {
        self.figureColor = fillColor
        setNeedsDisplay();
    }
    
    public func setBorderColor(borderColor: UIColor) -> Void {
        self.lineColor = borderColor
        setNeedsDisplay();
    }

    public func translate(by: CGPoint) {
        let translatedFrame = self.frame.offsetBy(dx: by.x, dy: by.y)
        self.frame = translatedFrame
        self.firstPoint = self.frame.origin
        self.lastPoint = CGPoint(x: self.frame.maxX, y: self.frame.maxY)
        self.updateConnections()
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
        self.updateConnections()
        setNeedsDisplay()
    }
}

// Connections logic
extension UmlFigure {
    public func addIncomingConnection(connection: ConnectionFigure, anchor: String) {
        self.incomingConnections.updateValue(anchor, forKey: connection)
    }
    
    public func addOutgoingConnection(connection: ConnectionFigure, anchor: String) {
        self.outgoingConnections.updateValue(anchor, forKey: connection)
    }
    
    public func updateConnections() {
        for pair in incomingConnections {
            pair.key.updateDestination(point: convert(((self.anchorPoints?.anchorPointsSnapEdges[pair.value]!)!), to: self.superview))
        }
        
        for pair in outgoingConnections {
            pair.key.updateOrigin(point: convert(((self.anchorPoints?.anchorPointsSnapEdges[pair.value]!)!), to: self.superview))
        }
    }
    
    private func distance(a: CGPoint, b: CGPoint) -> CGFloat {
        let xDist = a.x - b.x
        let yDist = a.y - b.y
        return CGFloat(sqrt(xDist * xDist + yDist * yDist))
    }
    
    public func getClosestAnchorPoint(point: CGPoint) -> CGPoint {
        var indexToAnchor : [Int: String] = [0: "top", 1: "left", 2: "right", 3: "bottom"]
        var distances: [CGFloat] = []
        distances.append(self.distance(a: point, b: convert((self.anchorPoints?.anchorPointsSnapEdges["top"])!, to: self.superview)))
        distances.append(self.distance(a: point, b: convert((self.anchorPoints?.anchorPointsSnapEdges["left"])!, to: self.superview)))
        distances.append(self.distance(a: point, b: convert((self.anchorPoints?.anchorPointsSnapEdges["right"])!, to: self.superview)))
        distances.append(self.distance(a: point, b: convert((self.anchorPoints?.anchorPointsSnapEdges["bottom"])!, to: self.superview)))
        
        let minIndex = distances.firstIndex(of: distances.min()!)
        return convert((self.anchorPoints?.anchorPointsSnapEdges[indexToAnchor[minIndex!]!])!, to: self.superview)
    }
    
    public func getClosestAnchorPointName(point: CGPoint) -> String {
        var indexToAnchor : [Int: String] = [0: "top", 1: "left", 2: "right", 3: "bottom"]
        var distances: [CGFloat] = []
        distances.append(self.distance(a: point, b: convert((self.anchorPoints?.anchorPointsSnapEdges["top"])!, to: self.superview)))
        distances.append(self.distance(a: point, b: convert((self.anchorPoints?.anchorPointsSnapEdges["left"])!, to: self.superview)))
        distances.append(self.distance(a: point, b: convert((self.anchorPoints?.anchorPointsSnapEdges["right"])!, to: self.superview)))
        distances.append(self.distance(a: point, b: convert((self.anchorPoints?.anchorPointsSnapEdges["bottom"])!, to: self.superview)))
        
        let minIndex = distances.firstIndex(of: distances.min()!)
        return indexToAnchor[minIndex!]!
    }
}

// Touch Interaction Logic
extension UmlFigure {
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        guard let point = touch?.location(in: self) else { return }
        guard let sublayers = self.layer.sublayers as? [CAShapeLayer] else { return }
        
        for layer in sublayers{
            if let path = layer.path, path.contains(point) {
                let snapPoint = convert((self.anchorPoints?.anchorPointsSnapEdges[layer.name!])!, to: self.superview)
                self.delegate?.notifyTouchBegan(action: "anchor", point: snapPoint, figure: self)
                return
            }
        }
        
        let editorPoint = convert(point, to: self.superview)
        self.delegate?.notifyTouchBegan(action: "shape", point: editorPoint, figure: self)
    }
    
    public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        guard let point = touch?.location(in: self.superview) else { return }
        
        self.delegate?.notifyTouchMoved(point: point, figure: self)
    }
    
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        guard let point = touch?.location(in: self.superview) else { return }
        self.delegate?.notifyTouchEnded(point: point, figure: self)
    }
    
    public override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        guard let point = touch?.location(in: self.superview) else { return }
        self.delegate?.notifyTouchEnded(point: point, figure: self)
    }
}
