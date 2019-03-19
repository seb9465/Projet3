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
    static let BASE_WIDTH: CGFloat = 150
    static let BASE_HEIGHT: CGFloat = 200
    
    public var className: String = "ClassName"
    public var methods: [String] = []

    
    init(origin: CGPoint) {
        super.init(touchedPoint: origin, width: UmlClassFigure.BASE_WIDTH, height: UmlClassFigure.BASE_HEIGHT)
    }
    
    init(firstPoint: CGPoint, lastPoint: CGPoint) {
        super.init(firstPoint: firstPoint, lastPoint: lastPoint, width: UmlClassFigure.BASE_WIDTH, height: UmlClassFigure.BASE_WIDTH)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func setClassName(name: String) -> Void {
        self.className = name;
        setNeedsDisplay();
    }
    
    public func addMethod(name: String) {
        self.methods.append(name)
        setNeedsDisplay();
    }
    
    public func removeMethod(name: String, index: Int) {
        self.methods.remove(at: index)
//        self.methods.append(name)
        setNeedsDisplay();
    }
    
    override func draw(_ rect: CGRect) {
        let outerRect = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height).insetBy(dx: 5, dy: 5);
        let nameRect = CGRect(x: 0, y: 0, width: self.frame.width, height: 50).insetBy(dx: 5, dy: 5);
        
        let nameLabel = UILabel(frame: nameRect)
        nameLabel.text = self.className
        nameLabel.textAlignment = .center
        nameLabel.drawText(in: nameRect)
        
        
        for n in 0..<self.methods.count {
            let methodRect = CGRect(x: 0, y: CGFloat(50 + (16 * n)), width: self.frame.width, height: 16).insetBy(dx: 5, dy: 5);
            let methodLabel = UILabel(frame: methodRect)
            methodLabel.text = "  • " + self.methods[n]
            methodLabel.textAlignment = .left
            methodLabel.drawText(in: methodRect)
        }

        let outerRectPath = UIBezierPath(rect: outerRect)
        let nameRectPath = UIBezierPath(rect: nameRect)
        
        self.figureColor.setFill()
        self.lineColor.setStroke()
        
        nameRectPath.lineWidth = self.lineWidth
        nameRectPath.fill()
        nameRectPath.stroke()
        
        outerRectPath.lineWidth = self.lineWidth
        outerRectPath.fill()
        outerRectPath.stroke()
    }
}
