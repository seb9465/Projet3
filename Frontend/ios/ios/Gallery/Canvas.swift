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
    let base64Strokes: String
    let base64Image: String
    
    init(canvasId: String, name: String, base64Strokes: String, base64Image: String) {
        self.canvasId = canvasId;
        self.name = name;
        self.base64Strokes = base64Strokes;
        self.base64Image = base64Image;
    }
    
    init (coder aDecoder: NSCoder!) {
        self.canvasId = aDecoder.decodeObject(forKey: "canvasId") as! String
        self.name = aDecoder.decodeObject(forKey: "name") as! String
        self.base64Strokes = aDecoder.decodeObject(forKey: "base64Strokes") as! String
        self.base64Image = aDecoder.decodeObject(forKey: "base64Image") as! String
        
    }
    func encodeWithCoder(aCoder: NSCoder!) {
        aCoder.encode(canvasId, forKey:"canvasId")
        aCoder.encode(name, forKey:"name")
        aCoder.encode(base64Strokes, forKey:"base64Strokes")
        aCoder.encode(base64Image, forKey:"base64Image")
    }
}
