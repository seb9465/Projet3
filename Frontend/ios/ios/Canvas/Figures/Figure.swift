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
    var name: String = "name"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.uuid = UUID()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func setFigureName(name: String) {
        self.name = name
        setNeedsDisplay()
    }
    
    public func exportViewModel() -> DrawViewModel? {return nil}

    public func rotate(orientation: RotateOrientation) -> Void {}
}
