//
//  ProtectionMessage.swift
//  ios
//
//  Created by Sébastien Labine on 19-04-06.
//  Copyright © 2019 LOG3000 equipe 12. All rights reserved.
//

struct SizeMessage: Codable {
    var Size: PolyPaintStylusPoint
    
    init(Size: PolyPaintStylusPoint) {
        self.Size = Size;
    }
}
