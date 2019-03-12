//
//  Editor.swift
//  ios
//
//  Created by William Sevigny on 2019-03-11.
//  Copyright © 2019 LOG3000 equipe 12. All rights reserved.
//

import UIKit

class Editor {
//    private var commands: [EditorCommand] = []
    private var undoArray: [UmlFigure] = []
    private var redoArray: [UmlFigure] = [];
    
    public var editorView: EditorView = EditorView()
    public var selectedFigure: UmlFigure!;
    
//    public func insertFigure(origin: CGPoint) -> Void {
//        let figure = FigureFactory.shared.getFigure(type: ItemTypeEnum.RoundedRectangleStroke, origin: origin)!;
//        self.editorView.addSubview(figure);
//        self.undoArray.append(figure);
//    }
    
    public func insertFigure(firstPoint: CGPoint, lastPoint: CGPoint) -> Void {
        let figure = FigureFactory.shared.getFigure(type: ItemTypeEnum.RoundedRectangleStroke, firstPoint: firstPoint, lastPoint: lastPoint)!
        self.editorView.addSubview(figure);
        self.undoArray.append(figure);
    }
    
    public func moveFigure(translation: CGPoint) {
//        self.selectedFigure.center = CGPoint(
//            x:self.selectedFigure.center.x + translation.x,
//            y:self.selectedFigure.center.y + translation.y
//        )
    }
    
    public func undo(view: UIView) -> Void {
        print(undoArray);
        if (undoArray.count > 0) {
            let figure: UmlFigure = view.subviews.last as! UmlFigure;
            self.redoArray.append(figure);
            figure.removeFromSuperview();
            self.undoArray.removeLast();
        }
    }
    
    public func redo(view: UIView) -> Void {
        if (redoArray.count > 0) {
            let figure: UmlFigure = self.redoArray.last!;
            view.addSubview(figure);
            self.undoArray.append(figure);
            self.redoArray.removeLast();
        }
    }
    
    public func clear() -> Void {
        for v in self.undoArray {
            v.removeFromSuperview();
        }
        self.undoArray.removeAll();
        self.redoArray.removeAll();
    }
    
    public func figuresInView() -> Bool {
        return self.undoArray.count > 0;
    }
    
    public func subviewIsInUndoArray(subview: UIView) -> Bool {
        for a in self.undoArray {
            if (a == subview) {
                return true;
            }
        }
        
        return false;
    }
    
    public func deleteFigure(tapPoint: CGPoint) -> Void {
        let subview = self.editorView.hitTest(tapPoint, with: nil);
        
        if (self.subviewIsInUndoArray(subview: subview!)) {
            var counter: Int = 0;
            for v in self.undoArray {
                if (v == subview) {
                    self.redoArray.append(v);
                    v.removeFromSuperview();
                    self.undoArray.remove(at: counter);
                    break;
                }
                counter += 1;
            }
        }
    }
    
    public func selectFigure(tapPoint: CGPoint) -> Bool {
        let subview = self.editorView.hitTest(tapPoint, with: nil);
        
        // CONDITIONS TO BE REVIEWED. DRY.
        if (self.subviewIsInUndoArray(subview: subview!)) {
            if (self.selectedFigure != nil) {
                self.selectedFigure.setIsNotSelected();
            }
            
            self.selectedFigure = subview as? UmlFigure;
            self.selectedFigure.setIsSelected();
            
            return true;
        } else {
            if (self.selectedFigure != nil) {
                self.selectedFigure.setIsNotSelected();
            }
            
            return false;
        }
    }
    
    public func unselectSelectedFigure() -> Void {
        if (self.selectedFigure != nil) {
            self.selectedFigure.setIsNotSelected();
        }
    }
    
    //    public func setFillColor(fillColor: UIColor) -> Void {
    //        self.currentlySelectedFigure.setFigureColor(figureColor: fillColor);
    //    }
    
    public func setSelectedFigureColor(color: UIColor) -> Void {
        self.selectedFigure.setFillColor(fillColor: color);
    }
    
    public func setSelectFigureBorderColor(color: UIColor) -> Void {
        self.selectedFigure.setBorderColor(borderColor: color);
    }
}
