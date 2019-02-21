//
//  DemoView.swift
//  ios
//
//  Created by Sebastien Cadorette on 2019-02-19.
//  Copyright © 2019 LOG3000 equipe 12. All rights reserved.
//

import UIKit
import PromiseKit
import Alamofire

class CanvasService: UIView {
    private var firstPoint: CGPoint = CGPoint(x: 0, y: 0);
    private var lastPoint: CGPoint = CGPoint(x: 100, y: 100);
    
    public var isSelected: Bool = false;
    private var isDragging: Bool = false;
    
    private var currentPoint: CGPoint?
    private var previousPoint1: CGPoint?
    private var previousPoint2: CGPoint?
    
    init(origin: CGPoint) {
        super.init(frame: CGRect(x: origin.x - 50, y: origin.y - 50, width: 100, height: 100));
        self.firstPoint = CGPoint(x: origin.x - 50, y: origin.y - 50);
        self.lastPoint = CGPoint(x: origin.x + 50, y: origin.y + 50);
        
        self.backgroundColor = UIColor.clear;
    }
    
    override init(frame: CGRect) {
        super.init(frame: CGRect(x: 100, y: 100, width: 100, height: 100));
        
        self.backgroundColor = UIColor.clear;
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func draw(_ rect: CGRect) {
//        CGRect frame = window.frame;
//        frame.origin.x = window.frame.origin.x + touchLocation.x - oldX;
//        frame.origin.y =  window.frame.origin.y + touchLocation.y - oldY;
//        window.frame = frame;
        print("DRAW IS CALLED");
        let r: CGRect = CGRect(x: firstPoint.x, y: firstPoint.y, width: lastPoint.x - firstPoint.x, height: lastPoint.y - firstPoint.y);
        
        self.frame = CGRect(x: firstPoint.x, y: firstPoint.y, width: lastPoint.x - firstPoint.x, height: lastPoint.y - firstPoint.y);
        
        
        let insetRect = r.insetBy(dx: 3, dy: 3);
        let path = UIBezierPath(roundedRect: insetRect, cornerRadius: 10);
        
        UIColor.red.setFill()
        path.lineWidth = 3;
        UIColor.black.setStroke();
        path.fill();
        path.stroke();
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if (self.isSelected) {
            self.isDragging = true;
            print("touches began");
            guard let point = touches.first else { return };
            
            previousPoint1 = point.previousLocation(in: self)
            currentPoint = point.location(in: self)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if (self.isDragging) {
            print("touches moved");
            guard let point = touches.first else { return };
            
            previousPoint2 = previousPoint1
            previousPoint1 = point.previousLocation(in: self)
            currentPoint = point.location(in: self)
            
            self.lastPoint = currentPoint!;
            setNeedsDisplay();
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.isDragging = false;
        touchesMoved(touches, with: event);
        print("touches ended");
    }
}

extension CanvasService {
    @discardableResult
    private static func request(route:CanvasEndpoint) -> Promise<Any> {
        return Promise {seal in
            Alamofire.request(route).responseJSON{ (response) in
                switch response.result {
                case .success(let value):
                    seal.fulfill(value);
                case .failure(let error):
                    seal.fulfill(error);
                }
            }
        }
    }
    
    static func getAll() -> Void{
        CanvasService.request(route: CanvasEndpoint.getAll()).done{canvas in
            print(canvas)
        }
    }
}
