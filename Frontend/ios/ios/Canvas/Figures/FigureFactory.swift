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
        }
    }
    
    public func getFigure(type: ItemTypeEnum, firstPoint: CGPoint, lastPoint: CGPoint) -> UmlFigure? {
        switch (type) {
        case .RoundedRectangleStroke :
            return ClassUmlFigure(firstPoint: firstPoint, lastPoint: lastPoint)
        }
    }
    
//    public func getSelectionOutline() -> SelectionOutline {
//        return SelectionOutline(bounds: <#T##CGRect#>, firstPoint: <#T##CGPoint#>, lastPoint: <#T##CGPoint#>)
//    }
}
