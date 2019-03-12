//
//  FigureFactory.swift
//  ios
//
//  Created by William Sevigny on 2019-03-11.
//  Copyright © 2019 LOG3000 equipe 12. All rights reserved.
//

import UIKit

class FigureFactory {
    
    static let shared = FigureFactory()
    
    public func getFigure(type: ItemTypeEnum, origin: CGPoint) -> CanvasFigure? {
        switch (type) {
            case .RoundedRectangleStroke :
                return ClassUmlFigure(origin: origin)
        }
    }
    
    public func getFigure(type: ItemTypeEnum, firstPoint: CGPoint, lastPoint: CGPoint) -> CanvasFigure? {
        switch (type) {
        case .RoundedRectangleStroke :
            return ClassUmlFigure(firstPoint: firstPoint, lastPoint: lastPoint)
        }
    }
    
}
