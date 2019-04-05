//
//  SelectionOutline.swift
//  ios
//
//  Created by William Sevigny on 2019-03-12.
//  Copyright © 2019 LOG3000 equipe 12. All rights reserved.
//

import UIKit

protocol SelectionOutlineProtocol {
    var selectedDashedBorder: CAShapeLayer! { get set }
    var selectedCornerCircle1: CAShapeLayer! { get set }
    var selectedCornerCircle2: CAShapeLayer! { get set }
    var selectedCornerCircle3: CAShapeLayer! { get set }
    var selectedCornerCircle4: CAShapeLayer! { get set }
}

class SelectionOutline: UIView {
    var delegate: TouchInputDelegate?
    
    private let radius: CGFloat = 5.0;
    public var firstPoint: CGPoint!
    public var lastPoint: CGPoint!
    public var associatedFigureID: UUID!;
    
    var border: CAShapeLayer!;
    var cornerAnchors: [CAShapeLayer] = []
    
    init(firstPoint: CGPoint, lastPoint: CGPoint, associatedFigureID: UUID, delegate: TouchInputDelegate) {
        self.firstPoint = firstPoint
        self.lastPoint = lastPoint
        self.associatedFigureID = associatedFigureID;
        self.delegate = delegate
        
        let frameSize = CGSize(width: abs(firstPoint.x - lastPoint.x), height: abs(firstPoint.y - lastPoint.y))
        let frame = CGRect(origin: firstPoint, size: frameSize)
        super.init(frame: frame)
//        self.isUserInteractionEnabled = false
        self.isMultipleTouchEnabled = true
        self.initializeLayers()
    }
    
    init(frame: CGRect, associatedFigureID: UUID, delegate: TouchInputDelegate) {
        self.firstPoint = frame.origin
        self.lastPoint = CGPoint(x: frame.maxX, y: frame.maxY)
        self.associatedFigureID = associatedFigureID
        self.delegate = delegate
        super.init(frame: frame)
        self.initializeLayers()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func initializeLayers() {
        let anchor1 = SelectionAnchor(position: CGPoint(x: 0, y: 0))
        let anchor2 = SelectionAnchor(position: CGPoint(x: self.frame.width, y: 0))
        let anchor3 = SelectionAnchor(position: CGPoint(x: self.frame.width, y: self.frame.height))
        let anchor4 = SelectionAnchor(position: CGPoint(x: 0, y: self.frame.height))
        
        self.cornerAnchors.append(anchor1)
        self.cornerAnchors.append(anchor2)
        self.cornerAnchors.append(anchor3)
        self.cornerAnchors.append(anchor4)
        
        for anchor in self.cornerAnchors {
            self.layer.addSublayer(anchor)
        }
        
        self.initializeBorder()
        self.layer.addSublayer(border);
    }
    
    private func initializeBorder() {
        border = CAShapeLayer();
        border.strokeColor = UIColor.black.cgColor;
        border.lineDashPattern = [4, 4];
        border.frame = bounds;
        border.fillColor = nil;
        border.path = UIBezierPath(rect: self.bounds).cgPath;
    }
    
    func updateOutline(newFrame: CGRect) {
        for anchor in self.cornerAnchors {
            anchor.removeFromSuperlayer()
        }
        self.cornerAnchors.removeAll()
        self.border.removeFromSuperlayer()
        self.frame = newFrame
        self.initializeLayers()
    }
    
    public func addUsernameSelecting(username: String) {
        if(username != "") {
            let usernameTextLayer = CATextLayer()
            usernameTextLayer.string = username
            usernameTextLayer.frame = self.layer.bounds
            usernameTextLayer.backgroundColor = UIColor.red.withAlphaComponent(0.4).cgColor
            self.layer.addSublayer(usernameTextLayer)
            usernameTextLayer.setNeedsDisplay()
        }
    }
    
    // Create a detection area around connection figure extremities
    func isPointOnAnchor(point: CGPoint) -> Bool{
        let detectionDiameter: CGFloat = 50
        let areaRect: CGRect = CGRect(
            x: point.x - detectionDiameter/2,
            y: point.y - detectionDiameter/2,
            width: detectionDiameter,
            height: detectionDiameter
        )
        
        guard let sublayers = self.layer.sublayers as? [CAShapeLayer] else { return false }
        for layer in sublayers{
//            print("Point", point)
//            print(layer.position)
            if (areaRect.contains(layer.position)) {
                return true
            }
        }
        return false
    }
    
    public func translate(by: CGPoint) {
        let translatedFrame = self.frame.offsetBy(dx: by.x, dy: by.y)
        self.frame = translatedFrame
    }
}

extension SelectionOutline {
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        guard let localPoint = touch?.location(in: self) else { return }
        guard let point = touch?.location(in: self.superview) else { return }
        
//        print(event?.touches(for: self)?.count)

        self.delegate?.notifyTouchBegan(action: "selection", point: point, figure: nil)
    }
    
    public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        guard let point = touch?.location(in: self.superview) else { return }
        
        self.delegate?.notifyTouchMoved(point: point, figure: nil)
    }
    
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        guard let point = touch?.location(in: self.superview) else { return }
        self.delegate?.notifyTouchEnded(point: point, figure: nil)
    }
    
    public override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        guard let point = touch?.location(in: self.superview) else { return }
        self.delegate?.notifyTouchEnded(point: point, figure: nil)
    }
}
