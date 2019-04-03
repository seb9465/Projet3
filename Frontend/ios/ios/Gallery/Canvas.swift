//
//  Canvas.swift
//  ios
//
//  Created by William Sevigny on 2019-02-18.
//  Copyright © 2019 LOG3000 equipe 12. All rights reserved.
//
import Foundation

struct Canvas: Codable  {
    let canvasId: String
    let name: String
    let drawViewModels: String
    let image: String
    let canvasVisibility: String
    let canvasAutor: String
    let canvasProtection: String
    init(canvasId: String, name: String, drawViewModels: String, image: String, canvasVisibility: String, canvasAutor: String, canvasProtection: String) {
        self.canvasId = canvasId;
        self.name = name;
        self.drawViewModels = drawViewModels;
        self.image = image;
        self.canvasVisibility = canvasVisibility;
        self.canvasAutor = canvasAutor;
        self.canvasProtection = canvasProtection;
    }
}
