//
//  ClassUmlFigure.swift
//  ios
//
//  Created by William Sevigny on 2019-03-11.
//  Copyright © 2019 LOG3000 equipe 12. All rights reserved.
//

import UIKit

class ClassUmlFigure: UmlFigure {
    
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
        let r: CGRect = CGRect(x: 1, y: 1, width: lastPoint.x - firstPoint.x, height: lastPoint.y - firstPoint.y);
        let insetRect = r.insetBy(dx: 4, dy: 4);
        let path = UIBezierPath(roundedRect: insetRect, cornerRadius: 10);
        self.figureColor.setFill();
        path.lineWidth = self.lineWidth;
        self.lineColor.setStroke();
        
        if (self.isSelected) {
            
        }
        
        path.fill();
        path.stroke();
    }
}
