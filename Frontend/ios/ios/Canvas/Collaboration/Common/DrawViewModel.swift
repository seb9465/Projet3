//
//  DrawViewModel.swift
//  ios
//
//  Created by William Sevigny on 2019-03-06.
//  Copyright © 2019 LOG3000 equipe 12. All rights reserved.
//

struct DrawViewModel: Codable {
    var Guid: String
    var owner: String
    var ItemType: ItemTypeEnum
    var StylusPoints: [PolyPaintStylusPoint]
    var Color: PolyPaintColor
    var BorderThickness: Double
    var BorderStyle: String
    var ShapeTitle: String
    var Methods: [String]
    var Properties: [String]
    var SourceTitle: String
    var DestinationTitle: String
    var ChannelId: String
    var OutilSelectionne: String
    var LastElbowPosition: PolyPaintStylusPoint
    var ImageBytes: [UInt8]

    init(ItemType: ItemTypeEnum, StylusPoints: [PolyPaintStylusPoint], OutilSelectionne: String, Color: PolyPaintColor, ChannelId: String) {
        self.ItemType = ItemType
        self.StylusPoints = StylusPoints
        self.OutilSelectionne = OutilSelectionne
        self.Color = Color
        self.ChannelId = ChannelId
    }
}

enum ItemTypeEnum: Int, Codable {
    case Activity
    case Artefact
    case Phase
    case Comment
    case Role
    case UmlClass
    case Text
    case Agregation
    case BidirectionalAssociation
    case Composition
    case Inheritance
    case UniderectionalAssoication
    case Image
}

struct PolyPaintStylusPoint: Codable {
    var X: Double
    var Y: Double
    var PressureFactor: Float
    
    init(X: Double, Y: Double, PressureFactor: Float) {
        self.X = X
        self.Y = Y
        self.PressureFactor = PressureFactor
    }
}

struct PolyPaintColor: Codable {
    var A: Int
    var R: Int
    var G: Int
    var B: Int
    
    init(A: Int, R: Int, G: Int, B:Int) {
        self.A = A
        self.R = R
        self.G = G
        self.B = B
    }
}
