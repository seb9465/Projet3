//
//  File.swift
//  ios
//
//  Created by William Sevigny on 2019-02-19.
//  Copyright © 2019 LOG3000 equipe 12. All rights reserved.
//
// Inspired by https://medium.com/@AladinWay/write-a-networking-layer-in-swift-4-using-alamofire-5-and-codable-part-3-using-futures-promises-cf3977fc8a5

import Foundation
import PromiseKit
import Alamofire

class CanvasService {
    
    @discardableResult
    private static func request(route:CanvasEndpoint) -> Promise<Any> {
        let token = UserDefaults.standard.string(forKey: "token")
        let headers = [
            "Authorization": "Bearer " + token!,
            "Accept": "application/json"
        ]
        
        let url: URLConvertible = "https://polypaint.me/api/user/canvas"
        
        return Promise {seal in
            let request = Alamofire.request(url, method: .get, encoding: JSONEncoding.default, headers: headers).responseJSON{ (response) in
                switch response.result {
                    case .success(let value):
                         seal.fulfill(value);
                    case .failure(let error):
                         seal.fulfill(error);
                }
            }
        }
    }
    
    static func getAll() -> Void {
        let a = CanvasEndpoint.asURLRequest(CanvasEndpoint.getAll());
        print(a);
        CanvasService.request(route: CanvasEndpoint.getAll()).done{canvas in
            print(canvas)
        }
    }
}
