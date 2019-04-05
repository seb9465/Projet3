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
        self.setInitialSelectedDashedBorder(bounds: self.bounds);
        self.setInitialSelectedCornerCirles(firstPoint: firstPoint, lastPoint: lastPoint)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func setInitialSelectedCornerCirles(firstPoint: CGPoint, lastPoint: CGPoint) -> Void {
        let selectedCornerCircle1 = CAShapeLayer();
        selectedCornerCircle1.path = UIBezierPath(roundedRect: CGRect(x: -5, y: -5, width: 2.0 * self.radius, height: 2.0 * self.radius), cornerRadius: self.radius).cgPath;
        selectedCornerCircle1.position = CGPoint(x: 0, y: 0);
        selectedCornerCircle1.fillColor = UIColor.blue.cgColor;
        
        let selectedCornerCircle2 = CAShapeLayer();
        selectedCornerCircle2.path = UIBezierPath(roundedRect: CGRect(x: -5, y: -5, width: 2.0 * self.radius, height: 2.0 * self.radius), cornerRadius: self.radius).cgPath;
        selectedCornerCircle2.position = CGPoint(x: lastPoint.x - firstPoint.x + 2, y: 0);
        selectedCornerCircle2.fillColor = UIColor.blue.cgColor;
        
        let selectedCornerCircle3 = CAShapeLayer();
        selectedCornerCircle3.path = UIBezierPath(roundedRect: CGRect(x: -5, y: -5, width: 2.0 * self.radius, height: 2.0 * self.radius), cornerRadius: self.radius).cgPath;
        selectedCornerCircle3.position = CGPoint(x: lastPoint.x - firstPoint.x + 2, y: lastPoint.y - firstPoint.y + 2);
        selectedCornerCircle3.fillColor = UIColor.blue.cgColor;
        
        let selectedCornerCircle4 = CAShapeLayer();
        selectedCornerCircle4.path = UIBezierPath(roundedRect: CGRect(x: -5, y: -5, width: 2.0 * self.radius, height: 2.0 * self.radius), cornerRadius: self.radius).cgPath;
        selectedCornerCircle4.position = CGPoint(x: 0, y: lastPoint.y - firstPoint.y + 2);
        selectedCornerCircle4.fillColor = UIColor.blue.cgColor;
        
        self.cornerAnchors.append(selectedCornerCircle1)
        self.cornerAnchors.append(selectedCornerCircle2)
        self.cornerAnchors.append(selectedCornerCircle3)
        self.cornerAnchors.append(selectedCornerCircle4)
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
    
    public func setInitialSelectedDashedBorder(bounds: CGRect) -> Void {
        border = CAShapeLayer();
        border.strokeColor = UIColor.black.cgColor;
        border.lineDashPattern = [4, 4];
        border.frame = bounds;
        border.fillColor = nil;
        border.path = UIBezierPath(rect: bounds).cgPath;
    }
    public func addSelectedFigureLayers() -> Void {
        self.layer.addSublayer(border);
        for cornerAnchor in self.cornerAnchors {
            self.layer.addSublayer(cornerAnchor)
        }
    }
    
    public func removeSelectedFigureLayers() -> Void {
        self.border.removeFromSuperlayer();
        for cornerAnchor in self.cornerAnchors {
            cornerAnchor.removeFromSuperlayer()
        }
    }
    
    public func adjustSelectedFigureLayers(firstPoint: CGPoint, lastPoint: CGPoint, bounds: CGRect, layer: CALayer) -> Void {
        border.path = UIBezierPath(rect: bounds).cgPath;
        for cornerAnchor in self.cornerAnchors {
            cornerAnchor.position.x = lastPoint.x - firstPoint.x + 2
        }
        
//        selectedCornerCircle2.position.x = lastPoint.x - firstPoint.x + 2;
//        selectedCornerCircle3.position.x = lastPoint.x - firstPoint.x + 2;
//        selectedCornerCircle3.position.y = lastPoint.y - firstPoint.y + 2;
//        selectedCornerCircle4.position.y = lastPoint.y - firstPoint.y + 2;

        self.addSelectedFigureLayers();
//        setNeedsDisplay();
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
