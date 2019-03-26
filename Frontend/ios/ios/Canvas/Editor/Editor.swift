//
//  Editor.swift
//  ios
//
//  Created by William Sevigny on 2019-03-11.
//  Copyright © 2019 LOG3000 equipe 12. All rights reserved.
//

import UIKit

class Editor {
    public var editorView: EditorView = EditorView()
    //    public var sideToolbarController: SideToolbarController?
    public var sideToolbatControllers: [SideToolbarController] = []
    
    private var undoArray: [Figure] = []
    private var redoArray: [Figure] = [];
    private var figures: [Figure] = [];
    private var oldRotationAngle: Int = 0
    
    public var selectedFigure: Figure! = nil;
    public var selectionLasso: SelectionLasso! = nil;
    public var selectionOutline: SelectionOutline!
    public var connectionPreview: ConnectionFigure!
    public var connectionSourceFigure: Figure!
    
    public var currentFigureType: ItemTypeEnum = ItemTypeEnum.UMLClass;
    public var currentLineType: ItemTypeEnum = ItemTypeEnum.StraightLine
    
    // TouchInputDelegate properties
    public var touchEventState: TouchEventState = .SELECT
    private var initialTouchPoint: CGPoint!
    private var previousTouchPoint: CGPoint!
    
    init() {
        self.editorView.delegate = self
        CollaborationHub.shared.delegate = self
        let rotation = UIRotationGestureRecognizer(target: self, action: #selector(self.rotatedView(_:)))
        self.editorView.addGestureRecognizer(rotation)
    }
    
    func select(figure: Figure) {
        self.selectedFigure = figure
        self.selectionOutline = SelectionOutline(firstPoint: figure.frame.origin, lastPoint: CGPoint(x: figure.frame.maxX, y: figure.frame.maxY))
        self.selectionOutline.addSelectedFigureLayers()
        self.editorView.addSubview(self.selectionOutline)
    }
    
    func selectLasso() {
        self.selectionLasso = SelectionLasso();
        self.selectionLasso.addSelectedFigureLayers();
    }
    
    func selectArea(point: CGPoint) {
        let points: [CGPoint] = [self.initialTouchPoint, point]
        let selectionOrigin = CGPoint(x: points.map { $0.x }.min()!, y: points.map { $0.y }.min()!)
        let selectionDest = CGPoint(x: points.map { $0.x }.max()!, y: points.map { $0.y }.max()!)
        
        self.selectionOutline = SelectionOutline(firstPoint: selectionOrigin, lastPoint: selectionDest)
        self.selectionOutline.addSelectedFigureLayers()
        if (selectionOutline.frame.width < 10) {
            return
        }
        self.editorView.addSubview(self.selectionOutline)
    }
    
    func deselect() {
        if (self.selectionOutline != nil) {
            self.selectionOutline.removeFromSuperview()
        }
        if (self.selectionLasso != nil) {
            self.selectionLasso.removeSelectedFigureLayers();
            self.selectionLasso = nil;
        }
        self.selectedFigure = nil
    }
    
    public func insertConnectionFigure(firstPoint: CGPoint, lastPoint: CGPoint, itemType: ItemTypeEnum) {
        let figure = ConnectionFigure(origin: self.initialTouchPoint, destination: lastPoint, itemType: itemType)
        (self.connectionSourceFigure as! UmlFigure).addOutgoingConnection(connection: figure)
        self.editorView.addSubview(figure);
        self.figures.append(figure)
        self.undoArray.append(figure);
    }
    
    public func insertFigure(itemType: ItemTypeEnum, firstPoint: CGPoint, lastPoint: CGPoint) -> Void {
        let figure = FigureFactory.shared.getFigure(itemType: itemType, firstPoint: firstPoint, lastPoint: lastPoint)!
        figure.delegate = self
        self.editorView.addSubview(figure);
        self.figures.append(figure)
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
        self.deselect();
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
    
    func snap(point: CGPoint) -> CGPoint{
        for subview in self.editorView.subviews {
            if let figure = subview as? UmlFigure {
                if (figure.frame.contains(point)) {
                    return figure.getClosestAnchor(point: point)
                }
            }
        }
        return point
    }
}

extension Editor {
    public func changeTouchHandleState(to: TouchEventState) {
        self.touchEventState = to
    }
}

extension Editor: SideToolbarDelegate {
    func setSelectedFigureBorderColor(color: UIColor) {
        (self.selectedFigure as! UmlFigure).setBorderColor(borderColor: color)
    }
    
    func setSelectedFigureName(name: String) {
        (self.selectedFigure as! UmlClassFigure).setClassName(name: name)
    }
    
    func setSelectedComment(comment: String) {
        (self.selectedFigure as! UmlCommentFigure).setComment(comment: comment)
    }
    
    func addClassMethod(name: String) {
        (self.selectedFigure as! UmlClassFigure).addMethod(name: name)
        self.updateSideToolBar()
    }
    
    func removeClassMethod(name: String, index: Int) {
        (self.selectedFigure as! UmlClassFigure).removeMethod(name: name, index: index)
        self.updateSideToolBar()
    }
    
    func addClassAttribute(name: String) {
        (self.selectedFigure as! UmlClassFigure).addAttribute(name: name)
        self.updateSideToolBar()
    }
    
    func removeClassAttribute(name: String, index: Int) {
        (self.selectedFigure as! UmlClassFigure).removeAttribute(name: name, index: index)
        self.updateSideToolBar()
    }
    
    func updateSideToolBar() {
        for controller in self.sideToolbatControllers {
            controller.update()
        }
    }
    
    func save() -> Void{
        CanvasService.SaveCanvas(name: "TestSaveCanva")
    }
    
    func rotate(orientation: RotateOrientation) {
        let figureSelected = self.selectedFigure;
        self.selectedFigure.rotate(orientation: orientation)
        self.deselect()
        self.select(figure: figureSelected!)
    }
    
    @objc private func rotatedView(_ sender: UIRotationGestureRecognizer) {
        if(self.selectedFigure != nil && sender.state == .changed) {
            let figureSelected = self.selectedFigure;
            let currentRotationAngle = Int(rad2deg(sender.rotation))
            // 45 degree pour faciliter la gesture
            if(currentRotationAngle % 45 == 0) {
                // pour le sense de la rotation
                if(self.oldRotationAngle < currentRotationAngle) {
                    self.selectedFigure.rotate(orientation: .right)
                } else {
                    self.selectedFigure.rotate(orientation: .left)
                }
                self.deselect()
                self.select(figure: figureSelected!)
            }
            oldRotationAngle = currentRotationAngle
            
        }
        print("rotation gesture is detected")
    }
    
    func rad2deg(_ number: CGFloat) -> CGFloat {
        return number * 180 / .pi
    }
}

extension Editor : TouchInputDelegate {
    func notifyTouchBegan(action: String, point: CGPoint, figure: Figure?) {
        switch (self.touchEventState) {
        case .SELECT:
            self.initialTouchPoint = point
            self.previousTouchPoint = point
            
            if (action == "anchor") {
                self.connectionSourceFigure = figure
                self.touchEventState = .CONNECTION
                self.connectionPreview = ConnectionFigure(origin: self.initialTouchPoint, destination: self.initialTouchPoint, itemType: .StraightLine)
                self.editorView.addSubview(connectionPreview)
                return
            }
            
            if (action == "shape") {
                self.deselect()
                self.select(figure: figure!)
                self.updateSideToolBar()
                self.touchEventState = .TRANSLATE
                return
            }
            
            if (action == "empty") {
                self.deselect()
                self.touchEventState = .AREA_SELECT
                return
            }
            
        case .REZISE:
            break
        case .TRANSLATE:
            break
        case .INSERT:
            CollaborationHub.shared.postNewFigure(origin: point, itemType: currentFigureType)
            break
        case .CONNECTION:
            break
        case .DELETE:
            self.deleteFigure(tapPoint: point);
            self.deselect();
            break
        case .AREA_SELECT:
            break
            
        }
    }
    
    func notifyTouchMoved(point: CGPoint, figure: Figure) {
        if (self.touchEventState == .TRANSLATE) {
            let offset = CGPoint(x: point.x - self.previousTouchPoint.x, y: point.y - self.previousTouchPoint.y)
            (figure as! UmlFigure).translate(by: offset)
            self.selectionOutline.translate(by: offset)
            self.previousTouchPoint = point
            
            return
        }
        
        if (self.touchEventState == .CONNECTION) {
            self.connectionPreview.removeFromSuperview()
            self.connectionPreview = ConnectionFigure(origin: self.initialTouchPoint, destination: point, itemType: .StraightLine)
            self.editorView.addSubview(self.connectionPreview)
        }
        
        if (self.touchEventState == .AREA_SELECT) {
            // Resize the selection shape
        }
    }
    
    func notifyTouchEnded(point: CGPoint) {
        if (self.touchEventState == .CONNECTION) {
            self.connectionPreview.removeFromSuperview()
            let lastPoint = self.snap(point: point)
            let connection = self.insertConnectionFigure(
                firstPoint: self.initialTouchPoint,
                lastPoint: lastPoint,
                itemType: currentFigureType
            )
            self.touchEventState = .SELECT
            return
        }
        
        if (self.touchEventState == .AREA_SELECT) {
//            self.selectArea(point: point)
            self.selectLasso();
            self.touchEventState = .SELECT
            return
        }
        
        if (self.touchEventState == .INSERT) {
            return
        }
        
        self.touchEventState = .SELECT
    }
}

extension Editor: CollaborationHubDelegate {
    func updateCanvas(itemType: ItemTypeEnum, firstPoint: CGPoint, lastPoint: CGPoint) {
        self.insertFigure(itemType: itemType, firstPoint: firstPoint, lastPoint: lastPoint)
    }
    
    func updateClear() {
        self.clear()
    }
}
