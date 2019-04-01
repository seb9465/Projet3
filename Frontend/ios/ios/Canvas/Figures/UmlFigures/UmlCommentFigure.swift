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
    let BASE_WIDTH: CGFloat = 150
    let BASE_HEIGHT: CGFloat = 50
    
    init(firstPoint: CGPoint, lastPoint: CGPoint) {
        super.init(firstPoint: firstPoint, lastPoint: lastPoint, width: BASE_WIDTH, height: BASE_WIDTH)
//        self.figureID = Constants.figureIDCounter;
        Constants.figureIDCounter += 1;
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
    
    override func draw(_ rect: CGRect) {
        let commentRect = CGRect(x: 0, y: 0, width: BASE_WIDTH, height: BASE_HEIGHT).insetBy(dx: 5, dy: 5);
        
        let commentLabel = UILabel(frame: commentRect)
        commentLabel.text = self.comment
        commentLabel.textAlignment = .center
        commentLabel.drawText(in: commentRect)
        
        let commentRectPath = UIBezierPath(rect: commentRect)
        
        self.figureColor.setFill()
        self.lineColor.setStroke()

        commentRectPath.lineWidth = self.lineWidth
        commentRectPath.fill()
        commentRectPath.stroke()
    }
}
