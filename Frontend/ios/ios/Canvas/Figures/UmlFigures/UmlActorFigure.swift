//
//  UmlActorFigure.swift
//  ios
//
//  Created by William Sevigny on 2019-03-21.
//  Copyright © 2019 LOG3000 equipe 12. All rights reserved.
//

import UIKit

class UmlActorFigure: UmlFigure {
    let BASE_WIDTH: CGFloat = 75
    let BASE_HEIGHT: CGFloat = 100
    
    init(firstPoint: CGPoint, lastPoint: CGPoint) {
        super.init(firstPoint: firstPoint, lastPoint: lastPoint, width: BASE_WIDTH, height: BASE_WIDTH)
        self.itemType = ItemTypeEnum.Role

    }
    
    init(origin: CGPoint) {
        super.init(touchedPoint: origin, width: BASE_WIDTH, height: BASE_HEIGHT)
        self.itemType = ItemTypeEnum.Role
    }
    
    override init(drawViewModel: DrawViewModel) {
        super.init(drawViewModel: drawViewModel);
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        //// Group
        //// Oval Drawing
        let ovalPath = UIBezierPath(ovalIn: CGRect(x: 25, y: 11.5, width: 27, height: 26))
        
        
        //// Bezier Drawing
        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x: 38.26, y: 39.17))
        bezierPath.addLine(to: CGPoint(x: 38.26, y: 73.75))

        //// Bezier 2 Drawing
        let bezier2Path = UIBezierPath()
        bezier2Path.move(to: CGPoint(x: 38.26, y: 39.17))
        bezier2Path.addLine(to: CGPoint(x: 63.5, y: 39.17))

        //// Bezier 3 Drawing
        let bezier3Path = UIBezierPath()
        bezier3Path.move(to: CGPoint(x: 10.5, y: 39.17))
        bezier3Path.addLine(to: CGPoint(x: 38.26, y: 39.17))

        //// Bezier 4 Drawing
        let bezier4Path = UIBezierPath()
        bezier4Path.move(to: CGPoint(x: 38.26, y: 73.75))
        bezier4Path.addLine(to: CGPoint(x: 18.07, y: 92.19))
        
        //// Bezier 5 Drawing
        let bezier5Path = UIBezierPath()
        bezier5Path.move(to: CGPoint(x: 38.26, y: 73.75))
        bezier5Path.addLine(to: CGPoint(x: 58.45, y: 94.5))

        self.lineColor.setStroke()
        self.figureColor.setFill()
        ovalPath.lineWidth = self.lineWidth
        bezierPath.lineWidth = self.lineWidth
        bezier2Path.lineWidth = self.lineWidth
        bezier3Path.lineWidth = self.lineWidth
        bezier4Path.lineWidth = self.lineWidth
        bezier5Path.lineWidth = self.lineWidth
        if(self.isBorderDashed) {
            bezierPath.setLineDash([4,4], count: 1, phase: 0)
            bezier2Path.setLineDash([4,4], count: 1, phase: 0)
            bezier3Path.setLineDash([4,4], count: 1, phase: 0)
            bezier4Path.setLineDash([4,4], count: 1, phase: 0)
            bezier5Path.setLineDash([4,4], count: 1, phase: 0)
        }
        ovalPath.fill()
        bezierPath.fill()
        bezier2Path.fill()
        bezier3Path.fill()
        bezier4Path.fill()
        bezier5Path.fill()
        ovalPath.stroke()
        bezierPath.stroke()
        bezier2Path.stroke()
        bezier3Path.stroke()
        bezier4Path.stroke()
        bezier5Path.stroke()
    }
    
    override func exportViewModel() -> DrawViewModel {
        let point1 = PolyPaintStylusPoint(X: Double(self.firstPoint.x), Y: Double(self.firstPoint.y), PressureFactor: 1)
        let point2 = PolyPaintStylusPoint(X: Double(self.lastPoint.x), Y: Double(self.lastPoint.y), PressureFactor: 1)
        
        var drawViewModel: DrawViewModel = DrawViewModel()
        drawViewModel.Guid = self.uuid.uuidString.lowercased()
        drawViewModel.Owner = UserDefaults.standard.string(forKey: "username")
        drawViewModel.ItemType = ItemTypeEnum.Role
        drawViewModel.StylusPoints = [point1, point2]
        drawViewModel.FillColor = PolyPaintColor(color: self.figureColor)
        drawViewModel.BorderColor = PolyPaintColor(color: self.lineColor)
        drawViewModel.BorderThickness = Double(self.lineWidth)
        drawViewModel.BorderStyle = (self.isBorderDashed) ? "dash" : "solid"
        drawViewModel.ShapeTitle = self.name
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

