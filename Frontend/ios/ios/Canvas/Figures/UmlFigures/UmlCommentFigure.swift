//
//  CommentFigure.swift
//  ios
//
//  Created by Sébastien Labine on 19-03-21.
//  Copyright © 2019 LOG3000 equipe 12. All rights reserved.
//

import UIKit

class UmlCommentFigure: UmlFigure {
    public var comment: String = "comment"
    private var currentAngle: Double = 0
    let BASE_WIDTH: CGFloat = 150
    let BASE_HEIGHT: CGFloat = 50
    
    init(firstPoint: CGPoint, lastPoint: CGPoint) {
        super.init(firstPoint: firstPoint, lastPoint: lastPoint, width: BASE_WIDTH, height: BASE_WIDTH)
    }
    
    init(origin: CGPoint) {
        super.init(touchedPoint: origin, width: BASE_WIDTH, height: BASE_HEIGHT)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func setComment(comment: String) -> Void {
        self.comment = comment;
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
        let nameRect = CGRect(x: 0, y: 0, width: BASE_WIDTH, height: BASE_HEIGHT).insetBy(dx: 5, dy: 5);
        
        let commentLabel = UILabel(frame: nameRect)
        commentLabel.text = self.comment
        commentLabel.textAlignment = .center
        commentLabel.drawText(in: nameRect)
        
        let nameRectPath = UIBezierPath(rect: nameRect)
        
        self.figureColor.setFill()
        self.lineColor.setStroke()

        nameRectPath.lineWidth = self.lineWidth
        nameRectPath.fill()
        nameRectPath.stroke()
    }
}
