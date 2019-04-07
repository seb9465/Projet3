//
//  SidebarDelegate.swift
//  ios
//
//  Created by William Sevigny on 2019-03-15.
//  Copyright © 2019 LOG3000 equipe 12. All rights reserved.
//

import UIKit

protocol SideToolbarDelegate {
    func setSelectedFigureBorderColor(color: UIColor)
    func setSelectedFigureFillColor(color: UIColor)
    func setSelectedFigureBorderStyle(isDashed: Bool)
    func setSelectedFigureLineWidth(width: CGFloat)
    func setSelectedFigureName(name: String)
    func setSelectedFigureNameDidEnd()
    func setSelectedFigureSourceLabel(name: String)
    func setSelectedFigureDestinationLabel(name: String)
    func addClassMethod(name: String)
    func removeClassMethod(name: String, index: Int)
    func addClassAttribute(name: String)
    func removeClassAttribute(name: String, index: Int)
    func rotate(orientation: RotateOrientation)
}
