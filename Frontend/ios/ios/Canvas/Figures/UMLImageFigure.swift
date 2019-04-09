//
//  ImageFigure.swift
//  ios
//
//  Created by Sébastien Labine on 19-03-12.
//  Copyright © 2019 LOG3000 equipe 12. All rights reserved.
//

import Foundation
import CoreGraphics
import UIKit
class UmlImageFigure: UmlFigure {
    var image: UIImage?
    var imageBytes: String?
    var imageView: UIImageView?
    override init(drawViewModel: DrawViewModel) {
        super.init(drawViewModel: drawViewModel);
        self.imageBytes = drawViewModel.ImageBytes!

        self.contentMode = UIView.ContentMode.scaleAspectFit
        self.image = UIImage(data: Data(base64Encoded: self.imageBytes!)!)
        self.imageView = UIImageView(image: self.image)
        self.imageView!.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
        self.addSubview(imageView!)
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
        self.imageView!.frame = CGRect(x: 0, y: 0, width: width, height: height)
    }
    override func resize(by: CGPoint, figures: [Figure]) {
        super.resize(by: by, figures: figures)
        self.imageView!.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
        setNeedsDisplay()
    }
    
    override func exportViewModel() -> DrawViewModel {
        let point1 = PolyPaintStylusPoint(X: Double(self.firstPoint.x), Y: Double(self.firstPoint.y), PressureFactor: 1)
        let point2 = PolyPaintStylusPoint(X: Double(self.lastPoint.x), Y: Double(self.lastPoint.y), PressureFactor: 1)
        
        var drawViewModel: DrawViewModel = DrawViewModel()
        drawViewModel.Guid = self.uuid.uuidString.lowercased()
        drawViewModel.Owner = UserDefaults.standard.string(forKey: "username")
        drawViewModel.ItemType = ItemTypeEnum.Image
        drawViewModel.StylusPoints = [point1, point2]
        drawViewModel.FillColor = PolyPaintColor(color: self.figureColor)
        drawViewModel.BorderColor = PolyPaintColor(color: self.lineColor)
        drawViewModel.BorderThickness = Double(self.lineWidth)
        drawViewModel.BorderStyle = (self.isBorderDashed) ? "dash" : "solid"
        drawViewModel.ShapeTitle = self.name
        drawViewModel.Methods = []
        drawViewModel.Properties = []
        drawViewModel.SourceTitle = nil
        drawViewModel.DestinationTitle = nil
        drawViewModel.ChannelId = canvasId
        drawViewModel.OutilSelectionne = nil
        drawViewModel.LastElbowPosition = nil
        drawViewModel.ImageBytes = self.imageBytes
        drawViewModel.Rotation = self.currentAngle
        drawViewModel.InConnections = self.serializeIncomingConnections()
        drawViewModel.OutConnections = self.serializeOutgoingConnections()
        return drawViewModel
    }
    
}
