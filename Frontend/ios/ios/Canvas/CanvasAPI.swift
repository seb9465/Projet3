//
//  CanvasAPI.swift
//  ios
//
//  Created by William Sevigny on 2019-02-26.
//  Copyright © 2019 LOG3000 equipe 12. All rights reserved.
//
import Alamofire
import PromiseKit

class CanvasAPI {
    
    @discardableResult
    private static func get() -> Promise<Data> {
        let url: URLConvertible = "https://polypaint.me/api/user/canvas"
        let headers = [
            "Authorization": "Bearer " + UserDefaults.standard.string(forKey: "token")!,
            "Accept": "application/json"
        ]
        
        return Promise { (seal) in
            Alamofire.request(url, method: .get, encoding: JSONEncoding.default, headers: headers).responseJSON{ (response) in
                switch response.result {
                case .success( _):
                    seal.fulfill(response.data!);
                case .failure(let error):
                    seal.reject(error)
                }
            }
        }
    }
    
    static func getAll() -> Promise<[Canvas]> {
        return Promise { seal in
            CanvasAPI.get().done{ (data) in
                let canvas = try JSONDecoder().decode([Canvas].self, from: data)
                seal.fulfill(canvas)
                }.catch({ (Error) in
                    print("Canvas Fetch failed", Error)
                })
        }
    }
}
