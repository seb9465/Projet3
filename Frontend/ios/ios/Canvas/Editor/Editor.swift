//
//  Editor.swift
//  ios
//
//  Created by William Sevigny on 2019-03-11.
//  Copyright © 2019 LOG3000 equipe 12. All rights reserved.
//

import UIKit

class Editor {
    var editorView: EditorView = EditorView()
    var sideToolbatControllers: [SideToolbarController] = []
    var selectedFiguresDictionnary: [String : [DrawViewModel]] = [:]
    var selectedOutlinesDictionnary: [String : [SelectionOutline]] = [:]
    
    var undoArray: [Figure] = []
    var redoArray: [Figure] = [];
    var figures: [Figure] = [];
    var oldRotationAngle: Int = 0
    
    var selectedFigures: [Figure] = [];
    var selectionLasso: SelectionLasso! = nil;
    
    // Selections locales
//    var localSelections: [Figure : SelectionOutline] = [:]
    var selectionOutlines: [SelectionOutline] = [];
    
    // Connection Creation properties
    var connectionPreview: Figure!
    var sourceFigure: UmlFigure!
    var currentFigureType: ItemTypeEnum = ItemTypeEnum.UmlClass;
    
    // TouchInputDelegate properties
    var touchEventState: TouchEventState = .NONE
    var initialTouchPoint: CGPoint!
    var previousTouchPoint: CGPoint!
    
    // Pinch gesture properties
    var initialPinchDistance: CGPoint = CGPoint.zero
    
    var clipboard: [Figure] = []
    
    init() {
        self.editorView.delegate = self
        let rotation = UIRotationGestureRecognizer(target: self, action: #selector(self.rotatedView(_:)))
        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(self.resizeFigure(_:)))
        self.editorView.addGestureRecognizer(rotation)
        self.editorView.addGestureRecognizer(pinch)
   //     self.editorView.backgroundColor = UIColor.red
   //     self.editorView.clipsToBounds = true
    }
    
    func resize(width: CGFloat, heigth: CGFloat) {
        print("resizing")
        let origin: CGPoint = CGPoint(x: 250, y: 70)
        let size = CGSize(width: width, height: heigth)
        let newFrame: CGRect = CGRect(origin: origin, size: size)
        self.editorView.frame = newFrame
        self.editorView.updateCanvasAnchor()
        self.editorView.setNeedsDisplay()
    }
    
    // Select made locally
    func select(figure: Figure) {
        let selectionOutline: SelectionOutline = SelectionOutline(frame: figure.getSelectionFrame(), associatedFigureID: figure.uuid, delegate: self)
        self.editorView.addSubview(selectionOutline)
        self.selectedFigures.append(figure)
        self.selectionOutlines.append(selectionOutline)
    }
    
    // Selection recieved by hub
    func select(drawViewModels: [DrawViewModel], username: String) {
        self.selectedFiguresDictionnary.updateValue(drawViewModels, forKey: username)
        var figuresToSelect: [Figure] = []
        for figure in self.figures {
            if (drawViewModels.contains(where: {$0.Guid == figure.uuid.uuidString.lowercased()})) {
                figuresToSelect.append(figure)
            }
        }
        
        var selectionOutlines: [SelectionOutline] = []
        for figure in figuresToSelect {
            let frame = figure.getSelectionFrame()
            let outline = SelectionOutline(
                firstPoint: frame.origin,
                lastPoint: CGPoint(x: frame.maxX, y: frame.maxY),
                associatedFigureID: figure.uuid,
                delegate: self
            )
            outline.addUsernameSelecting(username: username)
            selectionOutlines.append(outline)
            self.editorView.addSubview(outline);
        }
        self.selectedOutlinesDictionnary.updateValue(selectionOutlines, forKey: username)
        print("SELECT hihi", self.selectedOutlinesDictionnary)
    }
    
    func selectLasso(touchPoint: CGPoint) {
        self.selectionLasso = SelectionLasso(size: self.editorView.frame.size, touchPoint: touchPoint);
        self.editorView.addSubview(self.selectionLasso);
    }
    
    func deselect() {
        if (self.selectionOutlines.count > 0) {
            for outline in self.selectionOutlines {
                outline.removeFromSuperview();
            }
            
            self.selectionOutlines.removeAll();
        }
        CollaborationHub.shared!.selectObjects(drawViewModels: [])
        self.deselectLasso();
        self.selectedFigures.removeAll();
    }
    
    func deselect(username: String) {
        self.selectedFiguresDictionnary.updateValue([], forKey: username)
        if (selectedOutlinesDictionnary[username] != nil) {
            for outline in self.selectedOutlinesDictionnary[username]! {
                print("SELECTION REMOVED HIHI")
                outline.removeFromSuperview()
            }
        }
        self.selectedOutlinesDictionnary.updateValue([], forKey: username)
    }
    
    func deselectFigure(figure: Figure) {
        if (self.selectionOutlines.count > 0) {
            let tmpOutlineIndex: Int = self.selectionOutlines.firstIndex(where: { $0.associatedFigureID == figure.uuid })!;
            self.selectionOutlines[tmpOutlineIndex].removeFromSuperview();
            self.selectionOutlines.remove(at: tmpOutlineIndex);
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
    
    func copy() {
        self.clipboard = self.selectedFigures
    }
    
    func paste() {
        self.copy()
        for figure in self.clipboard {
            var viewModel = figure.exportViewModel()!
            viewModel.Guid = UUID().uuidString
            viewModel.StylusPoints![0].X = viewModel.StylusPoints![0].X + 10
            viewModel.StylusPoints![0].Y = viewModel.StylusPoints![0].Y + 10
            viewModel.StylusPoints![1].X = viewModel.StylusPoints![1].X + 10
            viewModel.StylusPoints![1].Y = viewModel.StylusPoints![1].Y + 10
            self.select(figure: figure)
            self.insertFigure(drawViewModel: viewModel)
        }
        self.deselect()
        CollaborationHub.shared!.postNewFigure(figures: self.clipboard)
        CanvasService.saveOnNewFigure(figures: self.figures, editor: self)
    }
    
    func cut() {
        self.copy()
        self.deleteSelectedFigures()
    }
    
    public func insertFigure(drawViewModel: DrawViewModel) -> Figure {
        let figure = FigureFactory.shared.fromDrawViewModel(drawViewModel: drawViewModel)!
        figure.delegate = self
        self.figures.append(figure)
        self.editorView.addSubview(figure)
        return figure
    }
    
    public func insertFigure(position: CGPoint) -> Void {
        let figure = FigureFactory.shared.getFigure(type: self.currentFigureType, touchedPoint: position)!
        figure.delegate = self
        self.figures.append(figure)
        self.editorView.addSubview(figure)
        CollaborationHub.shared!.postNewFigure(figures: [figure])
        CanvasService.saveOnNewFigure(figures: self.figures, editor: self)
    }
    
    public func insertConnectionFigure(firstPoint: CGPoint, lastPoint: CGPoint, itemType: ItemTypeEnum) -> Figure {
        let figure = FigureFactory.shared.getFigure(
            type: itemType,
            source: firstPoint,
            destination: lastPoint
        )
        figure!.delegate = self
        self.editorView.addSubview(figure!);
        self.figures.append(figure!)
        self.undoArray.append(figure!);
        return figure!
    }
    
    public func deleteSelectedFigures() {
        if (self.selectedFigures.isEmpty) {
            return
        }
        var viewModelsToDelete: [DrawViewModel] = []
        for figure in self.selectedFigures {
            figure.removeFromSuperview()
            viewModelsToDelete.append(figure.exportViewModel()!)
            self.figures.removeAll{$0 == figure}
        }
        self.deselect()
        self.selectedFigures.removeAll()
        CollaborationHub.shared?.CutObjects(drawViewModels: viewModelsToDelete)
        CanvasService.saveOnNewFigure(figures: self.figures, editor: self)
    }
    
    public func deleteSelectedFigures(username: String) {
        let figuresToDelete = self.selectedFiguresDictionnary[username]
        self.selectedFiguresDictionnary[username] = []
        /*
        var figureToDelete: [Figure] = []
        for figure in self.figures {
            if((figuresToDelete?.contains(where: {$0.Guid == figure.uuid.uuidString}))!) {
                figure.removeFromSuperview()
                figureToDelete.append(figure)
            }
        }
        for figure in figureToDelete {
            self.figures.removeAll{$0 == figure}
        }
         */
        self.deselect(username: username)
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
        print("clearing")
        for view in self.editorView.subviews {
            view.removeFromSuperview()
        }
        self.selectedFigures.removeAll()
        self.editorView.setNeedsDisplay()
        self.selectionOutlines.removeAll()
        self.figures.removeAll()
        self.undoArray.removeAll();
        self.redoArray.removeAll();
        self.deselect();
        CanvasService.saveOnNewFigure(figures: self.figures, editor: self)
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
}

extension Editor {
    public func changeTouchHandleState(to: TouchEventState) {
        self.touchEventState = to
    }
}

extension Editor: SideToolbarDelegate {
    func setSelectedFigureBorderColor(color: UIColor) {
        for figure in self.selectedFigures {
            figure.setBorderColor(borderColor: color);
        }
        CollaborationHub.shared!.postNewFigure(figures: self.selectedFigures)
        CanvasService.saveOnNewFigure(figures: self.figures, editor: self)
    }
    
    func setSelectedFigureFillColor(color: UIColor) {
        for figure in self.selectedFigures {
            figure.setFillColor(fillColor: color)
        }
        CollaborationHub.shared!.postNewFigure(figures: self.selectedFigures)
        CanvasService.saveOnNewFigure(figures: self.figures, editor: self)
    }
    
    func setSelectedFigureBorderStyle(isDashed: Bool) {
        for figure in self.selectedFigures {
            figure.setIsBorderDashed(isDashed: isDashed)
        }
        CollaborationHub.shared!.postNewFigure(figures: self.selectedFigures)
        CanvasService.saveOnNewFigure(figures: self.figures, editor: self)
    }
    
    func setSelectedFigureLineWidth(width: CGFloat) {
        for figure in self.selectedFigures {
            figure.setLineWidth(width: width)
        }
        CollaborationHub.shared!.postNewFigure(figures: self.selectedFigures)
        CanvasService.saveOnNewFigure(figures: self.figures, editor: self)
    }
    
    func setSelectedFigureName(name: String) {
        for figure in self.selectedFigures {
            figure.setFigureName(name: name)
        }
        CollaborationHub.shared!.postNewFigure(figures: self.selectedFigures)
    }

    func setSelectedFigureNameDidEnd() {
        CollaborationHub.shared!.postNewFigure(figures: self.selectedFigures)
        CanvasService.saveOnNewFigure(figures: self.figures, editor: self)
    }
    
    func addClassMethod(name: String) {
        for figure in self.selectedFigures {
            (figure as! UmlClassFigure).addMethod(name: name)
        }
        
        self.updateSideToolBar()
        CollaborationHub.shared!.postNewFigure(figures: self.selectedFigures)
        CanvasService.saveOnNewFigure(figures: self.figures, editor: self)
    }
    
    func removeClassMethod(name: String, index: Int) {
        for figure in self.selectedFigures {
            (figure as! UmlClassFigure).removeMethod(name: name, index: index)
        }
        
        self.updateSideToolBar()
        CollaborationHub.shared!.postNewFigure(figures: self.selectedFigures)
        CanvasService.saveOnNewFigure(figures: self.figures, editor: self)
    }
    
    func addClassAttribute(name: String) {
        for figure in self.selectedFigures {
            (figure as! UmlClassFigure).addAttribute(name: name);
        }
        
        self.updateSideToolBar()
        CollaborationHub.shared!.postNewFigure(figures: self.selectedFigures)
        CanvasService.saveOnNewFigure(figures: self.figures, editor: self)
    }
    
    func removeClassAttribute(name: String, index: Int) {
        for figure in self.selectedFigures {
            (figure as! UmlClassFigure).removeAttribute(name: name, index: index);
        }
        
        self.updateSideToolBar()
        CollaborationHub.shared!.postNewFigure(figures: self.selectedFigures)
        CanvasService.saveOnNewFigure(figures: self.figures, editor: self)
    }
    
    func updateSideToolBar() {
        for controller in self.sideToolbatControllers {
            controller.update();
        }
    }
    
    func export() -> UIImage{
        UIGraphicsBeginImageContextWithOptions(self.editorView.bounds.size, false, 0.0);
        self.editorView.drawHierarchy(in: self.editorView.bounds, afterScreenUpdates: true);
        let image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return image!
    }
    
    func rotate(orientation: RotateOrientation) {
        for figure in self.selectedFigures {
            let tempFigure: Figure = figure;
            figure.rotate(orientation: orientation);
            self.deselectFigure(figure: tempFigure);
            self.select(figure: figure);
        }
        CollaborationHub.shared!.postNewFigure(figures: self.selectedFigures)
    }
}

extension Editor: CollaborationHubDelegate {
    func updateSelection(itemMessage: ItemMessage) {
        if (itemMessage.Items.isEmpty) {
            self.deselect(username: itemMessage.Username)
            return
        }
        self.deselect(username: itemMessage.Username)
        self.select(drawViewModels: itemMessage.Items, username: itemMessage.Username)
    }
    
    func updateCanvas(itemMessage: ItemMessage) {
//        print(itemMessage.Items)
        for drawViewModel in itemMessage.Items {
            if (self.figures.contains(where: {$0.uuid.uuidString.lowercased() == drawViewModel.Guid})) {
                self.overriteFigure(figureId: drawViewModel.Guid!, newDrawViewModel: drawViewModel, username: itemMessage.Username)
                self.deselect(username: itemMessage.Username)
                self.select(drawViewModels: itemMessage.Items, username: itemMessage.Username)
                print("AFTER DRAW", self.selectedOutlinesDictionnary)
                return
            }
                self.insertNewDrawViewModel(drawViewModel: drawViewModel)
        }
    }
    
    func delete(username: String) {
        self.deleteSelectedFigures(username: username)
    }

    public func insertNewDrawViewModel(drawViewModel: DrawViewModel) {
        let figure = self.insertFigure(drawViewModel: drawViewModel)
        if (drawViewModel.ItemType?.description == "Connection") {
            print("Connecting to other figures")
            self.connectConnectionToFigures(drawViewModel: drawViewModel, connection: (figure as! ConnectionFigure))
        }
    }
    
    public func loadCanvas(drawViewModels: [DrawViewModel]) {
        let drawViewModelsSorted = drawViewModels.sorted(by: { $0.ItemType!.rawValue < $1.ItemType!.rawValue })
        for drawViewModel in drawViewModelsSorted  {
            insertNewDrawViewModel(drawViewModel: drawViewModel)
        }
    }
    
    func updateClear() {
        self.clear()
    }
}

// Logige de Select, Update de collaboration
extension Editor {
    
    func isFigureSelected(figure: Figure) -> Bool {
        for pair in self.selectedFiguresDictionnary {
            for selectedModel in pair.value {
                if(selectedModel.Guid == figure.uuid.uuidString.lowercased()) {
                    print("Selection cancelled: Figure already selected by another user")
                    return true
                }
            }
        }
        return false
    }
    
    func overriteFigure(figureId: String, newDrawViewModel: DrawViewModel, username: String) {
        let oldFigure = self.figures.first(where: {$0.uuid.uuidString.lowercased() == figureId})
        
        self.figures.removeAll{$0 == oldFigure}
        oldFigure?.removeFromSuperview()
        let newFigure = FigureFactory.shared.fromDrawViewModel(drawViewModel: newDrawViewModel)!
        newFigure.delegate = self
        self.figures.append(newFigure)
        self.editorView.addSubview(newFigure)
        
        if (oldFigure is ConnectionFigure && newFigure is ConnectionFigure) {
            self.updateConnectionBindings(oldConnection: oldFigure as! ConnectionFigure, newConnection: newFigure as! ConnectionFigure)
        }
        
        if (oldFigure is UmlFigure && newFigure is UmlFigure) {
            print("Updating received Figure connections")
            (newFigure as! UmlFigure).outgoingConnections = (oldFigure as! UmlFigure).outgoingConnections
            (newFigure as! UmlFigure).incomingConnections = (oldFigure as! UmlFigure).incomingConnections
            (newFigure as! UmlFigure).updateConnections()
        }    }
    
    func connectConnectionToFigures(drawViewModel: DrawViewModel, connection: ConnectionFigure) {
        for figure in self.figures {
            if (figure is UmlFigure) {
                for pair in (figure as! UmlFigure).anchorPoints!.anchorPointsSnapEdges {
                    // Create a detection area around connection figure extremities
                    let detectionDiameter: CGFloat = 10
                    let globalPoint: CGPoint = figure.convert(pair.value, to: self.editorView)
                    let areaRect: CGRect = CGRect(
                        x: globalPoint.x - detectionDiameter/2,
                        y: globalPoint.y - detectionDiameter/2,
                        width: detectionDiameter,
                        height: detectionDiameter
                    )
                    
                    if (areaRect.contains(drawViewModel.StylusPoints![0].getCGPoint())) {
                        (figure as! UmlFigure).addOutgoingConnection(connection: connection, anchor: pair.key)
                    }
 
                    if (areaRect.contains(drawViewModel.StylusPoints![1].getCGPoint())) {
                        (figure as! UmlFigure).addIncomingConnection(connection: connection, anchor: pair.key)
                    }
                }
            }
        }
    }
    
    func updateConnectionBindings(oldConnection: ConnectionFigure, newConnection: ConnectionFigure) {
        for figure in self.figures {
            if (figure is UmlFigure) {
                // Replace incoming connections
                if let incomingAnchor: String = (figure as! UmlFigure).incomingConnections[oldConnection] {
                (figure as! UmlFigure).incomingConnections.removeValue(forKey: oldConnection)
                (figure as! UmlFigure).incomingConnections.updateValue(incomingAnchor, forKey: newConnection)
                }
                
                // Replace outgoing connections
                if let outgoingAnchor: String = (figure as! UmlFigure).outgoingConnections[oldConnection] {
                    (figure as! UmlFigure).outgoingConnections.removeValue(forKey: oldConnection)
                    (figure as! UmlFigure).outgoingConnections.updateValue(outgoingAnchor, forKey: newConnection)
                }
            }
        }
    }
}


enum BoundTouched {
    case Up
    case Down
    case Left
    case Right
}
