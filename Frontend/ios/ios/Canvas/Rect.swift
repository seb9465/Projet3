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
    func setInitialPoint(initialPoint: CGPoint)
    func setLastPoint(lastPoint: CGPoint)
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
    
    func setInitialPoint(initialPoint: CGPoint) -> Void {
        self.firstPoint = initialPoint;
    }
    
    func setLastPoint(lastPoint: CGPoint) -> Void {
        self.lastPoint = lastPoint;
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