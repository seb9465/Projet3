//
//  EditorUtilities.swift
//  ios
//
//  Created by William Sevigny on 2019-04-06.
//  Copyright © 2019 LOG3000 equipe 12. All rights reserved.
//

import UIKit

extension Editor {

    func getSelectedFiguresDrawviewModels() -> [DrawViewModel] {
        var drawViewModels: [DrawViewModel] = []
        for figure in selectedFigures {
            drawViewModels.append(figure.exportViewModel()!)
        }

        return drawViewModels
    }
    
    func getFiguresDrawviewModels(figures: [Figure]) -> [DrawViewModel] {
        var drawViewModels: [DrawViewModel] = []
        for figure in figures {
            drawViewModels.append(figure.exportViewModel()!)
        }
        
        return drawViewModels
    }
    
//    func getConnectionAndAnchoredFiguresModels(connection: ConnectionFigure) {
//        
//    }
    
    func getUmlFigures() -> [UmlFigure] {
        return self.figures.filter({$0 is UmlFigure}) as! [UmlFigure]
    }
    
    func getFigureFromDrawViewModel(model: DrawViewModel) -> Figure {
        return self.figures.first(where: {$0.uuid.uuidString.lowercased() == model.Guid})!
    }
    
    func isAllAnchoredFiguresInSelection(connection: ConnectionFigure) -> Bool{
        if (connection.getAnchoredUmlFigures(umlFigures: self.getUmlFigures()).isEmpty) {
            return true
        }
        
        for umlFigure in connection.getAnchoredUmlFigures(umlFigures: self.getUmlFigures()) {
            if (!self.selectedFigures.contains(umlFigure)) {
                return false
            }
        }
        
        return true
    }
    
    func getFigureContaining(point: CGPoint) -> UmlFigure? {
        for subview in self.editorView.subviews {
            if let figure = subview as? UmlFigure {
                if (figure.frame.contains(point)) {
                    return figure
                }
            }
        }
        return nil
    }
}
