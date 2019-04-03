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
    
    init (coder aDecoder: NSCoder!) {
        self.canvasId = aDecoder.decodeObject(forKey: "canvasId") as! String
        self.name = aDecoder.decodeObject(forKey: "name") as! String
        self.drawViewModels = aDecoder.decodeObject(forKey: "drawViewModels") as! String
        self.image = aDecoder.decodeObject(forKey: "image") as! String
        self.canvasVisibility = aDecoder.decodeObject(forKey: "canvasVisibility") as! String
        self.canvasAutor = aDecoder.decodeObject(forKey: "canvasAutor") as! String
        self.canvasProtection = aDecoder.decodeObject(forKey: "canvasProtection") as! String

    }
    func encodeWithCoder(aCoder: NSCoder!) {
        aCoder.encode(canvasId, forKey:"canvasId")
        aCoder.encode(name, forKey:"name")
        aCoder.encode(drawViewModels, forKey:"drawViewModels")
        aCoder.encode(image, forKey:"image")
        aCoder.encode(canvasVisibility, forKey: "canvasVisibility")
        aCoder.encode(canvasAutor, forKey: "canvasAutor")
        aCoder.encode(canvasProtection, forKey: "canvasProtection")
    }
}
