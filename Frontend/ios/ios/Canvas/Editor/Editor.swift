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
    
    public var selectedFigures: [Figure] = [];
    public var selectionLasso: SelectionLasso! = nil;
    public var selectionOutline: [SelectionOutline] = [];
    
    // Connection Creation properties
    public var connectionPreview: ConnectionFigure!
    public var sourceFigure: UmlFigure!
    public var currentFigureType: ItemTypeEnum = ItemTypeEnum.UmlClass;
    
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
        self.selectedFigures.append(figure);
        self.selectionOutline.append(SelectionOutline(firstPoint: figure.frame.origin, lastPoint: CGPoint(x: figure.frame.maxX, y: figure.frame.maxY), associatedFigureID: figure.figureID));
        self.selectionOutline.last!.addSelectedFigureLayers();
        self.editorView.addSubview(self.selectionOutline.last!);
    }
    
    func selectLasso(touchPoint: CGPoint) {
        self.selectionLasso = SelectionLasso(size: self.editorView.frame.size, touchPoint: touchPoint);
        
        self.editorView.addSubview(self.selectionLasso);
    }
    
//    func selectArea(point: CGPoint) {
//        let points: [CGPoint] = [self.initialTouchPoint, point]
//        let selectionOrigin = CGPoint(x: points.map { $0.x }.min()!, y: points.map { $0.y }.min()!)
//        let selectionDest = CGPoint(x: points.map { $0.x }.max()!, y: points.map { $0.y }.max()!)
//        
//        self.selectionOutline.append(SelectionOutline(firstPoint: selectionOrigin, lastPoint: selectionDest, associatedFigureID: figure.figureID));
//        self.selectionOutline.last!.addSelectedFigureLayers()
//        if (selectionOutline.last!.frame.width < 10) {
//            return
//        }
//        self.editorView.addSubview(self.selectionOutline.last!)
//    }
    
    func deselect() {
        if (self.selectionOutline.count > 0) {
            for outline in self.selectionOutline {
                outline.removeFromSuperview();
            }
            self.selectionOutline.removeAll();
//            self.selectionOutline.removeFromSuperview()
        }
        self.deselectLasso();
        self.selectedFigures.removeAll();
    }
    
    func deselectFigure(figure: Figure) {
        if (self.selectionOutline.count > 0) {
            let tmpOutlineIndex: Int = self.selectionOutline.firstIndex(where: { $0.firstPoint == figure.firstPoint && $0.lastPoint == figure.lastPoint })!;
            let tempOutline: SelectionOutline = self.selectionOutline[tmpOutlineIndex];
            tempOutline.removeFromSuperview();
//            self.selectionOutline.removeFromSuperview()
        }
        self.deselectLasso();
        self.selectedFigures.remove(at: self.selectedFigures.firstIndex(of: figure)!);
    }
    
    func deselectLasso() -> Void {
        if (self.selectionLasso != nil) {
            self.selectionLasso.removeFromSuperview();
            self.selectionLasso = nil;
        }
    }
    
    public func insertConnectionFigure(firstPoint: CGPoint, lastPoint: CGPoint, itemType: ItemTypeEnum) -> ConnectionFigure {
        let figure = ConnectionFigure(origin: self.initialTouchPoint, destination: lastPoint, itemType: itemType)
        self.editorView.addSubview(figure);
        self.figures.append(figure)
        self.undoArray.append(figure);
        return figure
    }
    
    public func insertFigure(itemType: ItemTypeEnum, firstPoint: CGPoint, lastPoint: CGPoint) -> Void {
        let figure = FigureFactory.shared.getFigure(itemType: itemType, firstPoint: firstPoint, lastPoint: lastPoint)!
        figure.delegate = self
        self.editorView.addSubview(figure);
        self.figures.append(figure)
        self.undoArray.append(figure);
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
    
    public func subviewIsInUndoArray(subview: UIView) -> Bool {
        for a in self.undoArray {
            if (a == subview) {
                return true;
            }
        }
        
        return false;
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
    
    func snap(point: CGPoint) -> CGPoint{
        for subview in self.editorView.subviews {
            if let figure = subview as? UmlFigure {
                if (figure.frame.contains(point)) {
                    return figure.getClosestAnchorPoint(point: point)
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
        for figure in self.selectedFigures {
            (figure as! UmlFigure).setBorderColor(borderColor: color);
        }
//        (self.selectedFigure as! UmlFigure).setBorderColor(borderColor: color)
    }
    
    func setSelectedFigureName(name: String) {
        for figure in self.selectedFigures {
            (figure as! UmlClassFigure).setClassName(name: name);
        }
//        (self.selectedFigure as! UmlClassFigure).setClassName(name: name)
    }
    
    func setSelectedComment(comment: String) {
        for figure in self.selectedFigures {
            (figure as! UmlCommentFigure).setComment(comment: comment);
        }
//        (self.selectedFigure as! UmlCommentFigure).setComment(comment: comment)
    }
    
    func setSelectedPhase(phaseName: String) {
        for figure in self.selectedFigures {
            (figure as! UmlPhaseFigure).setPhaseName(phaseName: phaseName);
        }
//        (self.selectedFigure as! UmlPhaseFigure).setPhaseName(phaseName: phaseName)
    }
    
    func setSelectedText(text: String) {
        for figure in self.selectedFigures {
            (figure as! UMLTextFigure).setText(text: text)
        }
//        (self.selectedFigure as! UMLTextFigure).setText(text: text)
    }
    
    func addClassMethod(name: String) {
        for figure in self.selectedFigures {
            (figure as! UmlClassFigure).addMethod(name: name)
        }
//        (self.selectedFigure as! UmlClassFigure).addMethod(name: name)
        self.updateSideToolBar()
    }
    
    func removeClassMethod(name: String, index: Int) {
        for figure in self.selectedFigures {
            (figure as! UmlClassFigure).removeMethod(name: name, index: index)
        }
//        (self.selectedFigure as! UmlClassFigure).removeMethod(name: name, index: index)
        self.updateSideToolBar()
    }
    
    func addClassAttribute(name: String) {
        for figure in self.selectedFigures {
            (figure as! UmlClassFigure).addAttribute(name: name);
        }
//        (self.selectedFigure as! UmlClassFigure).addAttribute(name: name)
        self.updateSideToolBar()
    }
    
    func removeClassAttribute(name: String, index: Int) {
        for figure in self.selectedFigures {
            (figure as! UmlClassFigure).removeAttribute(name: name, index: index);
        }
//        (self.selectedFigure as! UmlClassFigure).removeAttribute(name: name, index: index)
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
        for figure in self.selectedFigures {
            let tempFigure: Figure = figure;
            figure.rotate(orientation: orientation)
            self.deselectFigure(figure: tempFigure);
            self.select(figure: figure);
        }
//        let figureSelected = self.selectedFigure;
//        self.selectedFigure.rotate(orientation: orientation)
//        self.deselect()
        
//        self.select(figure: figureSelected!)
    }
    
    @objc private func rotatedView(_ sender: UIRotationGestureRecognizer) {
        if(!self.selectedFigures.isEmpty && sender.state == .changed) {
//            let figureSelected = self.selectedFigure;
            let currentRotationAngle = Int(rad2deg(sender.rotation))
            // 45 degree pour faciliter la gesture
            if(currentRotationAngle % 45 == 0) {
                // pour le sense de la rotation
                for figure in self.selectedFigures {
                    let tempFigure: Figure = figure;
                    if(self.oldRotationAngle < currentRotationAngle) {
                        figure.rotate(orientation: .right)
                    } else {
                        figure.rotate(orientation: .left)
                    }
                    self.deselectFigure(figure: tempFigure)
                    self.select(figure: figure)
                }
//                if(self.oldRotationAngle < currentRotationAngle) {
//                    self.selectedFigure.rotate(orientation: .right)
//                } else {
//                    self.selectedFigure.rotate(orientation: .left)
//                }
//                self.deselect()
//                self.select(figure: figureSelected!)
            }
            oldRotationAngle = currentRotationAngle
            
        }
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
                self.sourceFigure = (figure as! UmlFigure)
                self.connectionPreview = ConnectionFigure(origin: self.initialTouchPoint, destination: self.initialTouchPoint, itemType: .UniderectionalAssoication)
                self.editorView.addSubview(connectionPreview)
                self.touchEventState = .CONNECTION
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
                self.selectLasso(touchPoint: point);
                return
            }
            break;
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
            self.selectionLasso.addNewTouchPoint(touchPoint: point);
            break
        }
    }
    
    func notifyTouchMoved(point: CGPoint, figure: Figure) {
        if (self.touchEventState == .TRANSLATE) {
            let tmpOutlineIndex: Int = self.selectionOutline.firstIndex(where: { $0.associatedFigureID == figure.figureID })!;
            
            let offset = CGPoint(x: point.x - self.previousTouchPoint.x, y: point.y - self.previousTouchPoint.y)
            (figure as! UmlFigure).translate(by: offset)
            self.selectionOutline[tmpOutlineIndex].translate(by: offset)
//            self.selectionOutline.translate(by: offset)
            self.previousTouchPoint = point
            
            return
        }
        
        if (self.touchEventState == .CONNECTION) {
            self.connectionPreview.removeFromSuperview()
            self.connectionPreview = ConnectionFigure(origin: self.initialTouchPoint, destination: point, itemType: .UniderectionalAssoication)
            self.editorView.addSubview(self.connectionPreview)
        }
        
//        if (self.touchEventState == .AREA_SELECT) {
//            // Resize the selection shape
//        }
    }
    
    func notifyTouchEnded(point: CGPoint) {
        if (self.touchEventState == .CONNECTION) {
            self.connectionPreview.removeFromSuperview()
            let lastPoint = self.snap(point: point)
            let connection = self.insertConnectionFigure(
                firstPoint: self.initialTouchPoint,
                lastPoint: lastPoint,
                itemType: currentFigureType
            );
            self.touchEventState = .SELECT;
        } else if (self.touchEventState == .AREA_SELECT) {
//            self.selectArea(point: point)
            // TODO: Retourne a .SELECT seulement si la selection au lasso est completer
//            self.touchEventState = .SELECT
            if (self.selectionLasso.shapeIsClosed) {
                for figure in self.figures {
                    if (self.selectionLasso.contains(figure: figure)) {
                        self.select(figure: figure);
                    }
                }
                self.deselectLasso();
                self.touchEventState = .SELECT;
            }
            return
        } else if (self.touchEventState == .INSERT) {
            return
        }
    }
    
    func handleConnectionTouchEnded(point: CGPoint) {
        self.connectionPreview.removeFromSuperview()
        guard let destinationFigure: UmlFigure = self.getFigureContaining(point: point) else {
            print("Insert cancelled: No destination figure found.")
            self.touchEventState = .SELECT
            return
        }
        
        if (destinationFigure.isEqual(self.sourceFigure)) {
            print("Insert cancelled: Cannot connect figure to itself.")
            self.touchEventState = .SELECT
            return
        }
        
        let connection: ConnectionFigure = self.insertConnectionFigure(
            firstPoint: self.initialTouchPoint,
            lastPoint: destinationFigure.getClosestAnchorPoint(point: point),
            itemType: currentFigureType
        )
        
        let sourceAnchor: String = self.sourceFigure.getClosestAnchorPointName(point: self.initialTouchPoint)
        let destinationAnchor: String = destinationFigure.getClosestAnchorPointName(point: point)
        self.sourceFigure.addOutgoingConnection(connection: connection, anchor: sourceAnchor)
        destinationFigure.addIncomingConnection(connection: connection, anchor: destinationAnchor)
        self.touchEventState = .SELECT
        return
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
