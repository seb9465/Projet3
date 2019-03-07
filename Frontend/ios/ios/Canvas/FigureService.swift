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
    
    // MARK: Attributes
    
    public var isSelected: Bool = false;
    private var isDragging: Bool = false;
    private var isResizing: Bool = false;
    private var resizingState: RESIZING = RESIZING.NO_RESIZING;
    
    private var currentPoint: CGPoint?;
    private var previousPoint1: CGPoint?;
    
    private var selectFigureService: SelectFigureService;
    private var currentTool: FigureProtocol
    
    // MARK: Public functions
    
    init(origin: CGPoint) {
        let fPoint: CGPoint = CGPoint(x: origin.x - 50, y: origin.y - 50);
        let lPoint: CGPoint = CGPoint(x: origin.x + 50, y: origin.y + 50);
        
        self.currentTool = Rect();
        self.currentTool.setInitialPoint(initialPoint: fPoint);
        self.currentTool.setLastPoint(lastPoint: lPoint);
        
        self.selectFigureService = SelectFigureService();
        
        super.init(frame: CGRect(x: origin.x - 50, y: origin.y - 50, width: 103, height: 103));
        
        self.selectFigureService.setInitialSelectedDashedBorder(bounds: self.bounds);
        self.selectFigureService.setInitialSelectedCornerCirles(firstPoint: fPoint, lastPoint: lPoint);
        
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
            
            if (temp.contains(self.selectFigureService.selectedCornerCircle1.position)) {
                self.isResizing = true;
                self.resizingState = RESIZING.FROM_CIRCLE_1;
            } else if (temp.contains(self.selectFigureService.selectedCornerCircle2.position)) {
                self.isResizing = true;
                self.resizingState = RESIZING.FROM_CIRCLE_2;
            } else if (temp.contains(self.selectFigureService.selectedCornerCircle3.position)) {
                self.isResizing = true;
                self.resizingState = RESIZING.FROM_CIRCLE_3;
            } else if (temp.contains(self.selectFigureService.selectedCornerCircle4.position)) {
                self.isResizing = true;
                self.resizingState = RESIZING.FROM_CIRCLE_4;
            } else {
                self.isDragging = true;
                print("DRAGGING");
            }
            
            self.selectFigureService.removeSelectedFigureLayers();
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
        
        self.selectFigureService.adjustSelectedFigureLayers(firstPoint: self.currentTool.firstPoint, lastPoint: self.currentTool.lastPoint, bounds: self.bounds, layer: self.layer);
        setNeedsDisplay();
    }
    
    public func setIsSelected() -> Void {
        self.isSelected = true;
        self.selectFigureService.addSelectedFigureLayers(layer: self.layer);
        setNeedsDisplay();
    }
    
    public func setIsNotSelected() -> Void {
        self.isSelected = false;
        self.selectFigureService.removeSelectedFigureLayers();
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
}
