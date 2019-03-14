//
//  Editor.swift
//  ios
//
//  Created by William Sevigny on 2019-03-11.
//  Copyright © 2019 LOG3000 equipe 12. All rights reserved.
//

import UIKit

enum TouchHandleState {
    case SELECT
    case REZISE
    case TRANSLATE
    case CONNECTION
    case INSERT
//    case DELETE
}

class Editor{
//    private var commands: [EditorCommand] = []
    private var undoArray: [Figure] = []
    private var redoArray: [Figure] = [];
    private var figures: [Figure] = [];
    
    public var editorView: EditorView = EditorView()
    public var selectedFigure: Figure! = nil;
    public var selectionOutline: SelectionOutline!;
    
    private var initialTouchPoint: CGPoint!
    private var previousTouchPoint: CGPoint!
    
    private var initialPoint: CGPoint!;
    
    private var touchHandleState: TouchHandleState = .SELECT
    
    init() {
        self.editorView.delegate = self
    }
    
    func select(figure: Figure) {
        self.selectedFigure = figure
        self.selectionOutline = SelectionOutline(firstPoint: figure.firstPoint, lastPoint: figure.lastPoint)
        self.selectionOutline.addSelectedFigureLayers(layer: self.editorView.layer)
        self.editorView.addSubview(self.selectionOutline)
    }
    
    func deselect() {
        if (self.selectionOutline != nil) {
            self.selectionOutline.removeFromSuperview()
        }
        self.selectedFigure = nil
    }
    
    public func insertConnectionFigure(firstPoint: CGPoint, lastPoint: CGPoint, type: ItemTypeEnum) {
        let figure = ConnectionFigure(origin: self.initialTouchPoint, destination: lastPoint)
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
//        self.selectedFigure.setFillColor(fillColor: color);
    }
    
    public func setSelectFigureBorderColor(color: UIColor) -> Void {
//        self.selectedFigure.setBorderColor(borderColor: color);
    }
    
    func setPointTouched(point: CGPoint) {
        self.initialPoint = point
    }
    
    func snap(point: CGPoint) -> CGPoint{
        for subview in self.editorView.subviews {
            if (subview.frame.contains(point)) {
                return subview.center
            }
        }
        return point
    }
}

extension Editor : touchInputDelegate {
    func notifyTouchBegan(action: String, point: CGPoint, figure: Figure?) {
        switch (self.touchHandleState) {
        case .SELECT:
            self.initialTouchPoint = point
            self.previousTouchPoint = point
            
            if (action == "anchor") {
                self.touchHandleState = .CONNECTION
                return
            }
            
            if (action == "shape") {
                self.deselect()
                self.select(figure: figure!)
                self.touchHandleState = .TRANSLATE
                return
            }
            
            if (action == "empty") {
                self.deselect()
                self.touchHandleState = .SELECT
                return
            }
        case .REZISE:
            break
        case .TRANSLATE:
            break
        case .CONNECTION:
            break
        case .INSERT:
            break
        }
    }
    
    func notifyTouchMoved(point: CGPoint, figure: Figure) {
        if (self.touchHandleState == .TRANSLATE) {
            let offset = CGPoint(x: point.x - self.previousTouchPoint.x, y: point.y - self.previousTouchPoint.y)
            (figure as! UmlFigure).translate(by: offset)
            self.selectionOutline.translate(by: offset)
            self.previousTouchPoint = point
        }
    }
    
    func notifyTouchEnded(point: CGPoint) {
        if (self.touchHandleState == .CONNECTION) {
            let lastPoint = self.snap(point: point)
            self.insertConnectionFigure(firstPoint: self.initialTouchPoint, lastPoint: lastPoint, type: .Connection)
        }
        self.touchHandleState = .SELECT
    }
}
