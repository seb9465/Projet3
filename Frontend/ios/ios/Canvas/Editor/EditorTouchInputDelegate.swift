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
//                let floatingFigures: [ItemTypeEnum] = [.UniderectionalAssoication, .BidirectionalAssociation, .Line]
//                if (!floatingFigures.contains(self.currentFigureType)) {
//                    self.touchEventState = .SELECT
//                    return
//                }
                
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
        }
    }
    
    private func handleSelectTouchBegin(action: String, point: CGPoint) {
        self.initialTouchPoint = point
        self.previousTouchPoint = point
        print(action)
        
        if (action == "selection") {
            if (!(self.selectedFigures[0] is ConnectionFigure)) {
                self.touchEventState = .TRANSLATE
                return
            }
            // Check if user is selecting the elbow
            if ((self.selectedFigures[0] as! ConnectionFigure).isPointOnElbow(point: point)) {
                self.touchEventState = .ELBOW
                return
            }
            
            if ((self.selectedFigures[0] as! ConnectionFigure).isOriginAnchored(umlFigures: self.figures.filter({$0 is UmlFigure}) as! [UmlFigure])) {
                return
            }
            if ((self.selectedFigures[0] as! ConnectionFigure).isDestinationAnchored(umlFigures: self.figures.filter({$0 is UmlFigure}) as! [UmlFigure])) {
                return
            }
            
            self.touchEventState = .TRANSLATE
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
            self.touchEventState = .TRANSLATE;
            // out of bounds
            var xOffset = CGFloat(point.x - self.previousTouchPoint.x)
            var yOffset = CGFloat(point.y - self.previousTouchPoint.y)
            
            for figure in self.selectedFigures {
                let tmpOutlineIndex: Int = self.selectionOutline.firstIndex(where: { $0.associatedFigureID == figure.uuid })!;
                let boundTouched: BoundTouched? = self.isOutOfBounds(view: self.selectionOutline[tmpOutlineIndex])
                
                switch(boundTouched) {
                case .Up?:
                    if(yOffset < 0) {
                        yOffset = 0
                    }
                    break
                case .Down?:
                    if(yOffset > 0) {
                        yOffset = 0
                    }
                case .Left?:
                    if(xOffset < 0) {
                        xOffset = 0
                    }
                    break
                case .Right?:
                    if(xOffset > 0) {
                        xOffset = 0
                    }
                case .none:
                    break
                }
                let offset = CGPoint(x: xOffset, y: yOffset)
                figure.translate(by: offset)
                self.selectionOutline[tmpOutlineIndex].translate(by: offset)
            }
            
            self.previousTouchPoint = point
            return
        }
        
        if (self.touchEventState == .ELBOW) {
            (self.selectedFigures[0] as! ConnectionFigure).updateElbowAnchor(point: point)
            return
        }
        
        if (self.touchEventState == .CONNECTION) {
            self.connectionPreview.removeFromSuperview()
            self.connectionPreview = FigureFactory.shared.getFigure(type: self.currentFigureType, source: self.initialTouchPoint, destination: point)
            //            self.connectionPreview = ConnectionFigure(origin: self.initialTouchPoint, destination: point, itemType: .UniderectionalAssoication)
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
                    self.select(figure: figure);
                }
            }
            var drawViewModels: [DrawViewModel] = []
            for figure in selectedFigures {
                drawViewModels.append(figure.exportViewModel()!)
            }
            CollaborationHub.shared!.selectObjects(drawViewModels: drawViewModels)
            self.deselectLasso();
            self.touchEventState = .AREA_SELECT
            return
        }
        
        if (self.touchEventState == .TRANSLATE) {
            if (self.selectedFigures.isEmpty) {
                self.touchEventState = .SELECT
                return
            }
            CanvasService.saveOnNewFigure(figures: self.figures, editor: self)
            CollaborationHub.shared!.postNewFigure(figures: self.selectedFigures)
            var drawViewModels: [DrawViewModel] = []
            for figure in selectedFigures {
                drawViewModels.append(figure.exportViewModel()!)
            }
            CollaborationHub.shared!.selectObjects(drawViewModels: drawViewModels)
            self.touchEventState = .SELECT
            return
        }
        
        if (self.touchEventState == .ELBOW) {
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
            CollaborationHub.shared!.postNewFigure(figures: [connection])

            let sourceAnchor: String = self.sourceFigure.getClosestAnchorPointName(point: self.initialTouchPoint)
            self.sourceFigure.addOutgoingConnection(connection: connection as! ConnectionFigure, anchor: sourceAnchor)
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
            CollaborationHub.shared!.postNewFigure(figures: self.selectedFigures)
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
        CollaborationHub.shared!.postNewFigure(figures: [connection])
        let sourceAnchor: String = self.sourceFigure.getClosestAnchorPointName(point: self.initialTouchPoint)
        let destinationAnchor: String = destinationFigure.getClosestAnchorPointName(point: point)
        self.sourceFigure.addOutgoingConnection(connection: connection as! ConnectionFigure, anchor: sourceAnchor)
        destinationFigure.addIncomingConnection(connection: connection as! ConnectionFigure, anchor: destinationAnchor)
        self.touchEventState = .SELECT
        return
    }
    
    public func isOutOfBounds(view: UIView) -> BoundTouched? {
        let intersectedFrame = self.editorView.bounds.intersection(view.frame)
        let safetySpace: CGFloat = 1
        if(abs(intersectedFrame.minX - (view.frame.minX - safetySpace)) >  1) {
            return .Left
        }
        if(abs(intersectedFrame.minY - (view.frame.minY - safetySpace)) > 1) {
            return .Up
        }
        if(abs(intersectedFrame.maxX - (view.frame.maxX + safetySpace)) > 1) {
            return .Right
        }
        if(abs(intersectedFrame.maxY - (view.frame.maxY + safetySpace)) > 1) {
            return .Down
        }
        return nil
    }
}
