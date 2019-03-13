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

    public func getFigure(type: ItemTypeEnum, firstPoint: CGPoint, lastPoint: CGPoint) -> UmlFigure? {
        switch (type) {
            case .RoundedRectangleStroke :
                return UmlClassFigure(firstPoint: firstPoint, lastPoint: lastPoint)
            case .Actor:
                return UmlImageFigure(firstPoint: firstPoint, lastPoint: lastPoint, figureType: UMLImageFigureType.actor)
            case.Connection:
                return nil
    //            return ConnectionFigure(origin: firstPoint, destination: lastPoint)
        }
    }
    
    // Alternate init to create UmlFigures on user tap
    public func getFigureModel(type: ItemTypeEnum, touchedPoint: CGPoint) -> Figure? {
        switch (type) {
            case .RoundedRectangleStroke :
                return UmlClassFigure(origin: touchedPoint)
            case .Actor:
                return UmlImageFigure(origin: touchedPoint, figureType: UMLImageFigureType.actor)
            case .Connection:
                return nil
            }
    }

}
