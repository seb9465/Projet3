//
//  FigureProtocol.swift
//  ios
//
//  Created by William Sevigny on 2019-03-10.
//  Copyright © 2019 LOG3000 equipe 12. All rights reserved.
//
import UIKit

protocol FigureProtocol {
    var firstPoint: CGPoint { get set }
    var lastPoint: CGPoint { get set }
    var figureColor: UIColor { get set }
    var lineWidth: CGFloat { get set }
    var lineColor: UIColor { get set }
    
    func draw()
    func setInitialPoint(initialPoint: CGPoint)
    func setLastPoint(lastPoint: CGPoint)
}
