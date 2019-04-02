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
    private var selectedFiguresDictionnary: [String : [DrawViewModel]] = [:]
    private var selectedOutlinesDictionnary: [String : [SelectionOutline]] = [:]
    
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
    public var touchEventState: TouchEventState = .NONE
    private var initialTouchPoint: CGPoint!
    private var previousTouchPoint: CGPoint!
    
    init() {
        self.editorView.delegate = self
        CollaborationHub.shared.delegate = self
        let rotation = UIRotationGestureRecognizer(target: self, action: #selector(self.rotatedView(_:)))
        self.editorView.addGestureRecognizer(rotation)
    }
    
    // Select made locally
    func select(figure: Figure) {
        self.selectedFigures.append(figure);
        self.selectionOutline.append(SelectionOutline(firstPoint: figure.frame.origin, lastPoint: CGPoint(x: figure.frame.maxX, y: figure.frame.maxY), associatedFigureID: figure.uuid));
        self.selectionOutline.last!.addSelectedFigureLayers();
        self.editorView.addSubview(self.selectionOutline.last!);
    }
    
    // Selection recieved by hub
    func select(figures: [Figure], username: String) {
        var selectionOutlines: [SelectionOutline] = []
        for figure in figures {
            let outline = SelectionOutline(
                firstPoint: figure.frame.origin,
                lastPoint: CGPoint(x: figure.frame.maxX, y: figure.frame.maxY),
                associatedFigureID: figure.uuid
            )
            outline.addUsernameSelecting(username: username)
            outline.addSelectedFigureLayers()
            selectionOutlines.append(outline)
            self.editorView.addSubview(outline);
        }
//        self.selectedFiguresDictionnary.updateValue(<#T##value: [DrawViewModel]##[DrawViewModel]#>, forKey: <#T##String#>)
        self.selectedOutlinesDictionnary.updateValue(selectionOutlines, forKey: username)
    }
    
    func selectLasso(touchPoint: CGPoint) {
        self.selectionLasso = SelectionLasso(size: self.editorView.frame.size, touchPoint: touchPoint);
        
        self.editorView.addSubview(self.selectionLasso);
    }
    
    func deselect() {
        if (self.selectionOutline.count > 0) {
            for outline in self.selectionOutline {
                outline.removeFromSuperview();
            }
            
            self.selectionOutline.removeAll();
        }
        CollaborationHub.shared.selectObjects(drawViewModels: [])
        self.deselectLasso();
        self.selectedFigures.removeAll();
    }
    
    func deselect(username: String) {
        self.selectedFiguresDictionnary.updateValue([], forKey: username)
        if (selectedOutlinesDictionnary[username] != nil) {
            for outline in self.selectedOutlinesDictionnary[username]! {
                outline.removeFromSuperview()
            }
        }
        self.selectedOutlinesDictionnary.updateValue([], forKey: username)
    }
    
    func deselectFigure(figure: Figure) {
        if (self.selectionOutline.count > 0) {
            let tmpOutlineIndex: Int = self.selectionOutline.firstIndex(where: { $0.associatedFigureID == figure.uuid })!;
            self.selectionOutline[tmpOutlineIndex].removeFromSuperview();
            self.selectionOutline.remove(at: tmpOutlineIndex);
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
////        let figure = FigureFactory.shared.getFigure(itemType: itemType, firstPoint: firstPoint, lastPoint: lastPoint)!
//        figure.delegate = self
//        self.editorView.addSubview(figure);
//        self.figures.append(figure)
//        self.undoArray.append(figure);
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
    
    public func deleteSelectedFigures() {
        if (self.selectedFigures.isEmpty) {
            return
        }
        
        for figure in self.selectedFigures {
            figure.removeFromSuperview()
            self.figures.removeAll{$0 == figure}
        }
        
        self.deselect()
        self.selectedFigures.removeAll()
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
        
    }
    
    func setSelectedFigureName(name: String) {
        for figure in self.selectedFigures {
            (figure as! UmlClassFigure).setClassName(name: name);
        }
        
    }
    
    func setSelectedComment(comment: String) {
        for figure in self.selectedFigures {
            (figure as! UmlCommentFigure).setComment(comment: comment);
        }
        
    }
    
    func setSelectedPhase(phaseName: String) {
        for figure in self.selectedFigures {
            (figure as! UmlPhaseFigure).setPhaseName(phaseName: phaseName);
        }
        
    }
    
    func setSelectedText(text: String) {
        for figure in self.selectedFigures {
            (figure as! UMLTextFigure).setText(text: text)
        }
        
    }
    
    func addClassMethod(name: String) {
        for figure in self.selectedFigures {
            (figure as! UmlClassFigure).addMethod(name: name)
        }
        
        self.updateSideToolBar()
    }
    
    func removeClassMethod(name: String, index: Int) {
        for figure in self.selectedFigures {
            (figure as! UmlClassFigure).removeMethod(name: name, index: index)
        }
        
        self.updateSideToolBar()
    }
    
    func addClassAttribute(name: String) {
        for figure in self.selectedFigures {
            (figure as! UmlClassFigure).addAttribute(name: name);
        }
        
        self.updateSideToolBar()
    }
    
    func removeClassAttribute(name: String, index: Int) {
        for figure in self.selectedFigures {
            (figure as! UmlClassFigure).removeAttribute(name: name, index: index);
        }
        
        self.updateSideToolBar()
    }
    
    func updateSideToolBar() {
        for controller in self.sideToolbatControllers {
            controller.update();
        }
    }
    
    func save() -> Void{
        CanvasService.SaveCanvas(name: "TestSaveCanva");
    }
    
    func rotate(orientation: RotateOrientation) {
        for figure in self.selectedFigures {
            let tempFigure: Figure = figure;
            figure.rotate(orientation: orientation);
            self.deselectFigure(figure: tempFigure);
            self.select(figure: figure);
        }
    }
    
    @objc private func rotatedView(_ sender: UIRotationGestureRecognizer) {
        if(!self.selectedFigures.isEmpty && sender.state == .changed) {
            let currentRotationAngle = Int(rad2deg(sender.rotation));
            
            if(currentRotationAngle % 45 == 0) {    // 45 degree pour faciliter la gesture
                for figure in self.selectedFigures {
                    let tempFigure: Figure = figure;
                    if(self.oldRotationAngle < currentRotationAngle) {
                        figure.rotate(orientation: .right);
                    } else {
                        figure.rotate(orientation: .left);
                    }
                    self.deselectFigure(figure: tempFigure);
                    self.select(figure: figure);
                }
            }
            oldRotationAngle = currentRotationAngle;
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
            } else if (action == "shape") {
//                self.deselect()
//                self.select(figure: figure!)
//                self.updateSideToolBar()
//                self.touchEventState = .TRANSLATE
                return
            } else if (action == "empty") {
                self.deselect()
//                self.touchEventState = .AREA_SELECT
//                self.selectLasso(touchPoint: point)
                return
            }
            break;
        case .REZISE:
            break
        case .TRANSLATE:
            break
        case .INSERT:
            // Get une figure dans la factory
            // ajouter la figure au canvas
            // export le viewModel de la figure
            // post le view model au HUB
            
            let figure = FigureFactory.shared.getFigure(type: self.currentFigureType, touchedPoint: point)!
            figure.delegate = self
            self.figures.append(figure)
            self.editorView.addSubview(figure)
            CollaborationHub.shared.postNewFigure(figures: [figure])
            break
        case .CONNECTION:
            break
        case .DELETE:
            self.deleteFigure(tapPoint: point);
            self.deselect();
            break
        case .AREA_SELECT:
            if (self.selectionLasso == nil) {
                self.deselect();
                self.selectLasso(touchPoint: point)
                return
            }
            self.selectionLasso.addNewTouchPoint(touchPoint: point);
            break
        case .NONE:
            break;
        }
    }
    
    func notifyTouchMoved(point: CGPoint, figure: Figure) {
        if (self.touchEventState == .SELECT || self.touchEventState == .TRANSLATE) {
            self.touchEventState = .TRANSLATE;
            let offset = CGPoint(x: point.x - self.previousTouchPoint.x, y: point.y - self.previousTouchPoint.y)
            for fig in self.selectedFigures {
                let tmpOutlineIndex: Int = self.selectionOutline.firstIndex(where: { $0.associatedFigureID == fig.uuid })!;
                (fig as! UmlFigure).translate(by: offset)
                self.selectionOutline[tmpOutlineIndex].translate(by: offset)
            }
            
            self.previousTouchPoint = point
            
            return
        } else if (self.touchEventState == .CONNECTION) {
            self.connectionPreview.removeFromSuperview()
            self.connectionPreview = ConnectionFigure(origin: self.initialTouchPoint, destination: point, itemType: .UniderectionalAssoication)
            self.editorView.addSubview(self.connectionPreview)
        }
    }
    
    func notifyTouchEnded(point: CGPoint, figure: Figure?) {
        if (self.touchEventState == .CONNECTION) {
            self.handleConnectionTouchEnded(point: point)
            return
        }
        
        if (self.touchEventState == .SELECT) {
            if (figure == nil) {
                return
            }
            self.deselect()
            for pair in self.selectedFiguresDictionnary {
                for selectedModel in pair.value {
                    if(selectedModel.Guid == figure?.uuid.uuidString) {
                        print("Already selected!")
                        return
                    }
                }
            }
            self.select(figure: figure!)
            self.updateSideToolBar()
            CollaborationHub.shared.selectObjects(drawViewModels: [(figure!.exportViewModel())!])
            return
        }
        
        if (self.touchEventState == .AREA_SELECT) {
            if (!self.selectionLasso.shapeIsClosed) {
                return
            }
            for figure in self.figures {
                if (self.selectionLasso.contains(figure: figure)) {
                    self.select(figure: figure);
                }
            }
            
            var drawViewModels: [DrawViewModel] = []
            for figure in selectedFigures {
                drawViewModels.append(figure.exportViewModel()!)
            }
            CollaborationHub.shared.selectObjects(drawViewModels: drawViewModels)

            self.deselectLasso();
            self.touchEventState = .AREA_SELECT;
            return
        }
        
        if (self.touchEventState == .TRANSLATE) {
            CollaborationHub.shared.postNewFigure(figures: [figure!])
            self.touchEventState = .SELECT;
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
    func updateSelection(itemMessage: ItemMessage) {
        if (itemMessage.Items.isEmpty) {
            self.deselect(username: itemMessage.Username)
            return
        }
        
        // TODO - William | Move to select
        self.selectedFiguresDictionnary.updateValue(itemMessage.Items, forKey: itemMessage.Username)
        var figuresToSelect: [Figure] = []
        for figure in self.figures {
            if (itemMessage.Items.contains(where: {$0.Guid == figure.uuid.uuidString})) {
                 figuresToSelect.append(figure)
            }
        }

        self.select(figures: figuresToSelect, username: itemMessage.Username)
    }
    
    func updateCanvas(itemMessage: ItemMessage) {
        print(itemMessage)
        for drawViewModel in itemMessage.Items {
            if (self.figures.contains(where: {$0.uuid.uuidString == drawViewModel.Guid})) {
                let oldFigure = self.figures.first(where: {$0.uuid.uuidString == drawViewModel.Guid})
                self.figures.removeAll{$0 == oldFigure}
                oldFigure?.removeFromSuperview()
                let newFigure = FigureFactory.shared.fromDrawViewModel(drawViewModel: drawViewModel)!
                newFigure.delegate = self
                self.figures.append(newFigure)
                self.editorView.addSubview(newFigure)
                self.deselect(username: itemMessage.Username)
                self.selectedFiguresDictionnary.updateValue(itemMessage.Items, forKey: itemMessage.Username)
                self.select(figures: [newFigure], username: itemMessage.Username)
                return
            }
            
            let figure = FigureFactory.shared.fromDrawViewModel(drawViewModel: drawViewModel)!
            figure.delegate = self
            self.figures.append(figure)
            self.editorView.addSubview(figure)
        }
        
//        sself.insertFigure(itemType: itemType, firstPoint: firstPoint, lastPoint: lastPoint)
    }
    
    func updateClear() {
        self.clear()
    }
}
