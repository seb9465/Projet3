//
//  Editor.swift
//  ios
//
//  Created by William Sevigny on 2019-03-11.
//  Copyright © 2019 LOG3000 equipe 12. All rights reserved.
//

import UIKit

class Editor {
    var delegate: EditorDelegate?

    var editorView: EditorView = EditorView()
    var sideToolbatControllers: [SideToolbarController] = []
    var selectedFiguresDictionnary: [String : [DrawViewModel]] = [:]
    var selectedOutlinesDictionnary: [String : [SelectionOutline]] = [:]
    
    // UNDO / REDO Properties
    var currentChange: ([DrawViewModel], [DrawViewModel]) = ([], [])
    var undoArray: [([DrawViewModel], [DrawViewModel])] = []
    var redoArray: [([DrawViewModel], [DrawViewModel])] = []
//    var redoArray: [Figure] = [];
    
    var figures: [Figure] = [];
    var selectedFigures: [Figure] = [];
    var selectionLasso: SelectionLasso! = nil;
    var selectionOutlines: [SelectionOutline] = [];
    
    var oldRotationAngle: Int = 0

    // Connection Creation properties
    var connectionPreview: Figure!
    var sourceFigure: UmlFigure!
    var currentFigureType: ItemTypeEnum = ItemTypeEnum.UmlClass;
    
    // TouchInputDelegate properties
    var touchEventState: TouchEventState = .SELECT
    var initialTouchPoint: CGPoint!
    var previousTouchPoint: CGPoint!
    
    // Pinch gesture properties
    var initialPinchDistance: CGPoint = CGPoint.zero
    
    var clipboard: [Figure] = []
    
    init() {
        self.editorView.delegate = self
        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(self.resizeFigure(_:)))
        self.editorView.addGestureRecognizer(pinch)
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.tap(_:)))
        tap.numberOfTapsRequired = 2
        self.editorView.addGestureRecognizer(tap)
    }
    func resize(width: CGFloat, heigth: CGFloat) {
        currentCanvas.canvasHeight = Float(heigth)
        currentCanvas.canvasWidth = Float(width)
        let origin: CGPoint = CGPoint(x: 250, y: 70)
        let size = CGSize(width: width, height: heigth)
        let newFrame: CGRect = CGRect(origin: origin, size: size)
        self.editorView.frame = newFrame
//        self.editorView.updateShadow()
        self.editorView.updateCanvasAnchor()
        self.editorView.setNeedsDisplay()
    }

    // Select made locally
    func select(figure: Figure) {
        let selectionOutline: SelectionOutline = SelectionOutline(frame: figure.getSelectionFrame(), associatedFigureID: figure.uuid, delegate: self)
        if (figure is ConnectionFigure) {
            print("Showing ELBOW")
            (figure as! ConnectionFigure).showElbowAnchor()
        }
        self.editorView.addSubview(selectionOutline)
        self.delegate?.setCutButtonState(isEnabled: true)
        self.delegate?.setDuplicateButtonState(isEnabled: true)
        self.selectedFigures.append(figure)
        self.selectionOutlines.append(selectionOutline)
        self.delegate?.setCurrentTab(index: 1)
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
    }
    
    func selectLasso(touchPoint: CGPoint) {
        self.selectionLasso = SelectionLasso(size: self.editorView.frame.size, touchPoint: touchPoint);
        self.editorView.addSubview(self.selectionLasso);
    }
    
    // Deselect Locally
    func deselect() {
        if (self.selectionOutlines.count > 0) {
            for outline in self.selectionOutlines {
                outline.removeFromSuperview();
            }
            
            self.selectionOutlines.removeAll();
        }
        
        for figure in self.selectedFigures {
            if (figure is ConnectionFigure) {
                (figure as! ConnectionFigure).hideElbowAnchor()
            }
        }
        CollaborationHub.shared!.selectObjects(drawViewModels: [])
        self.deselectLasso();
        self.selectedFigures.removeAll();
        self.delegate?.setCurrentTab(index: 0)
        self.delegate?.setCutButtonState(isEnabled: false)
        if(self.clipboard.count == 0) {
            self.delegate?.setDuplicateButtonState(isEnabled: false)
        }
    }
    
    // Deselect received from hub
    func deselect(username: String) {
        self.selectedFiguresDictionnary.updateValue([], forKey: username)
        if (selectedOutlinesDictionnary[username] != nil) {
            for outline in self.selectedOutlinesDictionnary[username]! {
                outline.removeFromSuperview()
            }
        }
        self.selectedOutlinesDictionnary.updateValue([], forKey: username)
    }
    
    // Wtf does this do?
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
            self.delegate?.lassoIsDone()
        }
    }
    
    public func copy() -> Void {
        self.clipboard = self.selectedFigures;
        self.delegate?.setDuplicateButtonState(isEnabled: true)
    }
    
    public func duplicate() -> Void {
        if (self.selectedFigures.count > 0) {
            self.copy();
            self.deselect();
        }
        
        var drawViewModelToSelect:[DrawViewModel] = []
        var figureToAdd: [Figure] = []
         for figure in self.clipboard {
            var viewModel = figure.exportViewModel()!;
            viewModel.Guid = UUID().uuidString;
            viewModel.StylusPoints![0].X = viewModel.StylusPoints![0].X + 10;
            viewModel.StylusPoints![0].Y = viewModel.StylusPoints![0].Y + 10;
            viewModel.StylusPoints![1].X = viewModel.StylusPoints![1].X + 10;
            viewModel.StylusPoints![1].Y = viewModel.StylusPoints![1].Y + 10;
            viewModel.InConnections = []
            viewModel.OutConnections = []
            let newFigure: Figure = self.insertFigure(drawViewModel: viewModel)
            self.select(figure: newFigure);
            figureToAdd.append(newFigure)
            drawViewModelToSelect.append(newFigure.exportViewModel()!)
        }
        CollaborationHub.shared!.postNewFigure(figures: figureToAdd);
        CollaborationHub.shared?.selectObjects(drawViewModels: drawViewModelToSelect)
        CanvasService.saveOnNewFigure(figures: self.figures, editor: self);
    }
    
    public func cut() -> Void {
        self.copy();
        self.deleteSelectedFigures();
    }
    
    public func insertFigure(position: CGPoint) -> Void {
        let figure = FigureFactory.shared.getFigure(type: self.currentFigureType, touchedPoint: position)!
        figure.delegate = self
        self.figures.append(figure)
        self.undoArray.append(([], [figure.exportViewModel()!]))
        self.editorView.addSubview(figure)
        self.select(figure: figure)
        print("insert", figure.uuid)
        CollaborationHub.shared?.selectObjects(drawViewModels: [figure.exportViewModel()!])
        CollaborationHub.shared!.postNewFigure(figures: [figure])
        CanvasService.saveOnNewFigure(figures: self.figures, editor: self)
    }
    
    public func insertConnectionFigure(firstPoint: CGPoint, lastPoint: CGPoint, itemType: ItemTypeEnum) -> Figure {
        let figure = FigureFactory.shared.getFigure(
            type: itemType,
            source: firstPoint,
            destination: lastPoint
        )!
        
        figure.delegate = self
        self.undoArray.append(([], [figure.exportViewModel()!]))
        self.editorView.addSubview(figure);
        self.figures.append(figure)
        self.select(figure: figure)
        CollaborationHub.shared?.selectObjects(drawViewModels: [figure.exportViewModel()!])
        self.updateSideToolBar()
        return figure
    }
    
    public func insertFigure(drawViewModel: DrawViewModel) -> Figure {
        let figure = FigureFactory.shared.fromDrawViewModel(drawViewModel: drawViewModel)!
        figure.delegate = self
        self.figures.append(figure)
        self.editorView.addSubview(figure)
        return figure
    }
    
    // Deletes figures in local selections
    public func deleteSelectedFigures() {
        if (self.selectedFigures.isEmpty) {
            return
        }
        var viewModelsToDelete: [DrawViewModel] = []
        for figure in self.selectedFigures {
//            if (figure is ConnectionFigure) {
//                (figure as! ConnectionFigure).removeFromConnectedFigures(umlFigures: self.figures.filter({$0 is UmlFigure}) as! [UmlFigure])
//            }
            figure.removeFromSuperview()
            viewModelsToDelete.append(figure.exportViewModel()!)
            self.figures.removeAll{$0 == figure}
        }
        self.deselect()
        self.selectedFigures.removeAll()
        CollaborationHub.shared?.CutObjects(drawViewModels: viewModelsToDelete)
        CanvasService.saveOnNewFigure(figures: self.figures, editor: self)
    }
    
    public func deleteSelectedFigures(drawViewModels: [DrawViewModel]) {
        for figureToDelete in drawViewModels {
            for (index,figure) in self.figures.enumerated() {
                if(figureToDelete.Guid == figure.uuid.uuidString.lowercased()) {
                    print("remove this one from view" + String(index))
                    figure.removeFromSuperview()
                    self.editorView.setNeedsDisplay()
                    self.figures.remove(at: index)
                }
            }
        }
    }
    
    public func clear() -> Void {
        print("Clearing canvas")
        self.currentChange.0 = self.getFiguresDrawviewModels(figures: self.figures)
        for figure in self.figures {
            figure.removeFromSuperview()
        }
        for selectionOutline in self.selectedOutlinesDictionnary {
            self.deselect(username: selectionOutline.key)
        }
        self.deselect()
        self.selectedFigures.removeAll()
        self.selectionOutlines.removeAll()
        self.editorView.setNeedsDisplay()
        self.figures.removeAll()
        self.currentChange.1 = []
        self.undoArray.append(self.currentChange)
        self.delegate?.setDuplicateButtonState(isEnabled: false)
        CanvasService.saveOnNewFigure(figures: self.figures, editor: self)
    }
    
    func export() -> UIImage{
        UIGraphicsBeginImageContextWithOptions(self.editorView.bounds.size, false, 0.0);
        self.editorView.drawHierarchy(in: self.editorView.bounds, afterScreenUpdates: true);
        let image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return image!
    }
}

extension Editor {
    public func changeTouchHandleState(to: TouchEventState) {
        self.touchEventState = to
    }
}

extension Editor: CollaborationHubDelegate {
    func sendExistingSelection() {
        var drawViewModels: [DrawViewModel] = []
        for figure in self.selectedFigures {
            drawViewModels.append(figure.exportViewModel()!)
        }
        CollaborationHub.shared!.selectObjects(drawViewModels:drawViewModels)
    }
    
    func resizeCanvas(size: PolyPaintStylusPoint) {
        self.resize(width: CGFloat(size.X), heigth: CGFloat(size.Y))
    }
    
    func updateSelection(itemMessage: ItemMessage) {
        if (itemMessage.Items.isEmpty) {
            self.deselect(username: itemMessage.Username)
            return
        }
        self.deselect(username: itemMessage.Username)
        self.select(drawViewModels: itemMessage.Items, username: itemMessage.Username)
    }
    
    func updateCanvas(itemMessage: ItemMessage) {
//        dump(itemMessage.Items)
        for drawViewModel in itemMessage.Items {
            if (self.figures.contains(where: {$0.uuid.uuidString.lowercased() == drawViewModel.Guid})) {
                self.overriteFigure(figureId: drawViewModel.Guid!, newDrawViewModel: drawViewModel, username: itemMessage.Username)

//                self.deselect(username: itemMessage.Username)
//                self.select(drawViewModels: itemMessage.Items, username: itemMessage.Username)
            } else {
                self.insertFigure(drawViewModel: drawViewModel)
            }
        }
        
//        self.bindLocalConnectionsToFigures(drawViewModels: itemMessage.Items)
    }
    
    func delete(drawViewModels: [DrawViewModel]) {
        self.deleteSelectedFigures(drawViewModels: drawViewModels)
    }
    
    func getKicked() {
        self.deselect()
        CollaborationHub.shared!.disconnectFromHub()
        self.delegate?.getKicked()
    }
    
    public func loadCanvas(drawViewModels: [DrawViewModel]) {
        for drawViewModel in drawViewModels  {
            self.insertFigure(drawViewModel: drawViewModel)
        }
//        self.bindLocalConnectionsToFigures(drawViewModels: drawViewModels)
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
    }

        
//        if (oldFigure is ConnectionFigure && newFigure is ConnectionFigure) {
//            self.updateConnectionBindings(oldConnection: oldFigure as! ConnectionFigure, newConnection: newFigure as! ConnectionFigure)
//        }
        
//        if (oldFigure is UmlFigure && newFigure is UmlFigure) {
//            print("Updating received Figure connections")
//            (newFigure as! UmlFigure).outgoingConnections = (oldFigure as! UmlFigure).outgoingConnections
//            (newFigure as! UmlFigure).incomingConnections = (oldFigure as! UmlFigure).incomingConnections
//            (newFigure as! UmlFigure).updateConnections()
//        }
    
//    func bindLocalConnectionsToFigures(drawViewModels: [DrawViewModel]) {
//        for umlFigureModel in drawViewModels.filter({$0.ItemType?.description != "Connection"}) {
//            let figure = self.figures.first(where: {$0.uuid.uuidString.lowercased() == umlFigureModel.Guid}) as! UmlFigure
//            figure.clearConnections()
//            let incomingConnections: [[String]] = umlFigureModel.InConnections!
//            for uuidToin in incomingConnections {
//                let connection: ConnectionFigure = self.figures.first(where: {$0.uuid.uuidString.lowercased() == uuidToin[0]}) as! ConnectionFigure
//                figure.addIncomingConnection(connection: connection, anchor: uuidToin[1])
//            }
//
//            let outgoingConnections: [[String]] = umlFigureModel.OutConnections!
//            for uuidToout in outgoingConnections {
//                let connection: ConnectionFigure = self.figures.first(where: {$0.uuid.uuidString.lowercased() == uuidToout[0]}) as! ConnectionFigure
//                figure.addOutgoingConnection(connection: connection, anchor: uuidToout[1])
//            }
//        }
//    }
    
//    func updateConnectionBindings(oldConnection: ConnectionFigure, newConnection: ConnectionFigure) {
//        for figure in self.figures {
//            if (figure is UmlFigure) {
//                // Replace incoming connections
//                if let incomingAnchor: String = (figure as! UmlFigure).incomingConnections[oldConnection] {
//                (figure as! UmlFigure).incomingConnections.removeValue(forKey: oldConnection)
//                (figure as! UmlFigure).incomingConnections.updateValue(incomingAnchor, forKey: newConnection)
//                }
//
//                // Replace outgoing connections
//                if let outgoingAnchor: String = (figure as! UmlFigure).outgoingConnections[oldConnection] {
//                    (figure as! UmlFigure).outgoingConnections.removeValue(forKey: oldConnection)
//                    (figure as! UmlFigure).outgoingConnections.updateValue(outgoingAnchor, forKey: newConnection)
//                }
//            }
//        }
//    }
}


enum BoundTouched {
    case Up
    case Down
    case Left
    case Right
    case UpLeft
    case UpRight
    case DownLeft
    case DownRight
}
