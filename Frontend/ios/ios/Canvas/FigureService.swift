//
//  figureService.swift
//  ios
//
//  Created by Sebastien Cadorette on 2019-02-21.
//  Copyright © 2019 LOG3000 equipe 12. All rights reserved.
//

import UIKit

class FigureService: UIView {
    private var firstPoint: CGPoint = CGPoint(x: 1, y: 1);
    private var lastPoint: CGPoint = CGPoint(x: 101, y: 101);
    
    public var isSelected: Bool = false;
    private var isDragging: Bool = false;
    
    private var currentPoint: CGPoint?
    private var previousPoint1: CGPoint?
    
    init(origin: CGPoint) {
        super.init(frame: CGRect(x: origin.x - 50, y: origin.y - 50, width: 101, height: 101));
        self.firstPoint = CGPoint(x: origin.x - 50, y: origin.y - 50);
        self.lastPoint = CGPoint(x: origin.x + 50, y: origin.y + 50);
        
        self.backgroundColor = UIColor.clear;
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(_ rect: CGRect) {
        // Redimension and put at the right place the frame of the figure.
        self.frame = CGRect(x: firstPoint.x, y: firstPoint.y, width: lastPoint.x - firstPoint.x, height: lastPoint.y - firstPoint.y);
        
        // Drawing the figure.
        let r: CGRect = CGRect(x: 1, y: 1, width: lastPoint.x - firstPoint.x, height: lastPoint.y - firstPoint.y);
        
        // Inset to be able to place a border.
        let insetRect = r.insetBy(dx: 4, dy: 4);
        
        let path = UIBezierPath(roundedRect: insetRect, cornerRadius: 10);
        
        if (self.isSelected) {
            let yourViewBorder: CAShapeLayer = CAShapeLayer()
            yourViewBorder.strokeColor = UIColor.black.cgColor
            yourViewBorder.lineDashPattern = [4, 4]
            yourViewBorder.frame = self.bounds
            yourViewBorder.fillColor = nil
            yourViewBorder.path = UIBezierPath(rect: self.bounds).cgPath
            self.layer.addSublayer(yourViewBorder)
            
            let circleLayer: CAShapeLayer = CAShapeLayer();
            let radius: CGFloat = 5.0;
            circleLayer.path = UIBezierPath(roundedRect: CGRect(x: -2.5, y: -2.5, width: 2.0 * radius, height: 2.0 * radius), cornerRadius: radius).cgPath;
            circleLayer.position = CGPoint(x: 0, y: 0);
            circleLayer.fillColor = UIColor.blue.cgColor;
            self.layer.addSublayer(circleLayer);
        }
        
        // Border and fill parameters.
        UIColor.red.setFill()
        path.lineWidth = 2;
        UIColor.black.setStroke();
        path.fill();
        path.stroke();
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if (self.isSelected) {
            self.isDragging = true;
            print("touches began");
            guard let point = touches.first else { return };
            
            previousPoint1 = point.previousLocation(in: self)
            currentPoint = point.location(in: self)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if (self.isDragging) {
            print("touches moved");
            guard let point = touches.first else { return };
            
            previousPoint1 = point.previousLocation(in: self)
            currentPoint = point.location(in: self)
            
            let deltax = currentPoint!.x - previousPoint1!.x;
            let deltay = currentPoint!.y - previousPoint1!.y;
            
            self.lastPoint.x += deltax;
            self.lastPoint.y += deltay;
            self.firstPoint.x += deltax;
            self.firstPoint.y += deltay;
            
            setNeedsDisplay();
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.isDragging = false;
        touchesMoved(touches, with: event);
        print("touches ended");
    }
    
    public func setIsSelected() -> Void {
        self.isSelected = true;
        setNeedsDisplay();
    }
    
    public func setIsNotSelected() -> Void {
        self.isSelected = false;
        setNeedsDisplay();
    }
}
