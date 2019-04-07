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
        self.image = UIImage(data: Data(base64Encoded: drawViewModel.ImageBytes!)!)!
        self.initializeAnchorPoints()
    }
    
    override func draw(_ rect: CGRect) {
        print(image)
        self.image?.draw(in: self.frame)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
