//
//  UMLTextFigure.swift
//  ios
//
//  Created by Sébastien Labine on 19-03-22.
//  Copyright © 2019 LOG3000 equipe 12. All rights reserved.
//

import UIKit

class UMLTextFigure: UmlFigure {
    let BASE_WIDTH: CGFloat = 100
    let BASE_HEIGHT: CGFloat = 50
    
    init(firstPoint: CGPoint, lastPoint: CGPoint) {
        super.init(firstPoint: firstPoint, lastPoint: lastPoint, width: BASE_WIDTH, height: BASE_WIDTH)
        self.itemType = ItemTypeEnum.Text
        self.initializeAnchorPoints()
    }
    
    override init(drawViewModel: DrawViewModel) {
        super.init(drawViewModel: drawViewModel);
        self.name = drawViewModel.ShapeTitle!
        self.initializeAnchorPoints()
    }
    
    init(origin: CGPoint) {
        super.init(touchedPoint: origin, width: BASE_WIDTH, height: BASE_HEIGHT)
        self.itemType = ItemTypeEnum.Text
        self.initializeAnchorPoints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(_ rect: CGRect) {
        var width = abs(self.frame.origin.x - self.frame.maxX)
        var height = abs(self.frame.origin.y - self.frame.maxY)
        
        if (Int(self.currentAngle / 90) % 2 != 0) {
            let temp = width
            width = height
            height = temp
        }
        let textRect = CGRect(x: 0, y: 0, width: width, height: height).insetBy(dx: 5, dy: 5);
        let textLabel = UILabel(frame: textRect)
        textLabel.text = self.name
        textLabel.textAlignment = .center
        textLabel.drawText(in: textRect)
    }
    
    override func exportViewModel() -> DrawViewModel {
        let point1 = PolyPaintStylusPoint(X: Double(self.firstPoint.x), Y: Double(self.firstPoint.y), PressureFactor: 1)
        let point2 = PolyPaintStylusPoint(X: Double(self.lastPoint.x), Y: Double(self.lastPoint.y), PressureFactor: 1)
        
        var drawViewModel: DrawViewModel = DrawViewModel()
        drawViewModel.Guid = self.uuid.uuidString.lowercased()
        drawViewModel.Owner = UserDefaults.standard.string(forKey: "username")
        drawViewModel.ItemType = ItemTypeEnum.Text
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
        drawViewModel.InConnections = self.serializeIncomingConnections()
        drawViewModel.OutConnections = self.serializeOutgoingConnections()
        return drawViewModel
    }
}
