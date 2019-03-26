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
    private let radius: CGFloat = 5.0;

    public var firstPoint: CGPoint!
    public var lastPoint: CGPoint!
    
    var border: CAShapeLayer!;
    var cornerAnchors: [CAShapeLayer] = []
    
    init(firstPoint: CGPoint, lastPoint: CGPoint) {
        self.firstPoint = firstPoint
        self.lastPoint = lastPoint
        
        let frameSize = CGSize(width: abs(firstPoint.x - lastPoint.x), height: abs(firstPoint.y - lastPoint.y))
        let frame = CGRect(origin: firstPoint, size: frameSize)
        super.init(frame: frame)
        self.isUserInteractionEnabled = false
        self.setInitialSelectedDashedBorder(bounds: self.bounds);
        self.setInitialSelectedCornerCirles(firstPoint: firstPoint, lastPoint: lastPoint)
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
    
    public func translate(by: CGPoint) {
        let translatedFrame = self.frame.offsetBy(dx: by.x, dy: by.y)
        self.frame = translatedFrame
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        return !(self.border.path?.contains(point))!
    }
}
