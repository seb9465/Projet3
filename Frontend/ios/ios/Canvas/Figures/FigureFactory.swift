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
                return UmlClassFigure(origin: origin)
            case .Actor:
                return UmlImageFigure(origin: origin, figureType: UMLImageFigureType.actor)
            
        }
    }
    
    public func getFigure(type: ItemTypeEnum, firstPoint: CGPoint, lastPoint: CGPoint) -> UmlFigure? {
        switch (type) {
        case .RoundedRectangleStroke :
            return UmlClassFigure(firstPoint: firstPoint, lastPoint: lastPoint)
        case .Actor:
            return UmlImageFigure(firstPoint: firstPoint, lastPoint: lastPoint, figureType: UMLImageFigureType.actor)
        }
    }
    
//    public func getSelectionOutline() -> SelectionOutline {
//        return SelectionOutline(bounds: <#T##CGRect#>, firstPoint: <#T##CGPoint#>, lastPoint: <#T##CGPoint#>)
//    }
}
