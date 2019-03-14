//
//  BaseFigure.swift
//  ios
//
//  Created by William Sevigny on 2019-03-11.
//  Copyright © 2019 LOG3000 equipe 12. All rights reserved.
//

import UIKit

protocol TouchInputDelegate {
    func notifyTouchBegan(action: String, point: CGPoint, figure: Figure?)
    func notifyTouchMoved(point: CGPoint, figure: Figure)
    func notifyTouchEnded(point: CGPoint)
}

class UmlFigure : Figure {
    var delegate: TouchInputDelegate?
    var figureColor: UIColor!
    var lineWidth: CGFloat!
    var lineColor: UIColor!
    var oldTouchedPoint: CGPoint!
        
    var anchorPoints: AnchorPoints?;
    
    init(firstPoint: CGPoint, lastPoint: CGPoint, width: CGFloat, height: CGFloat) {
        let frameSize = CGSize(width: abs(firstPoint.x - lastPoint.x), height: abs(firstPoint.y - lastPoint.y))
        let frame = CGRect(origin: firstPoint, size: frameSize)
        super.init(frame: frame)
        self.firstPoint = firstPoint
        self.lastPoint = lastPoint
        self.initializeBaseStyle()
        self.initializeAnchorPoints()
    }
    
    // Alternate init to create UmlFigures on user tap
    init(touchedPoint: CGPoint, width: CGFloat, height: CGFloat) {
        let frameSize = CGSize(width: width, height: height)
        let frame = CGRect(origin: CGPoint(x: touchedPoint.x - width/2, y: touchedPoint.y - height/2), size: frameSize)
        super.init(frame: frame);
        self.firstPoint = CGPoint(x: touchedPoint.x - width/2, y: touchedPoint.y - height/2)
        self.lastPoint = CGPoint(x: touchedPoint.x + width/2, y: touchedPoint.y + height/2)
        self.initializeBaseStyle()
        self.initializeAnchorPoints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initializeBaseStyle() {
        self.figureColor = UIColor.clear
        self.lineWidth = 2
        self.lineColor = UIColor.black
        self.backgroundColor = UIColor.clear;
    }
    
    private func initializeAnchorPoints() {
        self.anchorPoints = AnchorPoints(width: self.frame.width, height: self.frame.height)
        self.layer.addSublayer((self.anchorPoints?.anchorPointsBottom)!)
        self.layer.addSublayer((self.anchorPoints?.anchorPointsTop)!)
        self.layer.addSublayer((self.anchorPoints?.anchorPointsLeft)!)
        self.layer.addSublayer((self.anchorPoints?.anchorPointsRight)!)
    }
    
    public func setFillColor(fillColor: UIColor) -> Void {
        self.figureColor = fillColor;
        setNeedsDisplay();
    }
    
    public func setBorderColor(borderColor: UIColor) -> Void {
        self.lineColor = borderColor;
        setNeedsDisplay();
    }
    
    public func translate(by: CGPoint) {
        let translatedFrame = self.frame.offsetBy(dx: by.x, dy: by.y)
        self.frame = translatedFrame
        self.firstPoint = self.frame.origin
        self.lastPoint = CGPoint(x: self.frame.maxX, y: self.frame.maxY) 
    }
    
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        guard let point = touch?.location(in: self) else { return }
        guard let sublayers = self.layer.sublayers as? [CAShapeLayer] else { return }

        for layer in sublayers{
            if let path = layer.path, path.contains(point) {
                let snapPoint = convert((self.anchorPoints?.anchorPointsSnapEdges[layer.name!])!, to: self.superview)
                self.delegate?.notifyTouchBegan(action: "anchor", point: snapPoint, figure: self)
                return
            }
        }
        
        let editorPoint = convert(point, to: self.superview)
        self.delegate?.notifyTouchBegan(action: "shape", point: editorPoint, figure: self)
    }
    
    public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        guard let point = touch?.location(in: self.superview) else { return }
        
        self.delegate?.notifyTouchMoved(point: point, figure: self)
    }
    
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        guard let point = touch?.location(in: self.superview) else { return }
        self.delegate?.notifyTouchEnded(point: point)
    }
    
    public override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        guard let point = touch?.location(in: self.superview) else { return }
        self.delegate?.notifyTouchEnded(point: point)
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
