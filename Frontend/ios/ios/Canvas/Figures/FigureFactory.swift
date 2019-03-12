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
    
    public func getFigure(type: ItemTypeEnum, origin: CGPoint) -> UmlFigure? {
        switch (type) {
            case .RoundedRectangleStroke :
                return ClassUmlFigure(origin: origin)
            case .Actor:
                return UMLImageFigure(origin: origin, figureType: UMLImageFigureType.actor)
            
        }
    }
    
    public func getFigure(type: ItemTypeEnum, firstPoint: CGPoint, lastPoint: CGPoint) -> UmlFigure? {
        switch (type) {
        case .RoundedRectangleStroke :
            return ClassUmlFigure(firstPoint: firstPoint, lastPoint: lastPoint)
        case .Actor:
            return UMLImageFigure(firstPoint: firstPoint, lastPoint: lastPoint, figureType: UMLImageFigureType.actor)
        }
    }
    
//    public func getSelectionOutline() -> SelectionOutline {
//        return SelectionOutline(bounds: <#T##CGRect#>, firstPoint: <#T##CGPoint#>, lastPoint: <#T##CGPoint#>)
//    }
}
