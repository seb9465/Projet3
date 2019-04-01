//
//  UmlArtefactFigure.swift
//  ios
//
//  Created by Sébastien Labine on 19-03-21.
//  Copyright © 2019 LOG3000 equipe 12. All rights reserved.
//

import UIKit

class UmlArtefactFigure: UmlFigure {
    let BASE_WIDTH: CGFloat = 75
    let BASE_HEIGHT: CGFloat = 100
    
    init(firstPoint: CGPoint, lastPoint: CGPoint) {
        super.init(firstPoint: firstPoint, lastPoint: lastPoint, width: BASE_WIDTH, height: BASE_WIDTH)
    }
    
    init(origin: CGPoint) {
        super.init(touchedPoint: origin, width: BASE_WIDTH, height: BASE_HEIGHT)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        //// Bezier 2 Drawing
        let bezier2Path = UIBezierPath()
        bezier2Path.move(to: CGPoint(x: 4.5, y: 97.5))
        bezier2Path.addLine(to: CGPoint(x: 69.5, y: 97.5))
        bezier2Path.addLine(to: CGPoint(x: 69.5, y: 23.9))
        bezier2Path.addLine(to: CGPoint(x: 47.83, y: 23.9))
        bezier2Path.addLine(to: CGPoint(x: 47.5, y: 5.5))
        bezier2Path.addLine(to: CGPoint(x: 4.5, y: 5.5))
        bezier2Path.addLine(to: CGPoint(x: 4.5, y: 97.5))
        bezier2Path.close()
        UIColor.black.setStroke()
        bezier2Path.lineWidth = 1
        bezier2Path.stroke()
        
        
        //// Bezier 3 Drawing
        let bezier3Path = UIBezierPath()
        bezier3Path.move(to: CGPoint(x: 47.5, y: 5.5))
        bezier3Path.addLine(to: CGPoint(x: 69.5, y: 23.5))
        UIColor.black.setStroke()
        bezier3Path.lineWidth = 1
        bezier3Path.stroke()
    }
    
    override func exportViewModel() -> DrawViewModel {
        let point1 = PolyPaintStylusPoint(X: Double(self.firstPoint.x), Y: Double(self.firstPoint.y), PressureFactor: 1)
        let point2 = PolyPaintStylusPoint(X: Double(self.lastPoint.x), Y: Double(self.lastPoint.y), PressureFactor: 1)
        
        var drawViewModel: DrawViewModel = DrawViewModel()
        drawViewModel.Guid = self.uuid.uuidString
        drawViewModel.owner = UserDefaults.standard.string(forKey: "username")
        drawViewModel.ItemType = self.itemType
        drawViewModel.StylusPoints = [point1, point2]
        drawViewModel.FillColor = PolyPaintColor(A: 255, R: 255, G: 1, B: 1)
        drawViewModel.BorderColor = PolyPaintColor(A: 255, R: 255, G: 1, B: 1)
        drawViewModel.BorderThickness = 2.0
        drawViewModel.BorderStyle = "solid"
        drawViewModel.ShapeTitle = "A_IMPLEMENTER"
        drawViewModel.Methods = nil
        drawViewModel.Properties = nil
        drawViewModel.SourceTitle = nil
        drawViewModel.DestinationTitle = nil
        drawViewModel.ChannelId = "general"
        drawViewModel.OutilSelectionne = nil
        drawViewModel.LastElbowPosition = nil
        drawViewModel.ImageBytes = nil
        drawViewModel.Rotation = self.currentAngle
        return drawViewModel
    }
}
