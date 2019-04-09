//
//  EditorUndoRedo.swift
//  ios
//
//  Created by William Sevigny on 2019-04-07.
//  Copyright © 2019 LOG3000 equipe 12. All rights reserved.
//

import UIKit

extension Editor {
    // ** ONLY USED FOR UNDO / REDO **
    func insertFigures(drawViewModels: [DrawViewModel]) {
        var figure: Figure?
        
        for drawViewModel in drawViewModels  {
            figure = self.insertFigure(drawViewModel: drawViewModel)
        }

        if(figure != nil){
            if (figure! is UmlFigure) {
                (figure! as! UmlFigure).updateConnections(figures: self.figures)
            }
        }
    }
    
    // ** ONLY USED FOR UNDO / REDO  **
    func deleteFigures(drawViewModels: [DrawViewModel]) {
        for drawViewModel in drawViewModels {
            if let figure = self.getFigureFromDrawViewModel(model: drawViewModel) {
                figure.removeFromSuperview()
                self.figures.removeAll{$0 == figure}
            }
        }
        
        self.deselect()
    }
    
    public func undo(view: UIView) -> Void {
        if (self.undoArray.isEmpty) {
            return
        }
        
        let beforeAfter = undoArray.popLast()!
        
        if (beforeAfter.0.isEmpty) {
            self.deleteFigures(drawViewModels: beforeAfter.1)
            CollaborationHub.shared?.CutObjects(drawViewModels: beforeAfter.1)
            CanvasService.saveOnNewFigure(figures: self.figures, editor: self)
            self.redoArray.append(beforeAfter)
            return
        }
        
        if (beforeAfter.1.isEmpty) {
            self.insertFigures(drawViewModels: beforeAfter.0)
            CollaborationHub.shared?.postNewFigure(drawViewModels: beforeAfter.0)
            CanvasService.saveOnNewFigure(figures: self.figures, editor: self)
            self.redoArray.append(beforeAfter)
            return
        }
        
        self.deleteFigures(drawViewModels: beforeAfter.1)
        self.insertFigures(drawViewModels: beforeAfter.0)
        CollaborationHub.shared?.postNewFigure(drawViewModels: beforeAfter.0)
        CanvasService.saveOnNewFigure(figures: self.figures, editor: self)
        self.redoArray.append(beforeAfter)
    }
    
    
    public func redo(view: UIView) -> Void {
        if (self.redoArray.isEmpty) {
            return
        }
        
        let beforeAfter = redoArray.popLast()!
        
        if (beforeAfter.0.isEmpty) {
            self.insertFigures(drawViewModels: beforeAfter.1)
            CollaborationHub.shared?.postNewFigure(drawViewModels: beforeAfter.1)
            CanvasService.saveOnNewFigure(figures: self.figures, editor: self)
            self.undoArray.append(beforeAfter)
            return
        }
        
        if (beforeAfter.1.isEmpty) {
            self.deleteFigures(drawViewModels: beforeAfter.0)
            CollaborationHub.shared?.CutObjects(drawViewModels: beforeAfter.0)
            CanvasService.saveOnNewFigure(figures: self.figures, editor: self)
            self.undoArray.append(beforeAfter)
            return
        }
        
        self.deleteFigures(drawViewModels: beforeAfter.0)
        self.insertFigures(drawViewModels: beforeAfter.1)
        CollaborationHub.shared?.postNewFigure(drawViewModels: beforeAfter.1)
        CanvasService.saveOnNewFigure(figures: self.figures, editor: self)
        self.undoArray.append(beforeAfter)
    }
}
