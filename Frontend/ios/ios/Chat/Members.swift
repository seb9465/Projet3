//
//  File.swift
//  ios
//
//  Created by Sebastien Cadorette on 2019-02-09.
//  Copyright © 2019 LOG3000 equipe 12. All rights reserved.
//

import Foundation
import UIKit

class Member {
    private let _name: String;
    private let _color: UIColor;
    
    var name: String {
        get { return _name }
    }
    var color: UIColor {
        get { return _color }
    }
    
    init(name: String, color: UIColor) {
        self._name = name;
        self._color = color;
    }
}
