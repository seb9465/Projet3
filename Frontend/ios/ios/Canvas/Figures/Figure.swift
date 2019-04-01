//
//  Figure.swift
//  ios
//
//  Created by William Sevigny on 2019-03-13.
//  Copyright © 2019 LOG3000 equipe 12. All rights reserved.
//
import UIKit

class Figure: UIView {
    
    var firstPoint: CGPoint!
    var lastPoint: CGPoint!
    var itemType: ItemTypeEnum!
    var uuid: UUID!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.uuid = UUID()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func exportViewModel() -> DrawViewModel {
        let point1 = PolyPaintStylusPoint(X: Double(self.firstPoint.x), Y: Double(self.firstPoint.y), PressureFactor: 1)
        let point2 = PolyPaintStylusPoint(X: Double(self.lastPoint.x), Y: Double(self.lastPoint.y), PressureFactor: 1)
    
        var drawViewModel: DrawViewModel = DrawViewModel()
        drawViewModel.Guid = self.uuid.uuidString
        drawViewModel.owner = UserDefaults.standard.string(forKey: "username")
        drawViewModel.ItemType = self.itemType
        drawViewModel.StylusPoints = [point1, point2]
        drawViewModel.FillColor = PolyPaintColor(A: 255, R: 255, G: 1, B: 1)
        drawViewModel.BorderColor = PolyPaintColor(A: 255, R: 255, G: 1, B: 1)
        drawViewModel.BorderThickness = 2.0
        drawViewModel.BorderStyle = "solid"
        drawViewModel.ShapeTitle = "shapeTitle"
        drawViewModel.Methods = []
        drawViewModel.Properties = []
        drawViewModel.SourceTitle = "source"
        drawViewModel.DestinationTitle = "destination"
        drawViewModel.ChannelId = "general"
        drawViewModel.OutilSelectionne = "jai_chier_dans_le_plat_du_jour"
        drawViewModel.LastElbowPosition = point1
        drawViewModel.ImageBytes = [UInt8(exactly: 0.0)!]
        drawViewModel.Rotation = 0.0
        
        return drawViewModel
    }
    
    public func rotate(orientation: RotateOrientation) -> Void {}
}
