//
//  Canvas.swift
//  ios
//
//  Created by William Sevigny on 2019-02-18.
//  Copyright © 2019 LOG3000 equipe 12. All rights reserved.
//
import Foundation

struct Canvas: Codable  {
    var canvasId: String
    var name: String
    var drawViewModels: String
    var image: String
    var canvasVisibility: String
    var canvasAutor: String
    var canvasProtection: String
    var canvasWidth: Float
    var canvasHeight: Float
    init() {
        self.canvasId = "";
        self.name = "";
        self.drawViewModels = "[]";
        self.image = Base64Const.defaultPic;
        self.canvasVisibility = "";
        self.canvasAutor = "";
        self.canvasProtection = "";
        self.canvasWidth = 705
        self.canvasHeight = 620
    }

    init(canvasId: String, name: String, drawViewModels: String, image: String, canvasVisibility: String, canvasAutor: String, canvasProtection: String, canvasWidth: Float, canvasHeight: Float) {
        self.canvasId = canvasId;
        self.name = name;
        self.drawViewModels = drawViewModels;
        self.image = image;
        self.canvasVisibility = canvasVisibility;
        self.canvasAutor = canvasAutor;
        self.canvasProtection = canvasProtection;
        self.canvasHeight = canvasHeight
        self.canvasWidth = canvasWidth
    }
}
