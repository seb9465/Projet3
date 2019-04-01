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
        case .UmlClass :
            return UmlClassFigure(firstPoint: firstPoint, lastPoint: lastPoint)
        case .Role:
            return UmlActorFigure(firstPoint: firstPoint, lastPoint: lastPoint)
//            return UmlImageFigure(firstPoint: firstPoint, lastPoint: lastPoint, figureType: UMLImageFigureType.actor)
        
        case .Comment:
            return UmlCommentFigure(firstPoint: firstPoint, lastPoint: lastPoint)
        case .Phase:
            return UmlPhaseFigure(firstPoint: firstPoint, lastPoint: lastPoint)
        case .Text:
            return UMLTextFigure(firstPoint: firstPoint, lastPoint: lastPoint)
        case .Image:
           return UMLTextFigure(firstPoint: firstPoint, lastPoint: lastPoint)
        //            return ConnectionFigure(origin: firstPoint, destination: lastPoint)
        case .Artefact:
            return UmlArtefactFigure(firstPoint: firstPoint, lastPoint: lastPoint)
        case .Activity:
            return UmlActivityFigure(firstPoint: firstPoint, lastPoint: lastPoint)
        case .Agregation:
            return nil
        case .BidirectionalAssociation:
            return nil
        case .UniderectionalAssoication:
            return nil
        case .Composition:
            return nil
        case .Inheritance:
            return nil
        }
    }
    
    // Alternate init to create UmlFigures on user tap
    public func getFigure(type: ItemTypeEnum, touchedPoint: CGPoint) -> UmlFigure? {
        switch (type) {
        case .UmlClass :
            return UmlClassFigure(origin: touchedPoint)
        case .Role:
            return UmlActorFigure(origin: touchedPoint)
//            return UmlImageFigure(origin: touchedPoint, figureType: UMLImageFigureType.actor)
        case .Artefact:
            return UmlArtefactFigure(origin: touchedPoint)
        case .Activity:
            return UmlActivityFigure(origin: touchedPoint)
        case .Comment:
            return UmlCommentFigure(origin: touchedPoint)
        case .Phase:
            return UmlPhaseFigure(origin: touchedPoint)
         case .Text:
            return UMLTextFigure(origin: touchedPoint)
        case .Image:
            return UMLTextFigure(origin: touchedPoint)

        case .Agregation:
            return nil
        case .BidirectionalAssociation:
            return nil
        case .UniderectionalAssoication:
            return nil
        case .Composition:
            return nil
        case .Inheritance:
            return nil
        }
    }
    
}
