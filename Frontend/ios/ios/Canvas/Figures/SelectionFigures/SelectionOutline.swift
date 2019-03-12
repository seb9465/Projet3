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
    var selectedDashedBorder: CAShapeLayer!;
    var selectedCornerCircle1: CAShapeLayer!;
    var selectedCornerCircle2: CAShapeLayer!;
    var selectedCornerCircle3: CAShapeLayer!;
    var selectedCornerCircle4: CAShapeLayer!;
    
    init(firstPoint: CGPoint, lastPoint: CGPoint) {
        let width = abs(firstPoint.x - lastPoint.x)
        let height = abs(firstPoint.y - lastPoint.y)
        let frame : CGRect = CGRect(x: firstPoint.x, y: firstPoint.y, width: width + 5, height: height + 5)
        super.init(frame: frame);
        self.setInitialSelectedDashedBorder(bounds: self.bounds);
        self.setInitialSelectedCornerCirles(firstPoint: firstPoint, lastPoint: lastPoint)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func setInitialSelectedCornerCirles(firstPoint: CGPoint, lastPoint: CGPoint) -> Void {
        selectedCornerCircle1 = CAShapeLayer();
        selectedCornerCircle1.path = UIBezierPath(roundedRect: CGRect(x: -5, y: -5, width: 2.0 * self.radius, height: 2.0 * self.radius), cornerRadius: self.radius).cgPath;
        selectedCornerCircle1.position = CGPoint(x: 0, y: 0);
        selectedCornerCircle1.fillColor = UIColor.blue.cgColor;
        
        selectedCornerCircle2 = CAShapeLayer();
        selectedCornerCircle2.path = UIBezierPath(roundedRect: CGRect(x: -5, y: -5, width: 2.0 * self.radius, height: 2.0 * self.radius), cornerRadius: self.radius).cgPath;
        selectedCornerCircle2.position = CGPoint(x: lastPoint.x - firstPoint.x + 2, y: 0);
        selectedCornerCircle2.fillColor = UIColor.blue.cgColor;
        
        selectedCornerCircle3 = CAShapeLayer();
        selectedCornerCircle3.path = UIBezierPath(roundedRect: CGRect(x: -5, y: -5, width: 2.0 * self.radius, height: 2.0 * self.radius), cornerRadius: self.radius).cgPath;
        selectedCornerCircle3.position = CGPoint(x: lastPoint.x - firstPoint.x + 2, y: lastPoint.y - firstPoint.y + 2);
        selectedCornerCircle3.fillColor = UIColor.blue.cgColor;
        
        selectedCornerCircle4 = CAShapeLayer();
        selectedCornerCircle4.path = UIBezierPath(roundedRect: CGRect(x: -5, y: -5, width: 2.0 * self.radius, height: 2.0 * self.radius), cornerRadius: self.radius).cgPath;
        selectedCornerCircle4.position = CGPoint(x: 0, y: lastPoint.y - firstPoint.y + 2);
        selectedCornerCircle4.fillColor = UIColor.blue.cgColor;
    }
    
    public func setInitialSelectedDashedBorder(bounds: CGRect) -> Void {
        selectedDashedBorder = CAShapeLayer();
        selectedDashedBorder.strokeColor = UIColor.black.cgColor;
        selectedDashedBorder.lineDashPattern = [4, 4];
        selectedDashedBorder.frame = bounds;
        selectedDashedBorder.fillColor = nil;
        selectedDashedBorder.path = UIBezierPath(rect: bounds).cgPath;
    }
    
    public func addSelectedFigureLayers(layer: CALayer) -> Void {
        self.layer.addSublayer(selectedDashedBorder);
        self.layer.addSublayer(selectedCornerCircle1);
        self.layer.addSublayer(selectedCornerCircle2);
        self.layer.addSublayer(selectedCornerCircle3);
        self.layer.addSublayer(selectedCornerCircle4);
    }
    
    public func removeSelectedFigureLayers() -> Void {
        self.selectedDashedBorder.removeFromSuperlayer();
        self.selectedCornerCircle1.removeFromSuperlayer();
        self.selectedCornerCircle2.removeFromSuperlayer();
        self.selectedCornerCircle3.removeFromSuperlayer();
        self.selectedCornerCircle4.removeFromSuperlayer();
    }
    
    public func adjustSelectedFigureLayers(firstPoint: CGPoint, lastPoint: CGPoint, bounds: CGRect, layer: CALayer) -> Void {
        selectedDashedBorder.path = UIBezierPath(rect: bounds).cgPath;
        selectedCornerCircle2.position.x = lastPoint.x - firstPoint.x + 2;
        selectedCornerCircle3.position.x = lastPoint.x - firstPoint.x + 2;
        selectedCornerCircle3.position.y = lastPoint.y - firstPoint.y + 2;
        selectedCornerCircle4.position.y = lastPoint.y - firstPoint.y + 2;
        self.addSelectedFigureLayers(layer: layer);
        //        setNeedsDisplay();
    }
}
