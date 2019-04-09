//
//  FigureCellProtocol.swift
//  ios
//
//  Created by Sébastien Labine on 19-03-19.
//  Copyright © 2019 LOG3000 equipe 12. All rights reserved.
//

import UIKit

protocol FigureCellProtocol: class {
    func setSelectedFigureType(itemType: ItemTypeEnum, isConnection: Bool) -> Void
    func presentImagePicker() -> Void
}
