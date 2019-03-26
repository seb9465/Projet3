//
//  SelectionLasso.swift
//  ios
//
//  Created by Sebastien Cadorette on 2019-03-26.
//  Copyright © 2019 LOG3000 equipe 12. All rights reserved.
//

import Foundation
import UIKit

class SelectionLasso: UIView {
    private let radius: CGFloat = 5.0;
    
    private var firstPoint: CGPoint;
    private var lastPoint: CGPoint;
    private var shapes: [CAShapeLayer]!;
    
    init(size: CGSize, touchPoint: CGPoint) {
        self.firstPoint = touchPoint;
        self.lastPoint = self.firstPoint;
        self.shapes = [];
        
        let frame: CGRect = CGRect(origin: CGPoint(x: 0, y: 0), size: size);
        super.init(frame: frame);
        
        self.setInitialBorderLayer();
        self.addPoint(touchPoint: touchPoint);
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented");
    }
    
    public func setInitialBorderLayer() -> Void {
        let border = CAShapeLayer();
        border.strokeColor = UIColor.black.cgColor;
        border.lineDashPattern = [4, 4];
        border.frame = bounds;
        border.fillColor = nil;
        border.path = UIBezierPath(rect: self.bounds).cgPath;
        
        self.shapes.append(border);
        self.layer.addSublayer(border);
    }
    
//    public func addBorderLayer() -> Void {
//        self.layer.addSublayer(border);
//    }
    
//    public func removeBorderLayer() -> Void {
//        self.border.removeFromSuperlayer();
//    }
    
    public func addPoint(touchPoint: CGPoint) -> Void {
        // Adding the line from the touch point to the last point
        let line = CAShapeLayer();
        let linePath: UIBezierPath = UIBezierPath();
        linePath.move(to: CGPoint(x: 0, y: 0));
        linePath.addLine(to: CGPoint(
            x: touchPoint.x - self.lastPoint.x,
            y: touchPoint.y - self.lastPoint.y
        ));
        line.path = linePath.cgPath;
        line.fillColor = nil;
        line.lineWidth = 4;
        line.position = self.lastPoint;
        line.strokeColor = UIColor.black.cgColor;
        line.lineDashPattern = [4, 4]
        
        self.shapes.append(line);
        self.layer.addSublayer(line);
        
        // Adding the point in the view
        let newPoint = CAShapeLayer();
        newPoint.path = UIBezierPath(roundedRect: CGRect(x: -5, y: -5, width: 2.0 * self.radius, height: 2.0 * self.radius), cornerRadius: self.radius).cgPath;
        newPoint.position = CGPoint(x: touchPoint.x, y: touchPoint.y);
        newPoint.fillColor = UIColor.black.cgColor;
        
        self.shapes.append(newPoint);
        self.layer.addSublayer(newPoint);
        
        self.lastPoint = touchPoint;
    }
}
