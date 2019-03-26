//
//  SelectionLasso.swift
//  ios
//
//  Created by Sebastien Cadorette on 2019-03-26.
//  Copyright © 2019 LOG3000 equipe 12. All rights reserved.
//

import Foundation
import UIKit

class SelectionLasso: UIView {
    private let radius: CGFloat = 5.0;
    
    private var firstPoint: CGPoint;
    private var lastPoint: CGPoint;
    private var shape: CAShapeLayer;
    private var shapePath: UIBezierPath;
    
    init(size: CGSize, touchPoint: CGPoint) {
        self.firstPoint = touchPoint;
        self.lastPoint = self.firstPoint;
        self.shape = CAShapeLayer();
        self.shapePath = UIBezierPath();
        self.shapePath.move(to: CGPoint(x: 0, y: 0));
        self.shape.fillColor = nil;
        self.shape.lineWidth = 4;
        self.shape.position = self.firstPoint;
        self.shape.strokeColor = UIColor.black.cgColor;
        self.shape.lineDashPattern = [4, 4];
        
        let frame: CGRect = CGRect(origin: CGPoint(x: 0, y: 0), size: size);
        super.init(frame: frame);
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented");
    }
    
    public func addNewTouchPoint(touchPoint: CGPoint) -> Void {
        self.shape.removeFromSuperlayer();
        
        self.shapePath.addLine(to: CGPoint(
            x: touchPoint.x - self.firstPoint.x,
            y: touchPoint.y - self.firstPoint.y
        ));
        
        self.shape.path = self.shapePath.cgPath;
        
        self.layer.addSublayer(self.shape);
        
        self.lastPoint = touchPoint;
    }
}
