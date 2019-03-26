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
    private var shape: CAShapeLayer;
    private var shapePath: UIBezierPath;
//    private var shapes: [CAShapeLayer]!;
    
    init(size: CGSize, touchPoint: CGPoint) {
        self.firstPoint = touchPoint;
        self.lastPoint = self.firstPoint;
        self.shape = CAShapeLayer();
        self.shapePath = UIBezierPath();
        self.shapePath.move(to: CGPoint(x: 0, y: 0));
        self.shape.fillColor = nil;
        self.shape.lineWidth = 4;
        self.shape.position = self.firstPoint;
        self.shape.strokeColor = UIColor.black.cgColor;
        self.shape.lineDashPattern = [4, 4];
        
        let frame: CGRect = CGRect(origin: CGPoint(x: 0, y: 0), size: size);
        super.init(frame: frame);
        
//        self.addNewTouchPoint(touchPoint: touchPoint);
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented");
    }
    
    public func addNewTouchPoint(touchPoint: CGPoint) -> Void {
        self.shape.removeFromSuperlayer();
        // Adding the line from the touch point to the last point
//        let line = CAShapeLayer();
//        let linePath: UIBezierPath = UIBezierPath();
//        linePath.move(to: CGPoint(x: 0, y: 0));
        self.shapePath.addLine(to: CGPoint(
            x: touchPoint.x - self.firstPoint.x,
            y: touchPoint.y - self.firstPoint.y
        ));
        self.shape.path = self.shapePath.cgPath;
//        line.fillColor = nil;
//        line.lineWidth = 4;
//        line.position = self.lastPoint;
//        line.strokeColor = UIColor.black.cgColor;
//        line.lineDashPattern = [4, 4];
        
        self.layer.addSublayer(self.shape);
        
        // Adding the point in the view
//        let newPoint = CAShapeLayer();
//        newPoint.path = UIBezierPath(roundedRect: CGRect(x: -5, y: -5, width: 2.0 * self.radius, height: 2.0 * self.radius), cornerRadius: self.radius).cgPath;
//        newPoint.position = CGPoint(x: touchPoint.x, y: touchPoint.y);
//        newPoint.fillColor = UIColor.black.cgColor;
//
//        self.layer.addSublayer(newPoint);
        
        self.lastPoint = touchPoint;
    }
}
