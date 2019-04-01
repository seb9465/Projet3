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
    
    public var className: String = "ClassName"
    public var methods: [String] = []
    public var attributes: [String] = []
    
    init(origin: CGPoint) {
        super.init(touchedPoint: origin, width: BASE_WIDTH, height: BASE_HEIGHT)
        self.figureID = Constants.figureIDCounter;
        Constants.figureIDCounter += 1;
    }
    
    init(firstPoint: CGPoint, lastPoint: CGPoint) {
        super.init(firstPoint: firstPoint, lastPoint: lastPoint, width: BASE_WIDTH, height: BASE_WIDTH)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func setClassName(name: String) -> Void {
        self.className = name;
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
        let outerRect = CGRect(x: 0, y: 0, width: BASE_WIDTH, height: BASE_HEIGHT).insetBy(dx: 5, dy: 5);
        let nameRect = CGRect(x: 0, y: 0, width: BASE_WIDTH, height: 50).insetBy(dx: 5, dy: 5);
        let splitterRect = CGRect(x: 0, y: 0, width: BASE_WIDTH, height: 125).insetBy(dx: 5, dy: 5);
        
        let nameLabel = UILabel(frame: nameRect)
        nameLabel.text = self.className
        nameLabel.textAlignment = .center
        nameLabel.drawText(in: nameRect)
        
        
        for n in 0..<self.methods.count {
            let methodRect = CGRect(x: 0, y: CGFloat(50 + (16 * n)), width: self.frame.width, height: 16).insetBy(dx: 5, dy: 5);
            let methodLabel = UILabel(frame: methodRect)
            methodLabel.text = "  • " + self.methods[n]
            methodLabel.textAlignment = .left
            methodLabel.drawText(in: methodRect)
        }
        
        for n in 0..<self.attributes.count {
            let attributesRect = CGRect(x: 0, y: CGFloat(125 + (16 * n)), width: self.frame.width, height: 16).insetBy(dx: 5, dy: 5);
            let attributeLabel = UILabel(frame: attributesRect)
            attributeLabel.text = "  • " + self.attributes[n]
            attributeLabel.textAlignment = .left
            attributeLabel.drawText(in: attributesRect)
        }

        let outerRectPath = UIBezierPath(rect: outerRect)
        let nameRectPath = UIBezierPath(rect: nameRect)
        let splitterRectPath = UIBezierPath(rect: splitterRect)
        
        self.figureColor.setFill()
        self.lineColor.setStroke()
        
        splitterRectPath.lineWidth = self.lineWidth
        splitterRectPath.fill()
        splitterRectPath.stroke()
        
        nameRectPath.lineWidth = self.lineWidth
        nameRectPath.fill()
        nameRectPath.stroke()
        
        outerRectPath.lineWidth = self.lineWidth
        outerRectPath.fill()
        outerRectPath.stroke()
    }
    
//    override func exportToViewModel(itemType: ItemTypeEnum) -> DrawViewModel {
//        return DrawViewModel(
//             Guid: self.uuid,
//             owner: String,
//             ItemType: ItemTypeEnum,
//             StylusPoints: [PolyPaintStylusPoint],
//             Color: PolyPaintColor,
//             BorderThickness: Double,
//             BorderStyle: String,
//             ShapeTitle: String,
//             Methods: [String],
//             Properties: [String],
//             SourceTitle: String,
//             DestinationTitle: String,
//             ChannelId: String,
//             OutilSelectionne: String,
//             LastElbowPosition: PolyPaintStylusPoint,
//             ImageBytes: [UInt8],
//        )
//    }
}
