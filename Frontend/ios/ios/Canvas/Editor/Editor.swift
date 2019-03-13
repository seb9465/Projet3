//
//  Editor.swift
//  ios
//
//  Created by William Sevigny on 2019-03-11.
//  Copyright © 2019 LOG3000 equipe 12. All rights reserved.
//

import UIKit

class Editor: touchInputDelegate{
//    private var commands: [EditorCommand] = []
    private var undoArray: [Figure] = []
    private var redoArray: [Figure] = [];
    private var figures: [Figure] = [];
    
    public var editorView: EditorView = EditorView()
    public var selectedFigure: UmlFigure!;
    public var selectionOutline: SelectionOutline!;
    
    private var initialPoint: CGPoint!;
    private var finalPoint: CGPoint!;
    
//    public func insertFigure(origin: CGPoint) -> Void {
//        let figure = FigureFactory.shared.getFigure(type: ItemTypeEnum.RoundedRectangleStroke, origin: origin)!;
//        self.editorView.addSubview(figure);
//        self.undoArray.append(figure);
//    }
    
    public func insertFigure(firstPoint: CGPoint, lastPoint: CGPoint, type: ItemTypeEnum) {
//        let figure = FigureFactory.shared.getFigure(type: type, firstPoint: self.initialPoint, lastPoint: lastPoint)!
//        figure.delegate = self
        let figure = ConnectionFigure(origin: self.initialPoint, destination: lastPoint)
        self.editorView.addSubview(figure);
        self.figures.append(figure)
        self.undoArray.append(figure);
    }
    
    public func insertFigure(firstPoint: CGPoint, lastPoint: CGPoint) -> Void {
        let figure = FigureFactory.shared.getFigure(type: ItemTypeEnum.RoundedRectangleStroke, firstPoint: firstPoint, lastPoint: lastPoint)!
        figure.delegate = self
        self.editorView.addSubview(figure);
        self.figures.append(figure)
        self.undoArray.append(figure);
    }
    
    public func insertActor(firstPoint: CGPoint, lastPoint: CGPoint) -> Void {
        let figure = FigureFactory.shared.getFigure(type: ItemTypeEnum.Actor, firstPoint: firstPoint, lastPoint: lastPoint)!
        self.editorView.addSubview(figure);
        self.undoArray.append(figure);
    }
    
    public func selectFigure(tapPoint: CGPoint) -> Bool {
        guard let figure = self.editorView.hitTest(tapPoint, with: nil) as? UmlFigure else {
            if (self.selectionOutline != nil) {
                self.selectionOutline.removeFromSuperview()
            }
            self.selectedFigure = nil
            return false
        }
        
        if (!figure.isEqual(self.selectedFigure)) {
            if (self.selectionOutline != nil) {
                self.selectionOutline.removeFromSuperview()
            }
            self.selectedFigure = figure
            self.selectionOutline = SelectionOutline(firstPoint: figure.firstPoint, lastPoint: figure.lastPoint)
            self.selectionOutline.addSelectedFigureLayers(layer: self.editorView.layer)
            self.editorView.addSubview(self.selectionOutline)
        }
        
        return false
        
//        // CONDITIONS TO BE REVIEWED. DRY.
//        if (self.subviewIsInUndoArray(subview: subview!)) {
//            if (self.selectedFigure != nil) {
//                self.selectedFigure.setIsNotSelected();
//            }
//
//            self.selectedFigure = subview as? UmlFigure;
//            self.selectedFigure.setIsSelected();
//
//            return true;
//        } else {
//            if (self.selectedFigure != nil) {
//                self.selectedFigure.setIsNotSelected();
//            }
//
//            return false;
//        }
    }
    
    public func undo(view: UIView) -> Void {
        print(undoArray);
        if (undoArray.count > 0) {
            let figure: Figure = undoArray.popLast()!;
            self.redoArray.append(figure);
            figure.removeFromSuperview();
        }
    }
    
    public func redo(view: UIView) -> Void {
        if (redoArray.count > 0) {
            let figure: Figure = self.redoArray.last!;
            self.editorView.addSubview(figure);
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

    
    //    public func setFillColor(fillColor: UIColor) -> Void {
    //        self.currentlySelectedFigure.setFigureColor(figureColor: fillColor);
    //    }
    
    public func setSelectedFigureColor(color: UIColor) -> Void {
        self.selectedFigure.setFillColor(fillColor: color);
    }
    
    public func setSelectFigureBorderColor(color: UIColor) -> Void {
        self.selectedFigure.setBorderColor(borderColor: color);
    }
    
    func setPointTouched(point: CGPoint) {
        self.initialPoint = point
    }
}
