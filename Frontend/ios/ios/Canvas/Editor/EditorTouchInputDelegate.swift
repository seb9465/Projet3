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
            print(action)
            self.initialTouchPoint = point
            self.previousTouchPoint = point
            
            if (action == "selection") {
                self.touchEventState = .TRANSLATE
                return
            }
            if (action == "empty") {
                self.deselect()
                self.updateSideToolBar()
                return
            }
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
        case .NONE:
            break;
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
            
            CollaborationHub.shared!.postNewFigure(figures: self.selectedFigures)
            var drawViewModels: [DrawViewModel] = []
            for figure in selectedFigures {
                drawViewModels.append(figure.exportViewModel()!)
            }
            CollaborationHub.shared!.selectObjects(drawViewModels: drawViewModels)
            self.touchEventState = .SELECT
            return
        }
    }
    
    func handleConnectionTouchEnded(point: CGPoint) {
        if (self.connectionPreview != nil) {
            self.connectionPreview.removeFromSuperview()
        }
        
        guard let destinationFigure: UmlFigure = self.getFigureContaining(point: point) else {
            print("Insert floating connection figure.")
            self.insertConnectionFigure(firstPoint: self.initialTouchPoint, lastPoint: point, itemType: currentFigureType)
            self.touchEventState = .SELECT
            return
        }
        
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
