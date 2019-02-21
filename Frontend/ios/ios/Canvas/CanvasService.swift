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
    private let pathArray: NSMutableArray = NSMutableArray();
    private let bufferArray: NSMutableArray = NSMutableArray();
    
    init(origin: CGPoint) {
        super.init(frame: CGRect(x: 0, y: 0, width: 100, height: 100));
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
        let insetRect = rect.insetBy(dx: 3, dy: 3);
        let path = UIBezierPath(roundedRect: insetRect, cornerRadius: 10);
        
        UIColor.red.setFill()
        path.lineWidth = 3;
        UIColor.black.setStroke();
        path.fill();
        path.stroke();
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
