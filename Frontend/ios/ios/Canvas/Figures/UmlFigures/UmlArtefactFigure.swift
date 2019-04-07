//
//  UmlArtefactFigure.swift
//  ios
//
//  Created by Sébastien Labine on 19-03-21.
//  Copyright © 2019 LOG3000 equipe 12. All rights reserved.
//

import UIKit

class UmlArtefactFigure: UmlFigure {
    let BASE_WIDTH: CGFloat = 70
    let BASE_HEIGHT: CGFloat = 120
    
    init(firstPoint: CGPoint, lastPoint: CGPoint) {
        super.init(firstPoint: firstPoint, lastPoint: lastPoint, width: BASE_WIDTH, height: BASE_WIDTH)
        self.itemType = ItemTypeEnum.Artefact
        self.initializeAnchorPoints()
    }
    
    override init(drawViewModel: DrawViewModel) {
        super.init(drawViewModel: drawViewModel);
        self.initializeAnchorPoints()
    }
    
    init(origin: CGPoint) {
        super.init(touchedPoint: origin, width: BASE_WIDTH, height: BASE_HEIGHT)
        self.itemType = ItemTypeEnum.Artefact
        self.initializeAnchorPoints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func initializeAnchorPoints() {
        self.anchorPoints = AnchorPoints(width: self.frame.width, height: self.frame.height - nameLabelHeight)
        self.layer.addSublayer((self.anchorPoints?.anchorPointsBottom)!)
        self.layer.addSublayer((self.anchorPoints?.anchorPointsTop)!)
        self.layer.addSublayer((self.anchorPoints?.anchorPointsLeft)!)
        self.layer.addSublayer((self.anchorPoints?.anchorPointsRight)!)
    }
    
    override func draw(_ rect: CGRect) {
        let inset: CGFloat = (self.lineWidth > 5) ? self.lineWidth : 5
        let width = self.frame.width - inset
        let height = self.frame.height - inset - nameLabelHeight
        
        //// Bezier 2 Drawing
        let bezier2Path = UIBezierPath()
        bezier2Path.move(to: CGPoint(x: inset, y: height))
        bezier2Path.addLine(to: CGPoint(x: width, y: height))
        bezier2Path.addLine(to: CGPoint(x: width, y: height/6))
        bezier2Path.addLine(to: CGPoint(x: width * 5/6, y: height/6))
        bezier2Path.addLine(to: CGPoint(x: width * 5/6, y: inset))
        bezier2Path.addLine(to: CGPoint(x: inset, y: inset))
        bezier2Path.addLine(to: CGPoint(x: inset, y: height))
        bezier2Path.close()
        
        //// Bezier 3 Drawing
        let bezier3Path = UIBezierPath()
        bezier3Path.move(to: CGPoint(x: width * 5/6, y: inset))
        bezier3Path.addLine(to: CGPoint(x: width, y: height/6))

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

        
        let textRect = CGRect(x: 0, y: self.frame.height - nameLabelHeight - 5, width: self.frame.width, height: nameLabelHeight)
        let nameLabel = UILabel(frame: textRect)
        nameLabel.text = self.name
        nameLabel.backgroundColor = UIColor.white
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
        drawViewModel.InConnections = self.serializeIncomingConnections()
        drawViewModel.OutConnections = self.serializeOutgoingConnections()
        return drawViewModel
    }
}
