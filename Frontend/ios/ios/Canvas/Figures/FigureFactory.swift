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
    
    public func getFigure(itemType: ItemTypeEnum, firstPoint: CGPoint, lastPoint: CGPoint) -> UmlFigure? {
        switch (itemType) {
        case .UMLClass :
            return UmlClassFigure(firstPoint: firstPoint, lastPoint: lastPoint)
        case .Actor:
            return UmlImageFigure(firstPoint: firstPoint, lastPoint: lastPoint, figureType: UMLImageFigureType.actor)
        
        case .UMLComment:
            return UmlCommentFigure(firstPoint: firstPoint, lastPoint: lastPoint)
            
        case.StraightLine:
            return nil
        case.DashedLine:
            return nil
        //            return ConnectionFigure(origin: firstPoint, destination: lastPoint)
        case .Artefact:
            return UmlArtefactFigure(firstPoint: firstPoint, lastPoint: lastPoint)
        case .Phase:
            return nil
        }
    }
    
    // Alternate init to create UmlFigures on user tap
    public func getFigure(type: ItemTypeEnum, touchedPoint: CGPoint) -> Figure? {
        switch (type) {
        case .UMLClass :
            return UmlClassFigure(origin: touchedPoint)
        case .Actor:
            return UmlImageFigure(origin: touchedPoint, figureType: UMLImageFigureType.actor)
        case .UMLComment:
            return UmlCommentFigure(origin: touchedPoint)
        case.StraightLine:
            return nil
        case.DashedLine:
            return nil
        case .Artefact:
            return UmlArtefactFigure(origin: touchedPoint)

        case .Phase:
            return nil
            
        }
    }
    
}
