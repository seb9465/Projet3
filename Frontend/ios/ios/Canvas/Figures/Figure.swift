//
//  Figure.swift
//  ios
//
//  Created by William Sevigny on 2019-03-13.
//  Copyright © 2019 LOG3000 equipe 12. All rights reserved.
//
import UIKit

class Figure: UIView {
    var delegate: TouchInputDelegate?
    
    var firstPoint: CGPoint!
    var lastPoint: CGPoint!
    var itemType: ItemTypeEnum!
    var uuid: UUID!
    var name: String = "name"
    var isBorderDashed: Bool = false
    var figureColor: UIColor! = UIColor.clear
    var lineColor: UIColor! = UIColor.black
    var lineWidth: CGFloat! = 2
    var sourceName: String! = ""
    var destinationName: String! = ""

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.uuid = UUID()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func translate(by: CGPoint, figures: [Figure]) {}
    
    public func setFigureName(name: String) {
        self.name = name
        setNeedsDisplay()
    }
    
    public func setBorderColor(borderColor: UIColor) -> Void {
        self.lineColor = borderColor
        setNeedsDisplay();
    }
    
    public func setFillColor(fillColor: UIColor) -> Void {
        self.figureColor = fillColor
        setNeedsDisplay();
    }
    
    public func setIsBorderDashed(isDashed: Bool) {
        self.isBorderDashed = isDashed
        setNeedsDisplay()
    }
    
    public func setLineWidth(width: CGFloat) {
        self.lineWidth = width
        setNeedsDisplay()
    }
    
    public func getSelectionFrame() -> CGRect {
        return self.frame
    }
    
    public func exportViewModel() -> DrawViewModel? {return nil}

    public func rotate(orientation: RotateOrientation, figures: [Figure]) -> Void {}
    
    public func resize(by: CGPoint, figures: [Figure]) -> Void {}
}
