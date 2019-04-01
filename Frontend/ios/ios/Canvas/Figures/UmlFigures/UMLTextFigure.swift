//
//  UMLTextFigure.swift
//  ios
//
//  Created by Sébastien Labine on 19-03-22.
//  Copyright © 2019 LOG3000 equipe 12. All rights reserved.
//

import UIKit

class UMLTextFigure: UmlFigure {
    public var text: String = "text"
    let BASE_WIDTH: CGFloat = 100
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
    
    public func setText(text: String) -> Void {
        self.text = text;
        setNeedsDisplay();
    }
    
    override func draw(_ rect: CGRect) {
        let textRect = CGRect(x: 0, y: 0, width: BASE_WIDTH, height: BASE_HEIGHT).insetBy(dx: 5, dy: 5);
        let textLabel = UILabel(frame: textRect)
        textLabel.text = self.text
        textLabel.textAlignment = .center
        textLabel.drawText(in: textRect)
    }
}
