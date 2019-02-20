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
    
    var method: HTTPMethod {
        switch self {
        case .getAll():
            return .get
        }
    }
    
    var path: String {
        switch self {
        case .getAll():
            return "/user/canvas"
        }
    }
    
    var parameters: Parameters? {
        switch self {
        case .getAll():
            return nil
        }
    }
    
    var headers: HTTPHeaders {
        switch self {
        case .getAll():
            return [
                "Authorization": "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1bmlxdWVfbmFtZSI6InVzZXIuMiIsIm5hbWVpZCI6IjFmOTNlODQ0LTQ2OWEtNDEzOS04MTBhLTRjMzIxN2RiNDU4OCIsImZhbWlseV9uYW1lIjoidXNlcjIiLCJuYmYiOjE1NTA2MDk0MDUsImV4cCI6NjE1NTA2MDkzNDUsImlhdCI6MTU1MDYwOTQwNSwiaXNzIjoiaHR0cHM6Ly9wb2x5cGFpbnQubWUiLCJhdWQiOiJodHRwczovL3BvbHlwYWludC5tZSJ9.EF94akvlPi7XkdcvNCM-mqD0JhWD7w7v7B-rCqLnYOQ==",
                "Accept": "application/json"
            ]
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
