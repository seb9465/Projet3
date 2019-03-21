//
//  UMLPhaseFigure.swift
//  ios
//
//  Created by Sébastien Labine on 19-03-21.
//  Copyright © 2019 LOG3000 equipe 12. All rights reserved.
//

import UIKit

class UmlPhaseFigure: UmlFigure {
    public var phaseName: String = "PhaseName"
    private var currentAngle: Double = 0
    let BASE_WIDTH: CGFloat = 400
    let BASE_HEIGHT: CGFloat = 250
    
    init(firstPoint: CGPoint, lastPoint: CGPoint) {
        super.init(firstPoint: firstPoint, lastPoint: lastPoint, width: BASE_WIDTH, height: BASE_WIDTH)
    }
    
    init(origin: CGPoint) {
        super.init(touchedPoint: origin, width: BASE_WIDTH, height: BASE_HEIGHT)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func setPhaseName(phaseName: String) -> Void {
        self.phaseName = phaseName;
        setNeedsDisplay();
    }
    
    
    override public func rotate(orientation: RotateOrientation) -> Void {
        if (orientation == RotateOrientation.right) {
            currentAngle += 90
        } else {
            currentAngle -= 90
        }
        
        if (abs(currentAngle) == 360) {
            currentAngle = 0
        }
        
        self.transform = CGAffineTransform.init(rotationAngle: CGFloat(currentAngle * Double.pi/180))
        setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
         let outerRect = CGRect(x: 0, y: 0, width: BASE_WIDTH, height: BASE_HEIGHT).insetBy(dx: 5, dy: 5);
        let phaneNameRect = CGRect(x: 0, y: 0, width: BASE_WIDTH, height: 50).insetBy(dx: 5, dy: 5);
        
        let phaseNameLabel = UILabel(frame: phaneNameRect)
        UIRectFill()
        phaseNameLabel.text = self.phaseName
        phaseNameLabel.textAlignment = .center
        phaseNameLabel.drawText(in: phaneNameRect)
        let outerRectPath = UIBezierPath(rect: outerRect)
        let commentRectPath = UIBezierPath(rect: phaneNameRect)
        
        self.figureColor.setFill()
        self.lineColor.setStroke()
        
        commentRectPath.lineWidth = self.lineWidth
        commentRectPath.fill()
        commentRectPath.stroke()

        outerRectPath.lineWidth = self.lineWidth
        outerRectPath.fill()
        outerRectPath.stroke()
    }
}
