//
//  ClassUmlFigure.swift
//  ios
//
//  Created by William Sevigny on 2019-03-11.
//  Copyright © 2019 LOG3000 equipe 12. All rights reserved.
//

import UIKit
import GLKit

class UmlClassFigure: UmlFigure {
    
    // Constants
    let BASE_WIDTH: CGFloat = 150
    let BASE_HEIGHT: CGFloat = 200
    
    public var methods: [String] = []
    public var attributes: [String] = []
    
    init(origin: CGPoint) {
        super.init(touchedPoint: origin, width: BASE_WIDTH, height: BASE_HEIGHT)
        self.itemType = ItemTypeEnum.UmlClass
        self.initializeAnchorPoints()
    }
    
    init(firstPoint: CGPoint, lastPoint: CGPoint) {
        super.init(firstPoint: firstPoint, lastPoint: lastPoint, width: BASE_WIDTH, height: BASE_WIDTH)
        self.itemType = ItemTypeEnum.UmlClass
        self.initializeAnchorPoints()
    }
    
    override init(drawViewModel: DrawViewModel) {
        super.init(drawViewModel: drawViewModel);
        self.methods = drawViewModel.Methods!
        self.attributes = drawViewModel.Properties!
        self.initializeAnchorPoints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func setClassName(name: String) -> Void {
        self.name = name;
        setNeedsDisplay();
    }
    
    public func addMethod(name: String) {
        self.methods.append(name)
        setNeedsDisplay();
    }
    
    public func removeMethod(name: String, index: Int) {
        self.methods.remove(at: index)
        setNeedsDisplay();
    }
    
    public func addAttribute(name: String) {
        self.attributes.append(name)
        setNeedsDisplay();
    }
    
    public func removeAttribute(name: String, index: Int) {
        self.attributes.remove(at: index)
        setNeedsDisplay();
    }
    
    override func draw(_ rect: CGRect) {        
        let outerRect = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height).insetBy(dx: 5, dy: 5);
        let nameRect = CGRect(x: 0, y: 0, width: self.frame.width, height: 50).insetBy(dx: 5, dy: 5);
        let separatorY: CGFloat = CGFloat(60 + 16 * (self.attributes.count))

        let nameSeparation = UIBezierPath()
        nameSeparation.move(to: CGPoint(x: 5, y: 40))
        nameSeparation.addLine(to: CGPoint(x: self.frame.width - 5, y: 40))
        
        let attributeSeparation = UIBezierPath()
        attributeSeparation.move(to: CGPoint(x: 5, y: separatorY))
        attributeSeparation.addLine(to: CGPoint(x: self.frame.width - 5, y: separatorY))
        
        let outerRectPath = UIBezierPath(rect: outerRect)
        let nameRectPath = UIBezierPath(rect: nameRect)
        
        self.figureColor.setFill()
        self.lineColor.setStroke()
        if (self.isBorderDashed) {
            outerRectPath.setLineDash([4,4], count: 1, phase: 0)
            nameRectPath.setLineDash([4,4], count: 1, phase: 0)
            nameSeparation.setLineDash([4,4], count: 1, phase: 0)
            attributeSeparation.setLineDash([4,4], count: 1, phase: 0)
        }
        
        attributeSeparation.lineWidth = self.lineWidth
        nameSeparation.lineWidth = self.lineWidth
        outerRectPath.lineWidth = self.lineWidth
        outerRectPath.fill()
        outerRectPath.stroke()
        nameSeparation.stroke()
        attributeSeparation.stroke()

        let nameLabel = UILabel(frame: nameRect)
        nameLabel.text = self.name
        nameLabel.textAlignment = .center
        nameLabel.drawText(in: nameRect)
        
        for n in 0..<self.attributes.count {
            let methodRect = CGRect(x: 0, y: CGFloat(50 + (16 * n)), width: self.frame.width, height: 16).insetBy(dx: 5, dy: 5);
            let methodLabel = UILabel(frame: methodRect)
            methodLabel.text = "  • " + self.attributes[n]
            methodLabel.textAlignment = .left
            methodLabel.drawText(in: methodRect)
        }
        
        for n in 0..<self.methods.count {
            let attributesRect = CGRect(x: 0, y: CGFloat(Int(separatorY + 10) + (16 * n)), width: self.frame.width, height: 16).insetBy(dx: 5, dy: 5);
            let attributeLabel = UILabel(frame: attributesRect)
            attributeLabel.text = "  • " + self.methods[n]
            attributeLabel.textAlignment = .left
            attributeLabel.drawText(in: attributesRect)
        }
    }
    
    override func exportViewModel() -> DrawViewModel {
        let point1 = PolyPaintStylusPoint(X: Double(self.firstPoint.x), Y: Double(self.firstPoint.y), PressureFactor: 1)
        let point2 = PolyPaintStylusPoint(X: Double(self.lastPoint.x), Y: Double(self.lastPoint.y), PressureFactor: 1)

        var drawViewModel: DrawViewModel = DrawViewModel()
        drawViewModel.Guid = self.uuid.uuidString.lowercased()
        drawViewModel.Owner = UserDefaults.standard.string(forKey: "username")
        drawViewModel.ItemType = ItemTypeEnum.UmlClass
        drawViewModel.StylusPoints = [point1, point2]
        drawViewModel.FillColor = PolyPaintColor(color: self.figureColor)
        drawViewModel.BorderColor = PolyPaintColor(color: self.lineColor)
        drawViewModel.BorderThickness = Double(self.lineWidth)
        drawViewModel.BorderStyle = (self.isBorderDashed) ? "dash" : "solid"
        drawViewModel.ShapeTitle = self.name
        drawViewModel.Methods = self.methods
        drawViewModel.Properties = self.attributes
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
