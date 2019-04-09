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
    let BASE_HEIGHT: CGFloat = 150
    
    init(firstPoint: CGPoint, lastPoint: CGPoint) {
        super.init(firstPoint: firstPoint, lastPoint: lastPoint, width: BASE_WIDTH, height: BASE_WIDTH)
        self.itemType = ItemTypeEnum.Role
        self.name = "Role"
    }
    
    init(origin: CGPoint) {
        super.init(touchedPoint: origin, width: BASE_WIDTH, height: BASE_HEIGHT)
        self.itemType = ItemTypeEnum.Role
        self.initializeAnchorPoints()
        self.name = "Role"
    }
    
    override init(drawViewModel: DrawViewModel) {
        super.init(drawViewModel: drawViewModel);
        self.initializeAnchorPoints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func initializeAnchorPoints() {
        if (Int(self.currentAngle / 90) % 2 == 0) {
            self.anchorPoints = AnchorPoints(width: self.frame.width, height: self.frame.height - nameLabelHeight)
        } else {
            self.anchorPoints = AnchorPoints(width: self.frame.height, height: self.frame.width - nameLabelHeight)
        }
        self.layer.addSublayer((self.anchorPoints?.anchorPointsBottom)!)
        self.layer.addSublayer((self.anchorPoints?.anchorPointsTop)!)
        self.layer.addSublayer((self.anchorPoints?.anchorPointsLeft)!)
        self.layer.addSublayer((self.anchorPoints?.anchorPointsRight)!)
    }
    
    override func draw(_ rect: CGRect) {
        var width = abs(self.frame.origin.x - self.frame.maxX)
        var height = abs(self.frame.origin.y - self.frame.maxY)
        
        if (Int(self.currentAngle / 90) % 2 != 0) {
            let temp = width
            width = height
            height = temp
        }
        
        let inset: CGFloat = (self.lineWidth > 5) ? self.lineWidth : 5
        width = width - 2 * inset
        height = height - inset - nameLabelHeight

        //// Oval Drawing
        let ovalPath = UIBezierPath(ovalIn: CGRect(x: width/4 + inset, y: inset, width: width/2, height: height/4))

        //// Body
        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x: inset + width / 2, y: inset + height/4))
        bezierPath.addLine(to: CGPoint(x: inset + width / 2, y: 3*height/4))

        //// Bras
        let bezier2Path = UIBezierPath()
        bezier2Path.move(to: CGPoint(x: inset, y: 2*height/5))
        bezier2Path.addLine(to: CGPoint(x: inset + width, y: 2*height/5))


        //// Bezier 4 Drawing
        let bezier4Path = UIBezierPath()
        bezier4Path.move(to: CGPoint(x: inset + width/2, y: 3*height/4))
        bezier4Path.addLine(to: CGPoint(x: inset, y: height))
        
        //// Bezier 5 Drawing
        let bezier5Path = UIBezierPath()
        bezier5Path.move(to: CGPoint(x: inset + width/2, y: 3*height/4))
        bezier5Path.addLine(to: CGPoint(x: inset + width, y: height))

        self.lineColor.setStroke()
        self.figureColor.setFill()
        ovalPath.lineWidth = self.lineWidth
        bezierPath.lineWidth = self.lineWidth
        bezier2Path.lineWidth = self.lineWidth
        bezier4Path.lineWidth = self.lineWidth
        bezier5Path.lineWidth = self.lineWidth

        if(self.isBorderDashed) {
            ovalPath.setLineDash([4,4], count: 1, phase: 0)
            bezierPath.setLineDash([4,4], count: 1, phase: 0)
            bezier2Path.setLineDash([4,4], count: 1, phase: 0)
            bezier4Path.setLineDash([4,4], count: 1, phase: 0)
            bezier5Path.setLineDash([4,4], count: 1, phase: 0)
        }
        ovalPath.fill()
        bezierPath.fill()
        bezier2Path.fill()
        bezier4Path.fill()
        bezier5Path.fill()
        ovalPath.stroke()
        bezierPath.stroke()
        bezier2Path.stroke()
        bezier4Path.stroke()
        bezier5Path.stroke()
        
        width = abs(self.frame.origin.x - self.frame.maxX)
        height = abs(self.frame.origin.y - self.frame.maxY)
        
        if (Int(self.currentAngle / 90) % 2 != 0) {
            let temp = width
            width = height
            height = temp
        }
        let textRect = CGRect(x: 0, y: height - nameLabelHeight - 5, width: width, height: nameLabelHeight)
        let nameLabel = UILabel(frame: textRect)
        nameLabel.text = self.name
        nameLabel.contentMode = .top
        nameLabel.textAlignment = .center
        nameLabel.drawText(in: textRect)
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

