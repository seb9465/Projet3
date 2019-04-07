//
//  EditorGesturesHandler.swift
//  ios
//
//  Created by William Sevigny on 2019-04-05.
//  Copyright © 2019 LOG3000 equipe 12. All rights reserved.
//

import UIKit

extension Editor {
    @objc func rotatedView(_ sender: UIRotationGestureRecognizer) {
        if(!self.selectedFigures.isEmpty && sender.state == .changed) {
            let currentRotationAngle = Int(rad2deg(sender.rotation));
            
            if(currentRotationAngle % 45 == 0) {    // 45 degree pour faciliter la gesture
                for figure in self.selectedFigures {
                    let tempFigure: Figure = figure;
                    if(self.oldRotationAngle < currentRotationAngle) {
                        self.rotate(orientation: .right);
                    } else {
                        self.rotate(orientation: .left);
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
    
    @objc func resizeFigure(_ sender: UIPinchGestureRecognizer) {
        // very important:
        if sender.numberOfTouches < 2 {
            print("avoided an obscure crash!!")
            return
        }
        
        if (self.selectedFigures.count != 1) {
            return
        }
        
        let A = sender.location(ofTouch: 0, in: self.editorView)
        let B = sender.location(ofTouch: 1, in: self.editorView)
        let xD = abs( A.x - B.x )
        let yD = abs( A.y - B.y )
        
        if (sender.state == .began) {
            self.initialPinchDistance = CGPoint(x: xD, y: yD)
        }
        
        let xScale = xD - self.initialPinchDistance.x
        let yScale = yD - self.initialPinchDistance.y
        
        // To be fixed later
        self.initialPinchDistance = CGPoint(x: xD, y: yD)
        self.selectedFigures[0].resize(by: CGPoint(x: xScale, y: yScale))
        let outlineIndex: Int = self.selectionOutlines.firstIndex(where: { $0.associatedFigureID == self.selectedFigures[0].uuid })!
        self.selectionOutlines[outlineIndex].updateOutline(newFrame: self.selectedFigures[0].getSelectionFrame())
        if (sender.state == .cancelled || sender.state == .ended) {
            print("Stopped")
            CollaborationHub.shared!.postNewFigure(figures: self.selectedFigures)
            CollaborationHub.shared!.selectObjects(drawViewModels: self.getSelectedFiguresDrawviewModels())
        }
    }
}
