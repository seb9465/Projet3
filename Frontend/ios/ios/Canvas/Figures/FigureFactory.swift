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
    
    public func fromDrawViewModel(drawViewModel: DrawViewModel) -> Figure? {
        switch (drawViewModel.ItemType!) {
            case .UmlClass :
                return UmlClassFigure(drawViewModel: drawViewModel)
            case .Role:
                return UmlActorFigure(drawViewModel: drawViewModel)
            case .Comment:
                return UmlCommentFigure(drawViewModel: drawViewModel)
            case .Phase:
                return UmlPhaseFigure(drawViewModel: drawViewModel)
            case .Text:
                return UMLTextFigure(drawViewModel: drawViewModel)
            case .Image:
                return UMLTextFigure(drawViewModel: drawViewModel)
            case .Artefact:
                return UmlArtefactFigure(drawViewModel: drawViewModel)
            case .Activity:
                return UmlActivityFigure(drawViewModel: drawViewModel)
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
    public func getFigure(type: ItemTypeEnum, touchedPoint: CGPoint? = nil, source: CGPoint? = nil, destination: CGPoint? = nil) -> Figure? {
        switch (type) {
        case .UmlClass :
            return UmlClassFigure(origin: touchedPoint!)
        case .Role:
            return UmlActorFigure(origin: touchedPoint!)
//            return UmlImageFigure(origin: touchedPoint, figureType: UMLImageFigureType.actor)
        case .Artefact:
            return UmlArtefactFigure(origin: touchedPoint!)
        case .Activity:
            return UmlActivityFigure(origin: touchedPoint!)
        case .Comment:
            return UmlCommentFigure(origin: touchedPoint!)
        case .Phase:
            return UmlPhaseFigure(origin: touchedPoint!)
         case .Text:
            return UMLTextFigure(origin: touchedPoint!)
        case .Image:
            return UMLTextFigure(origin: touchedPoint!)
        case .Agregation:
//            return nil
            return ConnectionAgregation(origin: source!, destination: destination!, itemType: type)
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
