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
    var border: CAShapeLayer!;
    
    init() {
        let frame: CGRect = CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: 100, height: 100));
        super.init(frame: frame);
        
        self.setInitialSelectedDashedBorder();
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func setInitialSelectedDashedBorder() -> Void {
        border = CAShapeLayer();
        border.strokeColor = UIColor.black.cgColor;
        border.lineDashPattern = [4, 4];
        border.frame = bounds;
        border.fillColor = nil;
        border.path = UIBezierPath(rect: self.bounds).cgPath;
    }
    
    public func addSelectedFigureLayers() -> Void {
        self.layer.addSublayer(border);
    }
    
    public func removeSelectedFigureLayers() -> Void {
        self.border.removeFromSuperlayer();
    }
}
