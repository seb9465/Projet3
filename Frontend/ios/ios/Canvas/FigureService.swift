//
//  figureService.swift
//  ios
//
//  Created by Sebastien Cadorette on 2019-02-21.
//  Copyright © 2019 LOG3000 equipe 12. All rights reserved.
//

import UIKit

enum RESIZING {
    case FROM_CIRCLE_1
    case FROM_CIRCLE_2
    case FROM_CIRCLE_3
    case FROM_CIRCLE_4
    case NO_RESIZING
}

class FigureService: UIView {
    public var isSelected: Bool = false;
    private var isDragging: Bool = false;
    private var isResizing: Bool = false;
    private var resizingState: RESIZING = RESIZING.NO_RESIZING;
    
    private var currentPoint: CGPoint?;
    private var previousPoint1: CGPoint?;
    
    private let radius: CGFloat = 5.0;
    private var selectedDashedBorder: CAShapeLayer!;
    private var selectedCornerCircle1: CAShapeLayer!;
    private var selectedCornerCircle2: CAShapeLayer!;
    private var selectedCornerCircle3: CAShapeLayer!;
    private var selectedCornerCircle4: CAShapeLayer!;
    
    private var currentTool: FigureProtocol
    
    init(origin: CGPoint) {
        self.currentTool = Rect();
        self.currentTool.setInitialPoint(xPoint: origin.x - 50, yPoint: origin.y - 50);
        self.currentTool.setLastPoint(xPoint: origin.x + 50, yPoint: origin.y + 50);
        
        super.init(frame: CGRect(x: origin.x - 50, y: origin.y - 50, width: 103, height: 103));
        
        self.setInitialSelectedDashedBorder();
        
        self.setInitialSelectedCornerCirles();
        
        self.backgroundColor = UIColor.clear;
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func draw(_ rect: CGRect) {
        // Redimension and put at the right place the frame of the figure.
        self.frame = CGRect(x: self.currentTool.firstPoint.x, y: self.currentTool.firstPoint.y, width: self.currentTool.lastPoint.x - self.currentTool.firstPoint.x, height: self.currentTool.lastPoint.y - self.currentTool.firstPoint.y);
        
        self.currentTool.draw();
    }
    
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if (self.isSelected) {
            guard let point = touches.first else { return };
            previousPoint1 = point.previousLocation(in: self)
            currentPoint = point.location(in: self)
            
            let temp = CGRect(x: currentPoint!.x - 75/2, y: currentPoint!.y-75/2, width: 75, height: 75)
            
            if (temp.contains(self.selectedCornerCircle1.position)) {
                self.isResizing = true;
                self.resizingState = RESIZING.FROM_CIRCLE_1;
            } else if (temp.contains(self.selectedCornerCircle2.position)) {
                self.isResizing = true;
                self.resizingState = RESIZING.FROM_CIRCLE_2;
            } else if (temp.contains(self.selectedCornerCircle3.position)) {
                self.isResizing = true;
                self.resizingState = RESIZING.FROM_CIRCLE_3;
            } else if (temp.contains(self.selectedCornerCircle4.position)) {
                self.isResizing = true;
                self.resizingState = RESIZING.FROM_CIRCLE_4;
            } else {
                self.isDragging = true;
                print("DRAGGING");
            }
            
            self.removeSelectedFigureLayers();
        }
    }
    
    public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if(self.isSelected) {
            guard let point = touches.first else { return };
        
            previousPoint1 = point.previousLocation(in: self);
            currentPoint = point.location(in: self);
            
            let deltax = currentPoint!.x - previousPoint1!.x;
            let deltay = currentPoint!.y - previousPoint1!.y;
            
            if (self.isDragging) {
                self.currentTool.lastPoint.x += deltax;
                self.currentTool.lastPoint.y += deltay;
                self.currentTool.firstPoint.x += deltax;
                self.currentTool.firstPoint.y += deltay;
            } else if (self.isResizing) {
                switch (self.resizingState) {
                case .FROM_CIRCLE_1:
                    self.currentTool.firstPoint.x += deltax;
                    self.currentTool.firstPoint.y += deltay;
                    break;
                case .FROM_CIRCLE_2:
                    self.currentTool.lastPoint.x += deltax;
                    self.currentTool.firstPoint.y += deltay;
                    break;
                case .FROM_CIRCLE_3:
                    self.currentTool.lastPoint.x += deltax;
                    self.currentTool.lastPoint.y += deltay;
                    break;
                case .FROM_CIRCLE_4:
                    self.currentTool.lastPoint.y += deltay;
                    self.currentTool.firstPoint.x += deltax;
                    break;
                default:
                    break;
                }
            }
            
            setNeedsDisplay();
        }
    }
    
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.isDragging = false;
        self.isResizing = false;
        
        self.adjustSelectedFigureLayers();
    }
    
    public func setIsSelected() -> Void {
        self.isSelected = true;
        self.addSelectedFigureLayers();
        setNeedsDisplay();
    }
    
    public func setIsNotSelected() -> Void {
        self.isSelected = false;
        self.removeSelectedFigureLayers();
        setNeedsDisplay();
    }
    
    public func setFillColor(fillColor: UIColor) -> Void {
        self.currentTool.figureColor = fillColor;
        setNeedsDisplay();
    }
    
    public func setBorderColor(borderColor: UIColor) -> Void {
        self.currentTool.lineColor = borderColor;
        setNeedsDisplay();
    }
    
    private func setInitialSelectedCornerCirles() -> Void {
        selectedCornerCircle1 = CAShapeLayer();
        selectedCornerCircle1.path = UIBezierPath(roundedRect: CGRect(x: -5, y: -5, width: 2.0 * self.radius, height: 2.0 * self.radius), cornerRadius: self.radius).cgPath;
        selectedCornerCircle1.position = CGPoint(x: 0, y: 0);
        selectedCornerCircle1.fillColor = UIColor.blue.cgColor;
        
        selectedCornerCircle2 = CAShapeLayer();
        selectedCornerCircle2.path = UIBezierPath(roundedRect: CGRect(x: -5, y: -5, width: 2.0 * self.radius, height: 2.0 * self.radius), cornerRadius: self.radius).cgPath;
        selectedCornerCircle2.position = CGPoint(x: self.currentTool.lastPoint.x - self.currentTool.firstPoint.x + 2, y: 0);
        selectedCornerCircle2.fillColor = UIColor.blue.cgColor;
        
        selectedCornerCircle3 = CAShapeLayer();
        selectedCornerCircle3.path = UIBezierPath(roundedRect: CGRect(x: -5, y: -5, width: 2.0 * self.radius, height: 2.0 * self.radius), cornerRadius: self.radius).cgPath;
        selectedCornerCircle3.position = CGPoint(x: self.currentTool.lastPoint.x - self.currentTool.firstPoint.x + 2, y: self.currentTool.lastPoint.y - self.currentTool.firstPoint.y + 2);
        selectedCornerCircle3.fillColor = UIColor.blue.cgColor;
        
        selectedCornerCircle4 = CAShapeLayer();
        selectedCornerCircle4.path = UIBezierPath(roundedRect: CGRect(x: -5, y: -5, width: 2.0 * self.radius, height: 2.0 * self.radius), cornerRadius: self.radius).cgPath;
        selectedCornerCircle4.position = CGPoint(x: 0, y: self.currentTool.lastPoint.y - self.currentTool.firstPoint.y + 2);
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
    
    private func adjustSelectedFigureLayers() -> Void {
        selectedDashedBorder.path = UIBezierPath(rect: self.bounds).cgPath;
        selectedCornerCircle2.position.x = self.currentTool.lastPoint.x - self.currentTool.firstPoint.x + 2;
        selectedCornerCircle3.position.x = self.currentTool.lastPoint.x - self.currentTool.firstPoint.x + 2;
        selectedCornerCircle3.position.y = self.currentTool.lastPoint.y - self.currentTool.firstPoint.y + 2;
        selectedCornerCircle4.position.y = self.currentTool.lastPoint.y - self.currentTool.firstPoint.y + 2;
        self.addSelectedFigureLayers();
        setNeedsDisplay();
    }
}
