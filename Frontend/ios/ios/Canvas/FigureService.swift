//
//  figureService.swift
//  ios
//
//  Created by Sebastien Cadorette on 2019-02-21.
//  Copyright © 2019 LOG3000 equipe 12. All rights reserved.
//

import UIKit

protocol FigureProtocol {
    var figureColor: UIColor { get set }
    var lineWidth: CGFloat { get set }
    var lineColor: UIColor { get set }
}

class FigureService: UIView, FigureProtocol {
    var figureColor: UIColor
    var lineWidth: CGFloat
    var lineColor: UIColor
    private var firstPoint: CGPoint;
    private var lastPoint: CGPoint;
    
    public var isSelected: Bool = false;
    private var isDragging: Bool = false;
    
    private var currentPoint: CGPoint?;
    private var previousPoint1: CGPoint?;
    
    private let radius: CGFloat = 5.0;
    private var selectedDashedBorder: CAShapeLayer!;
    private var selectedCornerCircle1: CAShapeLayer!;
    private var selectedCornerCircle2: CAShapeLayer!;
    private var selectedCornerCircle3: CAShapeLayer!;
    private var selectedCornerCircle4: CAShapeLayer!;
    
    init(origin: CGPoint) {
        self.firstPoint = CGPoint(x: origin.x - 50, y: origin.y - 50);
        self.lastPoint = CGPoint(x: origin.x + 50, y: origin.y + 50);
        self.figureColor = UIColor.clear;
        self.lineWidth = 2;
        self.lineColor = UIColor.black;
        
        super.init(frame: CGRect(x: origin.x - 50, y: origin.y - 50, width: 102, height: 102));
        
        self.setInitialSelectedDashedBorder();
        
        self.setInitialSelectedCornerCirles();
        
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
            self.addSelectedFigureLayers();
        } else {
            self.removeSelectedFigureLayers();
        }
        
        // Border and fill parameters.
        self.figureColor.setFill();
        path.lineWidth = self.lineWidth;
        self.lineColor.setStroke();
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
    
    public func setFillColor(fillColor: UIColor) -> Void {
        self.figureColor = fillColor;
        setNeedsDisplay();
    }
    
    private func setInitialSelectedCornerCirles() -> Void {
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
    
    private func setInitialSelectedDashedBorder() -> Void {
        selectedDashedBorder = CAShapeLayer();
        selectedDashedBorder.strokeColor = UIColor.black.cgColor;
        selectedDashedBorder.lineDashPattern = [4, 4];
        selectedDashedBorder.frame = self.bounds;
        selectedDashedBorder.fillColor = nil;
        selectedDashedBorder.path = UIBezierPath(rect: self.bounds).cgPath;
    }
    
    private func addSelectedFigureLayers() -> Void {
        self.layer.addSublayer(selectedDashedBorder);
        self.layer.addSublayer(selectedCornerCircle1);
        self.layer.addSublayer(selectedCornerCircle2);
        self.layer.addSublayer(selectedCornerCircle3);
        self.layer.addSublayer(selectedCornerCircle4);
    }
    
    private func removeSelectedFigureLayers() -> Void {
        self.selectedDashedBorder.removeFromSuperlayer();
        self.selectedCornerCircle1.removeFromSuperlayer();
        self.selectedCornerCircle2.removeFromSuperlayer();
        self.selectedCornerCircle3.removeFromSuperlayer();
        self.selectedCornerCircle4.removeFromSuperlayer();
    }
}
