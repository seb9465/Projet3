//
//  Rect.swift
//  ios
//
//  Created by Sebastien Cadorette on 2019-03-07.
//  Copyright © 2019 LOG3000 equipe 12. All rights reserved.
//
import UIKit

protocol FigureProtocol {
    var firstPoint: CGPoint { get set }
    var lastPoint: CGPoint { get set }
    var figureColor: UIColor { get set }
    var lineWidth: CGFloat { get set }
    var lineColor: UIColor { get set }
    
    func draw()
    func setInitialPoint(xPoint: CGFloat, yPoint: CGFloat)
    func setLastPoint(xPoint: CGFloat, yPoint: CGFloat)
}

class Rect: FigureProtocol {
    var firstPoint: CGPoint
    var lastPoint: CGPoint
    var figureColor: UIColor
    var lineWidth: CGFloat
    var lineColor: UIColor
    
    init() {
        self.firstPoint = CGPoint(x: 0, y: 0);
        self.lastPoint = CGPoint(x: 0, y: 0);
        self.figureColor = UIColor.clear;
        self.lineWidth = 2;
        self.lineColor = UIColor.black;
    }
    
    func setInitialPoint(xPoint: CGFloat, yPoint: CGFloat) -> Void {
        self.firstPoint.x = xPoint;
        self.firstPoint.y = yPoint;
    }
    
    func setLastPoint(xPoint: CGFloat, yPoint: CGFloat) -> Void {
        self.lastPoint.x = xPoint;
        self.lastPoint.y = yPoint;
    }
    
    func draw() {
        // Drawing the figure.
        let r: CGRect = CGRect(x: 1, y: 1, width: lastPoint.x - firstPoint.x, height: lastPoint.y - firstPoint.y);
        
        // Inset to be able to place a border.
        let insetRect = r.insetBy(dx: 4, dy: 4);
        
        let path = UIBezierPath(roundedRect: insetRect, cornerRadius: 10);
        
        // Border and fill parameters.
        self.figureColor.setFill();
        path.lineWidth = self.lineWidth;
        self.lineColor.setStroke();
        path.fill();
        path.stroke();
    }
}
