//
//  File.swift
//  ios
//
//  Created by William Sevigny on 2019-02-19.
//  Copyright © 2019 LOG3000 equipe 12. All rights reserved.
//
// Inspired by https://medium.com/@AladinWay/write-a-networking-layer-in-swift-4-using-alamofire-and-codable-part-1-api-router-349699a47569

import Alamofire

enum CanvasEndpoint: APIConfiguration {
    case getAll()
    
    // MARK: - HTTPMethod
    var method: HTTPMethod {
        switch self {
        case .getAll():
            return .get
        }
    }
    
    // MARK: - Path
    var path: String {
        switch self {
        case .getAll():
            return "/user/canvas"
        }
    }
    
    // MARK: - Parameters
    var parameters: Parameters? {
        switch self {
        case .getAll():
            return nil
        }
    }
    
    // MARK: - URLRequestConvertible
    func asURLRequest() throws -> URLRequest {
        let url = try PolyPaint.ProductionServer.baseURL.asURL()
        
        var urlRequest = URLRequest(url: url.appendingPathComponent(path))
        
        // HTTP Method
        urlRequest.httpMethod = method.rawValue
        
        // Common Headers
        urlRequest.setValue(ContentType.json.rawValue, forHTTPHeaderField: HTTPHeaderField.acceptType.rawValue)
        urlRequest.setValue(ContentType.json.rawValue, forHTTPHeaderField: HTTPHeaderField.contentType.rawValue)
        
        // Parameters
        if let parameters = parameters {
            do {
                urlRequest.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
            } catch {
                throw AFError.parameterEncodingFailed(reason: .jsonEncodingFailed(error: error))
            }
        }
        
        return urlRequest
    }
}
