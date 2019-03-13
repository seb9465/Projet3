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
    static let BASE_WIDTH: CGFloat = 100
    static let BASE_HEIGHT: CGFloat = 100
    private var figureType: UMLImageFigureType
    
    init(origin: CGPoint, figureType: UMLImageFigureType) {
        self.figureType = figureType
            super.init(touchedPoint: origin, width: UmlImageFigure.BASE_WIDTH, height: UmlImageFigure.BASE_HEIGHT)
        }
        
        init(firstPoint: CGPoint, lastPoint: CGPoint, figureType: UMLImageFigureType) {
            self.figureType = figureType
            super.init(firstPoint: firstPoint, lastPoint: lastPoint, width: UmlImageFigure.BASE_WIDTH, height: UmlImageFigure.BASE_WIDTH)
        }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func getImagePathFromImageType(figureType: UMLImageFigureType) -> String {
        let attributes = figureType.rawValue.split(separator: ".")
        return Bundle.main.path(forResource: String(attributes[0]), ofType: String(attributes[1]), inDirectory: "Ressources")!

    }
    
    override func draw(_ rect: CGRect) {
        let imagePath = getImagePathFromImageType(figureType: self.figureType)
        let image = UIImage(contentsOfFile: imagePath)
        guard let context = UIGraphicsGetCurrentContext() else {return}
        context.rotate(by: CGFloat(deg2rad(180)))
        context.clear(rect);
        context.draw((image?.cgImage)!, in: rect, byTiling: true)
    }
    
    func deg2rad(_ number: Double) -> Double {
        return number * .pi / 180
    }
}
enum UMLImageFigureType: String {
    case actor = "actor.png"
}
