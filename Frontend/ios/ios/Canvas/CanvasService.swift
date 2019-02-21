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
    private static func request(route:CanvasEndpoint) -> Promise<Data> {
        let token = UserDefaults.standard.string(forKey: "token")
        let headers = [
            "Authorization": "Bearer " + token!,
            "Accept": "application/json"
        ]
        
        let url: URLConvertible = "https://polypaint.me/api/user/canvas"
        
        return Promise {seal in
            let request = Alamofire.request(url, method: .get, encoding: JSONEncoding.default, headers: headers).responseJSON{ (response) in
               print(response.value)
//                switch response.result {
//                    case .success(let value):
                        seal.fulfill(response.data!);
//                    case .failure(let error):
//                         seal.fulfill(nil);
                }
            }
        }
//    }
    
    static func getAll() -> Void {
        CanvasService.request(route: CanvasEndpoint.getAll()).done{ (data) in
            do {
                debugPrint(data)
                let canvas = try JSONDecoder().decode([Canvas].self, from: data)
                debugPrint(canvas)
//                print(canvas[0])
            } catch {
                print(error)
                print("Error in decoding")
            }
        }
    }
}
