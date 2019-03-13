//
//  ClassUmlFigure.swift
//  ios
//
//  Created by William Sevigny on 2019-03-11.
//  Copyright © 2019 LOG3000 equipe 12. All rights reserved.
//

import UIKit

class UmlClassFigure: UmlFigure {
    
    // Constants
    static let BASE_WIDTH: CGFloat = 100
    static let BASE_HEIGHT: CGFloat = 100
    
    init(origin: CGPoint) {
        super.init(touchedPoint: origin, width: UmlClassFigure.BASE_WIDTH, height: UmlClassFigure.BASE_HEIGHT)
    }
    
    init(firstPoint: CGPoint, lastPoint: CGPoint) {
        super.init(firstPoint: firstPoint, lastPoint: lastPoint, width: UmlClassFigure.BASE_WIDTH, height: UmlClassFigure.BASE_WIDTH)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        let rect = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
        let insetRect = rect.insetBy(dx: 5, dy: 5);
        let path = UIBezierPath(roundedRect: insetRect, cornerRadius: 10);
        self.figureColor.setFill();
        path.lineWidth = self.lineWidth;
        self.lineColor.setStroke();
        path.fill();
        path.stroke();
    }
}
