//
//  UmlActivityFigure.swift
//  ios
//
//  Created by William Sevigny on 2019-03-21.
//  Copyright © 2019 LOG3000 equipe 12. All rights reserved.
//

import UIKit

class UmlActivityFigure: UmlFigure {
    let BASE_WIDTH: CGFloat = 125
    let BASE_HEIGHT: CGFloat = 80
    
    init(firstPoint: CGPoint, lastPoint: CGPoint) {
        super.init(firstPoint: firstPoint, lastPoint: lastPoint, width: BASE_WIDTH, height: BASE_WIDTH)
    }
    
    init(origin: CGPoint) {
        super.init(touchedPoint: origin, width: BASE_WIDTH, height: BASE_HEIGHT)
    }
    
    override init(drawViewModel: DrawViewModel) {
        super.init(drawViewModel: drawViewModel);
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        //// Bezier Drawing
        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x: 7.5, y: 41.11))
        bezierPath.addLine(to: CGPoint(x: 22.53, y: 10.5))
        bezierPath.addLine(to: CGPoint(x: 104.5, y: 10.5))
        bezierPath.addLine(to: CGPoint(x: 89.47, y: 41.11))
        bezierPath.addLine(to: CGPoint(x: 104.5, y: 68.5))
        bezierPath.addLine(to: CGPoint(x: 22.53, y: 68.5))
        bezierPath.addLine(to: CGPoint(x: 7.5, y: 41.11))
        bezierPath.close()
        UIColor.black.setStroke()
        bezierPath.lineWidth = 1
        bezierPath.stroke()
    }
    
    override func exportViewModel() -> DrawViewModel {
        let point1 = PolyPaintStylusPoint(X: Double(self.firstPoint.x), Y: Double(self.firstPoint.y), PressureFactor: 1)
        let point2 = PolyPaintStylusPoint(X: Double(self.lastPoint.x), Y: Double(self.lastPoint.y), PressureFactor: 1)
        
        var drawViewModel: DrawViewModel = DrawViewModel()
        drawViewModel.Guid = self.uuid.uuidString
        drawViewModel.Owner = UserDefaults.standard.string(forKey: "username")
        drawViewModel.ItemType = ItemTypeEnum.Activity
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

