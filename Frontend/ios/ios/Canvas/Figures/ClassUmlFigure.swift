//
//  ClassUmlFigure.swift
//  ios
//
//  Created by William Sevigny on 2019-03-11.
//  Copyright © 2019 LOG3000 equipe 12. All rights reserved.
//

import UIKit

class ClassUmlFigure: CanvasFigure {
    
    // Constants
    static let BASE_WIDTH: CGFloat = 100
    static let BASE_HEIGHT: CGFloat = 100
    
    init(origin: CGPoint) {
        super.init(origin: origin, width: ClassUmlFigure.BASE_WIDTH, height: ClassUmlFigure.BASE_HEIGHT)
    }
    
    init(firstPoint: CGPoint, lastPoint: CGPoint) {
        super.init(firstPoint: firstPoint, lastPoint: lastPoint, width: ClassUmlFigure.BASE_WIDTH, height: ClassUmlFigure.BASE_WIDTH)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        // Drawing the figure.
        let r: CGRect = CGRect(x: 1, y: 1, width: lastPoint.x - firstPoint.x, height: lastPoint.y - firstPoint.y);

        // Inset to be able to place a border.
        let insetRect = r.insetBy(dx: 4, dy: 4);

        let path = UIBezierPath(roundedRect: insetRect, cornerRadius: 10);

        // Border and fill parameters.
        self.figureColor.setFill();
        path.lineWidth = self.lineWidth;
        self.lineColor.setStroke();
        path.fill();
        path.stroke();
    }
}
