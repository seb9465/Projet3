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
    var points: [CGPoint];
    
    private var shape: CAShapeLayer;
    private var shapePath: UIBezierPath;
    var shapeIsClosed: Bool;
    
    // MARK: Constructors
    
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
    
    // MARK: Public functions
    
    public func addNewTouchPoint(touchPoint: CGPoint) -> Void {
        let needsToBeClosed: Bool = self.shapeNeedsToBeClosed(touchPoint: touchPoint);
        
        if (!needsToBeClosed) {
            self.points.append(touchPoint);
        }
        
        self.shape.removeFromSuperlayer();
        self.clearShapePath();
        
        for point in self.points {
            self.addLineToShapePath(touchPoint: point);
            self.addTouchPointCircle(touchPoint: point);
        }
        
        if (needsToBeClosed) {
            self.shapePath.close();
            self.shapeIsClosed = true;
        }
        
        self.shape.path = self.shapePath.cgPath;
        self.layer.addSublayer(self.shape);
    }
    
    public func contains(figure: Figure) -> Bool {
        let firstPoint: CGPoint = figure.firstPoint;
        let lastPoint: CGPoint = figure.lastPoint;
        
        var points: [CGPoint] = [];
        points.append(CGPoint(x: firstPoint.x, y: firstPoint.y));   // Upper left corner
        points.append(CGPoint(x: firstPoint.x, y: lastPoint.y));    // Lower left corner
        points.append(CGPoint(x: lastPoint.x, y: firstPoint.y));    // Upper right corner
        points.append(CGPoint(x: lastPoint.x, y: lastPoint.y));     // Lower right corner
        
        for point in points {
            if (!self.shape.path!.contains(point)) {
                return false;
            }
        }
        
        return true;
    }
    
    // MARK: Private functions
    
    private func clearShapePath() -> Void {
        self.shapePath.removeAllPoints();
        self.shapePath.move(to: CGPoint(x: self.firstPoint.x, y: self.firstPoint.y));
    }
    
    private func addLineToShapePath(touchPoint: CGPoint) -> Void {
        self.shapePath.addLine(to: CGPoint(
            x: touchPoint.x,
            y: touchPoint.y
        ));
    }
    
    private func shapeNeedsToBeClosed(touchPoint: CGPoint) -> Bool {
        return abs(touchPoint.x - self.firstPoint.x) <= 50 && abs(touchPoint.y - self.firstPoint.y) <= 50;
    }
    
    private func setShapeProperties() -> Void {
        self.shapePath.move(to: CGPoint(x: self.firstPoint.x, y: self.firstPoint.y));
        self.shape.fillColor = nil;
        self.shape.lineWidth = 4;
        self.shape.position = CGPoint(x: 0, y: 0);
        self.shape.strokeColor = UIColor.black.cgColor;
        self.shape.lineDashPattern = [4, 4];
    }
    
    private func addTouchPointCircle(touchPoint: CGPoint) -> Void {
        let circle = CAShapeLayer();
        circle.path = UIBezierPath(roundedRect: CGRect(x: -5, y: -5, width: 2.0 * self.radius, height: 2.0 * self.radius), cornerRadius: self.radius).cgPath;
        circle.position = CGPoint(x: touchPoint.x, y: touchPoint.y);
        circle.fillColor = Constants.RED_COLOR.cgColor;
        self.layer.addSublayer(circle);
    }
}
