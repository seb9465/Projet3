//
//  ImageFigure.swift
//  ios
//
//  Created by Sébastien Labine on 19-03-12.
//  Copyright © 2019 LOG3000 equipe 12. All rights reserved.
//

import Foundation
import CoreGraphics
import UIKit
class UmlImageFigure: UmlFigure {
    let BASE_WIDTH: CGFloat = 150
    let BASE_HEIGHT: CGFloat = 200
    
    
    init(origin: CGPoint) {
        super.init(touchedPoint: origin, width: BASE_WIDTH, height: BASE_HEIGHT)
    }
    
    init(firstPoint: CGPoint, lastPoint: CGPoint) {
        super.init(firstPoint: firstPoint, lastPoint: lastPoint, width: self.BASE_WIDTH, height: BASE_WIDTH)
//        self.figureID = Constants.figureIDCounter;
        Constants.figureIDCounter += 1;
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
