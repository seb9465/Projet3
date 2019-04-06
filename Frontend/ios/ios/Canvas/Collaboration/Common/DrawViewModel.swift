//
//  DrawViewModel.swift
//  ios
//
//  Created by William Sevigny on 2019-03-06.
//  Copyright © 2019 LOG3000 equipe 12. All rights reserved.
//
import UIKit
struct DrawViewModel: Codable {
    var Guid: String?
    var Owner: String?
    var ItemType: ItemTypeEnum?
    var StylusPoints: [PolyPaintStylusPoint]?
    var FillColor: PolyPaintColor?
    var BorderColor: PolyPaintColor?
    var BorderThickness: Double?
    var BorderStyle: String?
    var ShapeTitle: String?
    var Methods: [String]?
    var Properties: [String]?
    var SourceTitle: String?
    var DestinationTitle: String?
    var ChannelId: String?
    var OutilSelectionne: String?
    var LastElbowPosition: PolyPaintStylusPoint?
    var ImageBytes: [UInt8]?
    var Rotation: Double?

    init() {}
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
    case Line
    
    var description: String {
        switch self {
        case .Activity:
            return "Activity"
        case .Artefact:
            return "Artefact"
        case .Phase:
            return "Phase"
        case .Comment:
            return "Comment"
        case .Role:
            return "Role"
        case .UmlClass:
            return "Class"
        case .Text:
            return "Text"
        case .Agregation:
            return "Connection"
        case .BidirectionalAssociation:
            return "Connection"
        case .Composition:
            return "Connection"
        case .Inheritance:
            return "Connection"
        case .UniderectionalAssoication:
            return "Connection"
        case .Image:
            return "Image"
        case .Line:
            return "Connection"
        }
    }
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
    
    init(point: CGPoint) {
        self.X = Double(point.x)
        self.Y = Double(point.y)
        self.PressureFactor = 1
    }
    
    func getCGPoint() -> CGPoint {
        return CGPoint(x: self.X, y: self.Y)
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
    
    init(color: UIColor)  {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        self.A = alpha <= 1 ? Int(alpha * 255): Int(alpha)
        self.R = red <= 1 ? Int(red * 255): Int(red)
        self.G = green <= 1 ? Int(green * 255): Int(green)
        self.B = blue <= 1 ? Int(blue * 255): Int(blue)
    }
    
    func getUIColor() -> UIColor {
        print(A, R, G, B)
        return UIColor(red: CGFloat(self.R), green: CGFloat(self.G), blue: CGFloat(self.B), alpha: CGFloat(self.A))
    }
}
