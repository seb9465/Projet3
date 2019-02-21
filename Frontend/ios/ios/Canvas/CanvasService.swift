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
