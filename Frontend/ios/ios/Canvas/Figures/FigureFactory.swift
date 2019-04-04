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
                return ConnectionAgregation(drawViewModel: drawViewModel)
            case .BidirectionalAssociation:
                return ConnectionAssociationBi(drawViewModel: drawViewModel)
            case .UniderectionalAssoication:
                return ConnectionAssociationUni(drawViewModel: drawViewModel)
            case .Composition:
                return ConnectionComposition(drawViewModel: drawViewModel)
            case .Inheritance:
                return ConnectionHeritage(drawViewModel: drawViewModel)
        }
    }
    
    // Alternate init to create UmlFigures on user tap
    public func getFigure(type: ItemTypeEnum, touchedPoint: CGPoint? = nil, source: CGPoint? = nil, destination: CGPoint? = nil) -> Figure? {
        switch (type) {
        case .UmlClass :
            return UmlClassFigure(origin: touchedPoint!)
        case .Role:
            return UmlActorFigure(origin: touchedPoint!)
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
            return ConnectionAgregation(origin: source!, destination: destination!, itemType: type)
        case .BidirectionalAssociation:
            return ConnectionAssociationBi(origin: source!, destination: destination!, itemType: type)
        case .UniderectionalAssoication:
            return ConnectionAssociationUni(origin: source!, destination: destination!, itemType: type)
        case .Composition:
            return ConnectionComposition(origin: source!, destination: destination!, itemType: type)
//            return nil
        case .Inheritance:
            return ConnectionHeritage(origin: source!, destination: destination!, itemType: type)
        }
    }
}
