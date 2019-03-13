//
//  BaseFigure.swift
//  ios
//
//  Created by William Sevigny on 2019-03-11.
//  Copyright © 2019 LOG3000 equipe 12. All rights reserved.
//

import UIKit

class UmlFigure : UIView {
    var firstPoint: CGPoint!
    var lastPoint: CGPoint!
    var width: CGFloat!
    var height: CGFloat!
    var figureColor: UIColor!
    var lineWidth: CGFloat!
    var lineColor: UIColor!
        
    public var isSelected: Bool = false;
    private var isDragging: Bool = false;
    private var isResizing: Bool = false;
    public var anchorPoints: AnchorPoints?;
    private var currentPoint: CGPoint?;
    private var previousPoint1: CGPoint?;
    
    private var selectFigureService: SelectFigureService;
    
    private var state: String!
    
    init(origin: CGPoint, width: CGFloat, height: CGFloat) {
        self.firstPoint = CGPoint(x: origin.x - width/2, y: origin.y - height/2)
        self.lastPoint = CGPoint(x: origin.x + width/2, y: origin.y + height/2)
        self.figureColor = UIColor.clear
        self.lineWidth = 2
        self.lineColor = UIColor.black
        self.height = height
        self.width = width
        
        self.selectFigureService = SelectFigureService();
       
        let frame : CGRect = CGRect(x: self.firstPoint.x, y: self.firstPoint.y, width: self.width + 5, height: self.height + 5)
        super.init(frame: frame);
        self.selectFigureService.setInitialSelectedDashedBorder(bounds: self.bounds);
        self.selectFigureService.setInitialSelectedCornerCirles(firstPoint: self.firstPoint, lastPoint: self.lastPoint);
        self.backgroundColor = UIColor.clear;
    }
    
    init(firstPoint: CGPoint, lastPoint: CGPoint, width: CGFloat, height: CGFloat) {
        self.firstPoint = firstPoint
        self.lastPoint = lastPoint
        self.figureColor = UIColor.clear
        self.lineWidth = 2
        self.lineColor = UIColor.black
        self.anchorPoints = AnchorPoints(firstPoint: firstPoint, lastPoint: lastPoint)

        self.height = abs(lastPoint.y - firstPoint.y)
        self.width = abs(lastPoint.x - firstPoint.x)
        
        self.selectFigureService = SelectFigureService();
        
        let frame : CGRect = CGRect(x: self.firstPoint.x, y: self.firstPoint.y, width: self.width + 5, height: self.height + 5)
        super.init(frame: frame);
        self.selectFigureService.setInitialSelectedDashedBorder(bounds: self.bounds);
        self.selectFigureService.setInitialSelectedCornerCirles(firstPoint: self.firstPoint, lastPoint: self.lastPoint);
        self.backgroundColor = UIColor.clear;
        
        self.layer.addSublayer((self.anchorPoints?.anchorPointsBottom)!)
        self.layer.addSublayer((self.anchorPoints?.anchorPointsTop)!)
        self.layer.addSublayer((self.anchorPoints?.anchorPointsLeft)!)
        self.layer.addSublayer((self.anchorPoints?.anchorPointsRight)!)

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
//    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        print("touches began")
//        if (self.isSelected) {
//            guard let point = touches.first else { return };
//            previousPoint1 = point.previousLocation(in: self)
//            currentPoint = point.location(in: self)
//
//            let temp = CGRect(x: currentPoint!.x - 75/2, y: currentPoint!.y-75/2, width: 75, height: 75)
//
//            if (temp.contains(self.selectFigureService.selectedCornerCircle1.position)) {
//                self.isResizing = true;
//                self.resizingState = RESIZING.FROM_CIRCLE_1;
//            } else if (temp.contains(self.selectFigureService.selectedCornerCircle2.position)) {
//                self.isResizing = true;
//                self.resizingState = RESIZING.FROM_CIRCLE_2;
//            } else if (temp.contains(self.selectFigureService.selectedCornerCircle3.position)) {
//                self.isResizing = true;
//                self.resizingState = RESIZING.FROM_CIRCLE_3;
//            } else if (temp.contains(self.selectFigureService.selectedCornerCircle4.position)) {
//                self.isResizing = true;
//                self.resizingState = RESIZING.FROM_CIRCLE_4;
//            } else {
//                self.isDragging = true;
//                print("DRAGGING");
//            }
//
//            self.selectFigureService.removeSelectedFigureLayers();
//        }
//    }
    
//    public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
//        if(self.isSelected) {
//            guard let point = touches.first else { return };
//
//            previousPoint1 = point.previousLocation(in: self);
//            currentPoint = point.location(in: self);
//
//            let deltax = currentPoint!.x - previousPoint1!.x;
//            let deltay = currentPoint!.y - previousPoint1!.y;
//
//            if (self.isDragging) {
//                self.lastPoint.x += deltax;
//                self.lastPoint.y += deltay;
//                self.firstPoint.x += deltax;
//                self.firstPoint.y += deltay;
//            } else if (self.isResizing) {
//                switch (self.resizingState) {
//                case .FROM_CIRCLE_1:
//                    self.firstPoint.x += deltax;
//                    self.firstPoint.y += deltay;
//                    break;
//                case .FROM_CIRCLE_2:
//                    self.lastPoint.x += deltax;
//                    self.firstPoint.y += deltay;
//                    break;
//                case .FROM_CIRCLE_3:
//                    self.lastPoint.x += deltax;
//                    self.lastPoint.y += deltay;
//                    break;
//                case .FROM_CIRCLE_4:
//                    self.lastPoint.y += deltay;
//                    self.firstPoint.x += deltax;
//                    break;
//                default:
//                    break;
//                }
//            }
//
//            setNeedsDisplay();
//        }
//    }
    
//    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
//        self.isDragging = false;
//        self.isResizing = false;
//
//        self.selectFigureService.adjustSelectedFigureLayers(firstPoint: self.firstPoint, lastPoint: self.lastPoint, bounds: self.bounds, layer: self.layer);
//        setNeedsDisplay();
//    }
    
    public func setIsSelected() -> Void {
        self.isSelected = true;
//        self.selectFigureService.addSelectedFigureLayers(layer: self.layer);
//        let border = SelectionOutline(bounds: self.bounds, firstPoint: self.firstPoint, lastPoint: self.lastPoint)
//        border.addSelectedFigureLayers(layer: self.layer);
        setNeedsDisplay();
    }
    
    public func setIsNotSelected() -> Void {
        self.isSelected = false;
        self.selectFigureService.removeSelectedFigureLayers();
        setNeedsDisplay();
    }
    
    public func setFillColor(fillColor: UIColor) -> Void {
        self.figureColor = fillColor;
        setNeedsDisplay();
    }
    
    public func setBorderColor(borderColor: UIColor) -> Void {
        self.lineColor = borderColor;
        setNeedsDisplay();
    }
    
    public func update() {
        setNeedsDisplay()
    }
}
