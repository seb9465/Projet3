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
    let BASE_WIDTH: CGFloat = 150
    let BASE_HEIGHT: CGFloat = 200
    var image: UIImage?
    var imageBytes: String?

    override init(drawViewModel: DrawViewModel) {
        super.init(drawViewModel: drawViewModel);
        self.imageBytes = drawViewModel.ImageBytes!
        self.image = UIImage(data: Data(base64Encoded: drawViewModel.ImageBytes!)!)!
        self.initializeAnchorPoints()
    }
    
    override func draw(_ rect: CGRect) {
        self.image?.draw(in: self.frame)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
