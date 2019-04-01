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
        self.uuid = UUID.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func exportToViewModel() -> DrawViewModel {
        let point1 = PolyPaintStylusPoint(X: Double(self.firstPoint.x), Y: Double(self.firstPoint.y), PressureFactor: 1)
        let point2 = PolyPaintStylusPoint(X: Double(self.lastPoint.x), Y: Double(self.lastPoint.y), PressureFactor: 1)
        let color: PolyPaintColor = PolyPaintColor(A: 255, R: 255, G: 1, B: 1)
    
        var viewModel: DrawViewModel = DrawViewModel()
        viewModel.Guid = self.uuid
        viewModel.owner = UserDefaults.standard.string(forKey: "username")
        viewModel.ItemType = self.itemType
        viewModel.StylusPoints = [point1, point2]
    }
    
    public func rotate(orientation: RotateOrientation) -> Void {}
}
