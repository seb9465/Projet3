//
//  DemoView.swift
//  ios
//
//  Created by Sebastien Cadorette on 2019-02-19.
//  Copyright © 2019 LOG3000 equipe 12. All rights reserved.
//

import UIKit

class CanvasService: UIView {
    
    init(origin: CGPoint) {
        super.init(frame: CGRect(x: 100, y: 100, width: 100, height: 100));
        self.center = origin;
        // Background color du frame.
        self.backgroundColor = UIColor.clear;
    }
    
    override init(frame: CGRect) {
        super.init(frame: CGRect(x: 100, y: 100, width: 100, height: 100));
        // Background color du frame.
        self.backgroundColor = UIColor.clear;
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func draw(_ rect: CGRect) {
        
//        let insetRect = CGRect(x: 100, y: 100, width: 100, height: 100)

        let path = UIBezierPath(roundedRect: rect, cornerRadius: 10);
        
        UIColor.red.setFill()
        path.fill();
    }
}
