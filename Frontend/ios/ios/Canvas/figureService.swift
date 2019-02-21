//
//  figureService.swift
//  ios
//
//  Created by Sebastien Cadorette on 2019-02-21.
//  Copyright © 2019 LOG3000 equipe 12. All rights reserved.
//

import UIKit

class figureService: UIView {
    private var firstPoint: CGPoint = CGPoint(x: 0, y: 0);
    private var lastPoint: CGPoint = CGPoint(x: 100, y: 100);
    
    public var isSelected: Bool = false;
    private var isDragging: Bool = false;
    
    private var currentPoint: CGPoint?
    private var previousPoint1: CGPoint?
    
    init(origin: CGPoint) {
        super.init(frame: CGRect(x: origin.x - 50, y: origin.y - 50, width: 100, height: 100));
        self.firstPoint = CGPoint(x: origin.x - 50, y: origin.y - 50);
        self.lastPoint = CGPoint(x: origin.x + 50, y: origin.y + 50);
        
        self.backgroundColor = UIColor.clear;
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(_ rect: CGRect) {
        let r: CGRect = CGRect(x: 0, y: 0, width: lastPoint.x - firstPoint.x, height: lastPoint.y - firstPoint.y);
        
        self.frame = CGRect(x: firstPoint.x, y: firstPoint.y, width: lastPoint.x - firstPoint.x, height: lastPoint.y - firstPoint.y);
        
        
        let insetRect = r.insetBy(dx: 3, dy: 3);
        let path = UIBezierPath(roundedRect: insetRect, cornerRadius: 10);
        
        UIColor.red.setFill()
        path.lineWidth = 3;
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
}
