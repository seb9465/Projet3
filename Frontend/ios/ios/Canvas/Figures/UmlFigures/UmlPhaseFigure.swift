//
//  UMLPhaseFigure.swift
//  ios
//
//  Created by Sébastien Labine on 19-03-21.
//  Copyright © 2019 LOG3000 equipe 12. All rights reserved.
//

import UIKit

class UmlPhaseFigure: UmlFigure {
    let BASE_WIDTH: CGFloat = 400
    let BASE_HEIGHT: CGFloat = 250
    
    init(firstPoint: CGPoint, lastPoint: CGPoint) {
        super.init(firstPoint: firstPoint, lastPoint: lastPoint, width: BASE_WIDTH, height: BASE_WIDTH)
        self.itemType = ItemTypeEnum.Phase
        self.initializeAnchorPoints()
    }
    
    override init(drawViewModel: DrawViewModel) {
        super.init(drawViewModel: drawViewModel);
        self.name = drawViewModel.ShapeTitle!
        self.initializeAnchorPoints()
    }
    
    init(origin: CGPoint) {
        super.init(touchedPoint: origin, width: BASE_WIDTH, height: BASE_HEIGHT)
        self.itemType = ItemTypeEnum.Phase
        self.initializeAnchorPoints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(_ rect: CGRect) {
         let outerRect = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height).insetBy(dx: 5, dy: 5);
        let phaneNameRect = CGRect(x: 0, y: 0, width: self.frame.width, height: 50).insetBy(dx: 5, dy: 5);
        
        let phaseNameLabel = UILabel(frame: phaneNameRect)
        phaseNameLabel.text = self.name
        phaseNameLabel.textAlignment = .center
        
        let outerRectPath = UIBezierPath(rect: outerRect)
        let commentRectPath = UIBezierPath(rect: phaneNameRect)
        
        self.figureColor.setFill()
        self.lineColor.setStroke()
        if(self.isBorderDashed) {
            outerRectPath.setLineDash([4,4], count: 1, phase: 0)
            commentRectPath.setLineDash([4,4], count: 1, phase: 0)
        }
        outerRectPath.lineWidth = self.lineWidth
        outerRectPath.fill()
        outerRectPath.stroke()
        commentRectPath.lineWidth = self.lineWidth
        commentRectPath.fill()
        commentRectPath.stroke()
        phaseNameLabel.drawText(in: phaneNameRect)
    }
    
    override func exportViewModel() -> DrawViewModel {
        let point1 = PolyPaintStylusPoint(X: Double(self.firstPoint.x), Y: Double(self.firstPoint.y), PressureFactor: 1)
        let point2 = PolyPaintStylusPoint(X: Double(self.lastPoint.x), Y: Double(self.lastPoint.y), PressureFactor: 1)
        
        var drawViewModel: DrawViewModel = DrawViewModel()
        drawViewModel.Guid = self.uuid.uuidString.lowercased()
        drawViewModel.Owner = UserDefaults.standard.string(forKey: "username")
        drawViewModel.ItemType = ItemTypeEnum.Phase
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
