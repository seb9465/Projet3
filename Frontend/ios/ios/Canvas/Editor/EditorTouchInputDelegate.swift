//
//  Editor_TouchInputDelegate.swift
//  ios
//
//  Created by William Sevigny on 2019-04-04.
//  Copyright © 2019 LOG3000 equipe 12. All rights reserved.
//
import UIKit

extension Editor : TouchInputDelegate {
    func notifyTouchBegan(action: String, point: CGPoint, figure: Figure?) {
        print(self.touchEventState)
//        if (self.touchEventState == .SELECT) {
//            self.handleSelectTouchBegin(action: action, point: point)
//            return
//        }
//        
//        if (self.touchEventState == .INSERT) {
//            self.insertFigure(position: point)
//            self.touchEventState = .SELECT
//            self.updateSideToolBar()
//            return
//        }
        
        switch (self.touchEventState) {
        case .SELECT:
            self.handleSelectTouchBegin(action: action, point: point)
            break;
        case .REZISE:
            break
        case .TRANSLATE:
            break
        case .INSERT:
            self.insertFigure(position: point)
            self.touchEventState = .SELECT
            self.updateSideToolBar()
            break
        case .CONNECTION:
            self.initialTouchPoint = point
            self.previousTouchPoint = point
            if (action == "shape") {
                self.sourceFigure = (figure as! UmlFigure)
                self.initialTouchPoint = self.sourceFigure.getClosestAnchorPoint(point: point)
                self.connectionPreview = FigureFactory.shared.getFigure(type: self.currentFigureType, source: self.initialTouchPoint, destination: self.initialTouchPoint)
                self.editorView.addSubview(connectionPreview)
                self.touchEventState = .CONNECTION
                return
            }
            
            if (action == "empty") {
                self.connectionPreview = FigureFactory.shared.getFigure(type: self.currentFigureType, source: self.initialTouchPoint, destination: self.initialTouchPoint)
                self.editorView.addSubview(connectionPreview)
                self.touchEventState = .CONNECTION
                return
            }
            
            break
        case .DELETE:
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
        case .ELBOW:
            break
        case .NONE:
            break
        case .CANVAS_RESIZE:
            break
        }
    }
    
    private func handleSelectTouchBegin(action: String, point: CGPoint) {
        self.initialTouchPoint = point
        self.previousTouchPoint = point
        print(action)
        
        if (action == "selection") {
            if (self.selectedFigures.isEmpty) {
                return
            }
            
            if (!(self.selectedFigures.contains(where: {$0 is ConnectionFigure}))) {
                self.currentChange.0 = self.getSelectedFiguresDrawviewModels()
                self.touchEventState = .TRANSLATE
                return
            }
            
            // Check if user is selecting the elbow
            if (self.selectedFigures.count == 1) {
                if ((self.selectedFigures[0] as! ConnectionFigure).isPointOnElbow(point: point)) {
                    
                    var models: [DrawViewModel] = self.getSelectedFiguresDrawviewModels()
                    let connection: ConnectionFigure = (self.selectedFigures[0] as! ConnectionFigure)
                    models.append(contentsOf: self.getFiguresDrawviewModels(figures: connection.getAnchoredUmlFigures(umlFigures: self.getUmlFigures())))

                    self.currentChange.0 = models
                    self.touchEventState = .ELBOW
                    return
                }
            }
            
            // Only translate when all connected Anchors are selected
            for connection in self.selectedFigures.filter({$0 is ConnectionFigure}) {
                if (!self.isAllAnchoredFiguresInSelection(connection: connection as! ConnectionFigure)) {
                    return
                }
            }
            
            self.currentChange.0 = self.getSelectedFiguresDrawviewModels()
            self.touchEventState = .TRANSLATE
            return
        }
        
        if (action == "canvas_anchor") {
            print("allo, je resize le canvas")
            self.touchEventState = .CANVAS_RESIZE
            return
        }

        if (action == "empty") {
            self.deselect()
            self.updateSideToolBar()
            return
        }
    }
    
    func notifyTouchMoved(point: CGPoint, figure: Figure?) {
        if (self.touchEventState == .TRANSLATE) {
            self.touchEventState = .TRANSLATE

            let xOffset = CGFloat(point.x - self.previousTouchPoint.x)
            let yOffset = CGFloat(point.y - self.previousTouchPoint.y)
            
            for figure in self.selectedFigures {
                let tmpOutlineIndex: Int = self.selectionOutlines.firstIndex(where: { $0.associatedFigureID == figure.uuid })!;
                let offset = CGPoint(x: xOffset, y: yOffset)
                figure.translate(by: offset)
                self.selectionOutlines[tmpOutlineIndex].translate(by: offset)
            }
            
            self.previousTouchPoint = point
            return
        }
        
        if (self.touchEventState == .ELBOW) {
            (self.selectedFigures[0] as! ConnectionFigure).updateElbowAnchor(point: point)
            let outlineIndex: Int = self.selectionOutlines.firstIndex(where: { $0.associatedFigureID == self.selectedFigures[0].uuid })!
            self.selectionOutlines[outlineIndex].updateOutline(newFrame: self.selectedFigures[0].getSelectionFrame())
            return
        }
        
        if (self.touchEventState == .CANVAS_RESIZE) {
            self.resize(width: point.x, heigth: point.y)
            self.editorView.updateCanvasAnchor()
            return
        }
        
        if (self.touchEventState == .CONNECTION) {
            if(self.connectionPreview != nil){
                self.connectionPreview.removeFromSuperview()
            }
            self.connectionPreview = FigureFactory.shared.getFigure(type: self.currentFigureType, source: self.initialTouchPoint, destination: point)
            self.editorView.addSubview(self.connectionPreview)
            return
        }
    }
    
    func notifyTouchEnded(point: CGPoint, figure: Figure?) {
        if (self.touchEventState == .CONNECTION) {
            self.handleConnectionTouchEnded(point: point)
            self.sourceFigure = nil
            return
        }
        
        if (self.touchEventState == .SELECT) {
            if (figure == nil) {
                return
            }
            self.deselect()
            
            if (self.isFigureSelected(figure: figure!)) {
                return
            }
            self.select(figure: figure!)
            self.updateSideToolBar()
            CollaborationHub.shared!.selectObjects(drawViewModels: [(figure!.exportViewModel())!])
            return
        }
        
        if (self.touchEventState == .AREA_SELECT) {
            if (!self.selectionLasso.shapeIsClosed) {
                return
            }
            for figure in self.figures {
                if (self.selectionLasso.contains(figure: figure)) {
                    if (!self.isFigureSelected(figure: figure)) {
                        self.select(figure: figure);
                    }
                }
            }

            CollaborationHub.shared!.selectObjects(drawViewModels: self.getSelectedFiguresDrawviewModels())
            self.deselectLasso();
            self.updateSideToolBar()
            
            self.touchEventState = .SELECT
            return
        }
        
        if (self.touchEventState == .TRANSLATE) {
            if (self.selectedFigures.isEmpty) {
                self.touchEventState = .SELECT
                return
            }
            CanvasService.saveOnNewFigure(figures: self.figures, editor: self)

            // UPDATE Affected ConnectionFigures
            var figuresToUpdate = self.selectedFigures
            for figure in selectedFigures {
                if (figure is UmlFigure) {
                    figuresToUpdate.append(contentsOf: (figure as! UmlFigure).getAnchoredConnections())
                }
            }
            
            self.currentChange.1 = self.getSelectedFiguresDrawviewModels()
            self.undoArray.append((self.currentChange))
            
            CollaborationHub.shared!.postNewFigure(figures: figuresToUpdate)
            CollaborationHub.shared!.selectObjects(drawViewModels: self.getSelectedFiguresDrawviewModels())
            self.touchEventState = .SELECT
            return
        }
        
        if (self.touchEventState == .ELBOW) {
            var models: [DrawViewModel] = self.getSelectedFiguresDrawviewModels()
            let connection: ConnectionFigure = (self.selectedFigures[0] as! ConnectionFigure)
            models.append(contentsOf: self.getFiguresDrawviewModels(figures: connection.getAnchoredUmlFigures(umlFigures: self.getUmlFigures())))
            self.currentChange.1 = models
            self.undoArray.append((self.currentChange))
            
            CollaborationHub.shared!.postNewFigure(drawViewModels: models)
            CollaborationHub.shared!.selectObjects(drawViewModels: self.getSelectedFiguresDrawviewModels())
            self.touchEventState = .SELECT
            return
        }

        if (self.touchEventState == .CANVAS_RESIZE) {
            self.resize(width: point.x, heigth: point.y)
            CollaborationHub.shared?.ResizeCanvas(width: Double(point.x), height: Double(point.y))
            CanvasService.saveOnNewFigure(figures: self.figures, editor: self)
            self.touchEventState = .SELECT
            return
        }
    }
    
    func handleConnectionTouchEnded(point: CGPoint) {
        if (self.connectionPreview != nil) {
            self.connectionPreview.removeFromSuperview()
        }
        
        let floatingFigures: [ItemTypeEnum] = [.UniderectionalAssoication, .BidirectionalAssociation, .Line]
        
        // Case 1 - Floating
        if (self.sourceFigure == nil && self.getFigureContaining(point: point) == nil) {
            if (!floatingFigures.contains(self.currentFigureType)) {
                self.touchEventState = .SELECT
                return
            }
            let connection = self.insertConnectionFigure(firstPoint: self.initialTouchPoint, lastPoint: point, itemType: currentFigureType)
            CollaborationHub.shared!.postNewFigure(figures: [connection])
            CanvasService.saveOnNewFigure(figures: self.figures, editor: self)
            self.touchEventState = .SELECT
            return
        }
        
        // Case 2 - Origin anchored
        if (self.sourceFigure != nil && self.getFigureContaining(point: point) == nil) {
            if (!floatingFigures.contains(self.currentFigureType)) {
                self.touchEventState = .SELECT
                return
            }
            let connection = self.insertConnectionFigure(firstPoint: self.initialTouchPoint, lastPoint: point, itemType: currentFigureType)
            let sourceAnchor: String = self.sourceFigure.getClosestAnchorPointName(point: self.initialTouchPoint)
            self.sourceFigure.addOutgoingConnection(connection: connection as! ConnectionFigure, anchor: sourceAnchor)
            CollaborationHub.shared!.postNewFigure(figures: [self.sourceFigure, connection])
            CanvasService.saveOnNewFigure(figures: self.figures, editor: self)
            self.touchEventState = .SELECT
            return
        }
        
        // Case 3 - Destination Anchored
        if (self.sourceFigure == nil && self.getFigureContaining(point: point) != nil) {
            if (!floatingFigures.contains(self.currentFigureType)) {
                self.touchEventState = .SELECT
                return
            }
            let destinationFigure: UmlFigure = self.getFigureContaining(point: point)!
            let connection = self.insertConnectionFigure(
                firstPoint: self.initialTouchPoint,
                lastPoint: destinationFigure.getClosestAnchorPoint(point: point),
                itemType: currentFigureType
            )
            CollaborationHub.shared!.postNewFigure(figures: [connection])
            let destinationAnchor: String = destinationFigure.getClosestAnchorPointName(point: point)
            destinationFigure.addIncomingConnection(connection: connection as! ConnectionFigure, anchor: destinationAnchor)
            self.touchEventState = .SELECT
            CollaborationHub.shared!.postNewFigure(figures: [destinationFigure, connection])
            CanvasService.saveOnNewFigure(figures: self.figures, editor: self)
            return
        }
        
        // Case 4 - All Anchored
        let destinationFigure: UmlFigure = self.getFigureContaining(point: point)!
        if (destinationFigure.isEqual(self.sourceFigure)) {
            print("Insert cancelled: Cannot connect figure to itself.")
            self.touchEventState = .SELECT
            return
        }
        
        let connection = self.insertConnectionFigure(
            firstPoint: self.initialTouchPoint,
            lastPoint: destinationFigure.getClosestAnchorPoint(point: point),
            itemType: currentFigureType
        )
        
        let sourceAnchor: String = self.sourceFigure.getClosestAnchorPointName(point: self.initialTouchPoint)
        let destinationAnchor: String = destinationFigure.getClosestAnchorPointName(point: point)
        self.sourceFigure.addOutgoingConnection(connection: connection as! ConnectionFigure, anchor: sourceAnchor)
        destinationFigure.addIncomingConnection(connection: connection as! ConnectionFigure, anchor: destinationAnchor)
        CollaborationHub.shared!.postNewFigure(figures: [self.sourceFigure, destinationFigure, connection])
        CanvasService.saveOnNewFigure(figures: self.figures, editor: self)
        self.touchEventState = .SELECT
        return
    }
}
