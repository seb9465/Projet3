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
    var anchorPointsTop: CAShapeLayer!;
    var anchorPointsLeft: CAShapeLayer!;
    var anchorPointsRight: CAShapeLayer!;
    var anchorPointsBottom: CAShapeLayer!;

    init(firstPoint: CGPoint, lastPoint: CGPoint) {
        let width = abs(firstPoint.x - lastPoint.x)
        let height = abs(firstPoint.y - lastPoint.y)
        
        anchorPointsTop = CAShapeLayer();
        anchorPointsTop.path = UIBezierPath(ovalIn: CGRect(x: width/2, y: 0, width: 10,height:10)).cgPath
        anchorPointsTop.fillColor = UIColor.red.cgColor
        
        anchorPointsRight = CAShapeLayer();
        anchorPointsRight.path = UIBezierPath(ovalIn: CGRect(x: width, y: height/2, width: 10,height:10)).cgPath
        anchorPointsRight.fillColor = UIColor.red.cgColor
        
        anchorPointsLeft = CAShapeLayer();
        anchorPointsLeft.path = UIBezierPath(ovalIn: CGRect(x: 0, y: height/2, width: 10,height:10)).cgPath
        anchorPointsLeft.fillColor = UIColor.red.cgColor
        
        anchorPointsBottom = CAShapeLayer();
        anchorPointsBottom.path = UIBezierPath(ovalIn: CGRect(x: width/2, y: height, width: 10,height:10)).cgPath
        anchorPointsBottom.fillColor = UIColor.red.cgColor

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
