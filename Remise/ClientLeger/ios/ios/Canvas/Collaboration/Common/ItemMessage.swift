//
//  DrawViewModel.swift
//  ios
//
//  Created by William Sevigny on 2019-03-06.
//  Copyright © 2019 LOG3000 equipe 12. All rights reserved.
//
import Foundation

struct ItemMessage: Codable {
    var CanvasId: String
    var Username: String
    var Items : [DrawViewModel]

    init(CanvasId: String, Username: String, Items: [DrawViewModel]) {
        self.CanvasId = CanvasId;
        self.Username = Username;
        self.Items = Items;
    }
}
