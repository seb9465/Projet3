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
    
    public func exportToViewModel() -> DrawViewModel {
        let point1 = PolyPaintStylusPoint(X: Double(self.firstPoint.x), Y: Double(self.firstPoint.y), PressureFactor: 1)
        let point2 = PolyPaintStylusPoint(X: Double(self.lastPoint.x), Y: Double(self.lastPoint.y), PressureFactor: 1)
        let color: PolyPaintColor = PolyPaintColor(A: 255, R: 255, G: 1, B: 1)
        
        return DrawViewModel(
            ItemType: ItemTypeEnum.RoundedRectangleStroke,
            StylusPoints: [point1, point2],
            OutilSelectionne: "rounded_rectangle",
            Color: color,
            ChannelId: "general"
        )
    }
}
