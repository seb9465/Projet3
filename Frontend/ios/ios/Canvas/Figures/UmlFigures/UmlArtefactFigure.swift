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
        self.itemType = ItemTypeEnum.Artefact
    }
    
    override init(drawViewModel: DrawViewModel) {
        super.init(drawViewModel: drawViewModel);
    }
    
    init(origin: CGPoint) {
        super.init(touchedPoint: origin, width: BASE_WIDTH, height: BASE_HEIGHT)
        self.itemType = ItemTypeEnum.Artefact
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        // original width = 97.5
        
        //// Bezier 2 Drawing
        let bezier2Path = UIBezierPath()
        bezier2Path.move(to: CGPoint(x: 0, y: self.frame.height))
        bezier2Path.addLine(to: CGPoint(x: 69.5, y: self.frame.height))
        bezier2Path.addLine(to: CGPoint(x: 69.5, y: 25))
        bezier2Path.addLine(to: CGPoint(x: 47.83, y: 25))
        bezier2Path.addLine(to: CGPoint(x: 47.5, y: 0))
        bezier2Path.addLine(to: CGPoint(x: 0, y: 0))
        bezier2Path.addLine(to: CGPoint(x: 0, y: self.frame.height))
        bezier2Path.close()
        
        //// Bezier 3 Drawing
        let bezier3Path = UIBezierPath()
        bezier3Path.move(to: CGPoint(x: 47.5, y: 0))
        bezier3Path.addLine(to: CGPoint(x: 69.5, y: 25))

        self.figureColor.setFill()
        self.lineColor.setStroke()
        bezier2Path.lineWidth = self.lineWidth
        bezier3Path.lineWidth = self.lineWidth
        
        if(self.isBorderDashed) {
            bezier2Path.setLineDash([4,4], count: 1, phase: 0)
            bezier3Path.setLineDash([4,4], count: 1, phase: 0)
        }
        bezier2Path.stroke()
        bezier2Path.fill()
        bezier3Path.stroke()
        bezier3Path.fill()

        
        let textRect = CGRect(x: 0, y: 0, width: BASE_WIDTH, height: 50).insetBy(dx: 5, dy: 5);
        let nameLabel = UILabel(frame: textRect)
        nameLabel.text = self.name
        nameLabel.contentMode = .bottom
        nameLabel.textAlignment = .center
        nameLabel.drawText(in: textRect)
    }
    
    override func exportViewModel() -> DrawViewModel {
        let point1 = PolyPaintStylusPoint(X: Double(self.firstPoint.x), Y: Double(self.firstPoint.y), PressureFactor: 1)
        let point2 = PolyPaintStylusPoint(X: Double(self.lastPoint.x), Y: Double(self.lastPoint.y), PressureFactor: 1)
        
        var drawViewModel: DrawViewModel = DrawViewModel()
        drawViewModel.Guid = self.uuid.uuidString.lowercased()
        drawViewModel.Owner = UserDefaults.standard.string(forKey: "username")
        drawViewModel.ItemType = ItemTypeEnum.Artefact
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
        drawViewModel.ChannelId = canvasId
        drawViewModel.OutilSelectionne = nil
        drawViewModel.LastElbowPosition = nil
        drawViewModel.ImageBytes = nil
        drawViewModel.Rotation = self.currentAngle
        return drawViewModel
    }
}
