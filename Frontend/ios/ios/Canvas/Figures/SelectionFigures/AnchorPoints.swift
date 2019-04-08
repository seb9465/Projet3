//
//  AnchorPoints.swift
//  ios
//
//  Created by Sébastien Labine on 19-03-12.
//  Copyright © 2019 LOG3000 equipe 12. All rights reserved.
//

import Foundation
import UIKit
import CoreGraphics
protocol AnchorPointsProtocol{
    var anchorPointsTop: CAShapeLayer! { get set }
    var anchorPointsLeft: CAShapeLayer! { get set }
    var anchorPointsRight: CAShapeLayer! { get set }
    var anchorPointsBottom: CAShapeLayer! { get set }
}

class AnchorPoints {
    
    var anchorDiameter: CGFloat = 4
    var anchorRadius: CGFloat = 2
    
    var anchorPointsTop: CAShapeLayer!;
    var anchorPointsLeft: CAShapeLayer!;
    var anchorPointsRight: CAShapeLayer!;
    var anchorPointsBottom: CAShapeLayer!;
    var anchorPointsSnapEdges: [String: CGPoint] = [:]

    init(width: CGFloat, height: CGFloat) {
        anchorPointsTop = CAShapeLayer();
        anchorPointsTop.path = UIBezierPath(ovalIn: CGRect(
            x: width/2 - self.anchorRadius,
            y: 0,
            width: self.anchorDiameter,
            height: self.anchorDiameter
        )).cgPath
        

        anchorPointsRight = CAShapeLayer();
        anchorPointsRight.path = UIBezierPath(ovalIn: CGRect(
            x: width - self.anchorDiameter,
            y: height/2 - self.anchorRadius,
            width: self.anchorDiameter,
            height: self.anchorDiameter
        )).cgPath
        
        anchorPointsLeft = CAShapeLayer();
        anchorPointsLeft.path = UIBezierPath(ovalIn: CGRect(
            x: 0,
            y: height/2 - self.anchorRadius,
            width: self.anchorDiameter,
            height: self.anchorDiameter
        )).cgPath
        
        anchorPointsBottom = CAShapeLayer();
        anchorPointsBottom.path = UIBezierPath(ovalIn: CGRect(
            x: width/2 - self.anchorRadius,
            y: height - self.anchorDiameter,
            width: self.anchorDiameter,
            height: self.anchorDiameter
        )).cgPath
        
        anchorPointsTop.name = "top"
        anchorPointsRight.name = "right"
        anchorPointsLeft.name = "left"
        anchorPointsBottom.name = "bottom"
        
        self.anchorPointsSnapEdges.updateValue(CGPoint(x: width/2, y: 0), forKey: "top")
        self.anchorPointsSnapEdges.updateValue(CGPoint(x: width, y: height/2), forKey: "right")
        self.anchorPointsSnapEdges.updateValue(CGPoint(x: 0, y: height/2), forKey: "left")
        self.anchorPointsSnapEdges.updateValue(CGPoint(x: width/2, y: height), forKey: "bottom")
        
//        anchorPointsTop.fillColor = UIColor.gray.cgColor
//        anchorPointsRight.fillColor = UIColor.gray.cgColor
//        anchorPointsLeft.fillColor = UIColor.gray.cgColor
//        anchorPointsBottom.fillColor = UIColor.gray.cgColor
        
        anchorPointsTop.fillColor = UIColor.clear.cgColor
        anchorPointsRight.fillColor = UIColor.clear.cgColor
        anchorPointsLeft.fillColor = UIColor.clear.cgColor
        anchorPointsBottom.fillColor = UIColor.clear.cgColor
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
