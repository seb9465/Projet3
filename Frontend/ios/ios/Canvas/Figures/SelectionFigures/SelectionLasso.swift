//
//  SelectionLasso.swift
//  ios
//
//  Created by Sebastien Cadorette on 2019-03-26.
//  Copyright © 2019 LOG3000 equipe 12. All rights reserved.
//

import Foundation
import UIKit

protocol SelectionLassoProtocol {
    var shapeIsClosed: Bool { get }
}

class SelectionLasso: UIView, SelectionLassoProtocol {
    private let radius: CGFloat = 5.0;
    
    private var firstPoint: CGPoint;
    private var points: [CGPoint];
    
    private var shape: CAShapeLayer;
    private var shapePath: UIBezierPath;
    var shapeIsClosed: Bool;
    
    init(size: CGSize, touchPoint: CGPoint) {
        self.firstPoint = touchPoint;
        
        self.points = [];
        self.points.append(touchPoint);
        
        self.shape = CAShapeLayer();
        self.shapePath = UIBezierPath();
        self.shapeIsClosed = false;
        
        let frame: CGRect = CGRect(origin: CGPoint(x: 0, y: 0), size: size);
        super.init(frame: frame);
        
        self.setShapeProperties();
        
        self.addTouchPointCircle(touchPoint: touchPoint);
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented");
    }
    
    public func addNewTouchPoint(touchPoint: CGPoint) -> Void {
        let needsToBeClosed: Bool = self.shapeNeedsToBeClosed(touchPoint: touchPoint);
        
        if (!needsToBeClosed) {
            self.points.append(touchPoint);
        }
        
        self.shape.removeFromSuperlayer();
        self.shapePath.removeAllPoints();
        self.shapePath.move(to: CGPoint(x: 0, y: 0));
        
        for point in self.points {
            self.shapePath.addLine(to: CGPoint(
                x: point.x - self.firstPoint.x,
                y: point.y - self.firstPoint.y
            ));
            
            self.addTouchPointCircle(touchPoint: point);
        }
        
        if (needsToBeClosed) {
            self.shapePath.close();
            self.shapeIsClosed = true;
        }
        
        self.shape.path = self.shapePath.cgPath;
        self.layer.addSublayer(self.shape);
    }
    
    private func shapeNeedsToBeClosed(touchPoint: CGPoint) -> Bool {
        return abs(touchPoint.x - self.firstPoint.x) <= 50 && abs(touchPoint.y - self.firstPoint.y) <= 50;
    }
    
    private func setShapeProperties() -> Void {
        self.shapePath.move(to: CGPoint(x: 0, y: 0));
        self.shape.fillColor = nil;
        self.shape.lineWidth = 4;
        self.shape.position = self.firstPoint;
        self.shape.strokeColor = UIColor.black.cgColor;
        self.shape.lineDashPattern = [4, 4];
    }
    
    private func addTouchPointCircle(touchPoint: CGPoint) -> Void {
        let circle = CAShapeLayer();
        circle.path = UIBezierPath(roundedRect: CGRect(x: -5, y: -5, width: 2.0 * self.radius, height: 2.0 * self.radius), cornerRadius: self.radius).cgPath;
        circle.position = CGPoint(x: touchPoint.x, y: touchPoint.y);
        circle.fillColor = UIColor.blue.cgColor;
        self.layer.addSublayer(circle);
    }
}
