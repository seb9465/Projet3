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
    
    override init(drawViewModel: DrawViewModel) {
        super.init(drawViewModel: drawViewModel);
        self.image = UIImage(data: Data(bytes: drawViewModel.ImageBytes!))!
        self.initializeAnchorPoints()
    }
    
    override func draw(_ rect: CGRect) {
        let imageLayer = CALayer()
        imageLayer.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
        imageLayer.contents = self.image
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
