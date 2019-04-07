//
//  EditorUtilities.swift
//  ios
//
//  Created by William Sevigny on 2019-04-06.
//  Copyright © 2019 LOG3000 equipe 12. All rights reserved.
//

extension Editor {

    func getSelectedFiguresDrawviewModels() -> [DrawViewModel] {
        var drawViewModels: [DrawViewModel] = []
        for figure in selectedFigures {
            drawViewModels.append(figure.exportViewModel()!)
        }

        return drawViewModels
    }
    
    func getUmlFigures() -> [UmlFigure] {
        return self.figures.filter({$0 is UmlFigure}) as! [UmlFigure]
    }
    
    func isAllAnchoredFiguresInSelection(connection: ConnectionFigure) -> Bool{
        if (connection.getAnchoredUmlFigures(umlFigures: self.getUmlFigures()).isEmpty) {
            return true
        }
        
        for umlFigure in connection.getAnchoredUmlFigures(umlFigures: self.getUmlFigures()) {
            if (!self.selectedFigures.contains(umlFigure)) {
                print("Shuld not move")
                return false
            }
        }
        
        return true
    }
}
