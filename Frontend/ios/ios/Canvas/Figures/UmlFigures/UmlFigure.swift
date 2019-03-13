//
//  BaseFigure.swift
//  ios
//
//  Created by William Sevigny on 2019-03-11.
//  Copyright © 2019 LOG3000 equipe 12. All rights reserved.
//

import UIKit

protocol touchInputDelegate {
    func setPointTouched(point: CGPoint)
    func insertFigure(firstPoint: CGPoint, lastPoint: CGPoint, type: ItemTypeEnum)
}

class UmlFigure : Figure {
    var delegate: touchInputDelegate?
    
    var firstPoint: CGPoint!
    var lastPoint: CGPoint!
    var width: CGFloat!
    var height: CGFloat!
    var figureColor: UIColor!
    var lineWidth: CGFloat!
    var lineColor: UIColor!
        
    var anchorPoints: AnchorPoints?;

    init(origin: CGPoint, width: CGFloat, height: CGFloat) {
        self.firstPoint = CGPoint(x: origin.x - width/2, y: origin.y - height/2)
        self.lastPoint = CGPoint(x: origin.x + width/2, y: origin.y + height/2)
        self.figureColor = UIColor.clear
        self.lineWidth = 2
        self.lineColor = UIColor.black
        self.height = height
        self.width = width
        
        let frame : CGRect = CGRect(x: self.firstPoint.x, y: self.firstPoint.y, width: self.width + 5, height: self.height + 5)
        super.init(frame: frame);
        self.backgroundColor = UIColor.clear;
    }
    
    init(firstPoint: CGPoint, lastPoint: CGPoint, width: CGFloat, height: CGFloat) {
        self.firstPoint = firstPoint
        self.lastPoint = lastPoint
        self.figureColor = UIColor.clear
        self.lineWidth = 2
        self.lineColor = UIColor.black
        
        let frameSize = CGSize(width: abs(firstPoint.x - lastPoint.x), height: abs(firstPoint.y - lastPoint.y))
        let frame = CGRect(origin: firstPoint, size: frameSize)
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.clear;
        
        self.anchorPoints = AnchorPoints(width: frameSize.width, height: frameSize.height)
        self.layer.addSublayer((self.anchorPoints?.anchorPointsBottom)!)
        self.layer.addSublayer((self.anchorPoints?.anchorPointsTop)!)
        self.layer.addSublayer((self.anchorPoints?.anchorPointsLeft)!)
        self.layer.addSublayer((self.anchorPoints?.anchorPointsRight)!)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func setFillColor(fillColor: UIColor) -> Void {
        self.figureColor = fillColor;
        setNeedsDisplay();
    }
    
    public func setBorderColor(borderColor: UIColor) -> Void {
        self.lineColor = borderColor;
        setNeedsDisplay();
    }
    
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        
        guard let point = touch?.location(in: self) else { return }
        guard let sublayers = self.layer.sublayers as? [CAShapeLayer] else { return }
        
        for layer in sublayers{
            if let path = layer.path, path.contains(point) {
                print("Touched an anchor")
                guard let globalPoint = touch?.location(in: self.superview) else { return }
                self.delegate!.setPointTouched(point: globalPoint)
            }
        }
    }
    
    public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
//        let touch = touches.first
//        guard let point = touch?.location(in: self) else { return }
//        let global = convert(point, to: self.superview)
//        print("Moved", global)
    }
    
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        guard let point = touch?.location(in: self.superview) else { return }
        
        // TODO: FirstPoint is position of selected anchor
        self.delegate?.insertFigure(firstPoint: CGPoint.zero, lastPoint: point, type: .Connection)
    }
    
    public override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        guard let point = touch?.location(in: self.superview) else { return }
        print("Touches cancelled", point)
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
    
}
