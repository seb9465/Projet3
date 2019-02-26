//
//  Constants.swift
//  ios
//
//  Created by William Sevigny on 2019-02-19.
//  Copyright © 2019 LOG3000 equipe 12. All rights reserved.
//

import Foundation

struct PolyPaint {
    struct ProductionServer {
        static let baseURL = "https://polypaint.me/api"
    }
}

enum HTTPHeaderField: String {
    case authentication = "Authorization"
    case contentType = "Content-Type"
    case acceptType = "Accept"
    case acceptEncoding = "Accept-Encoding"
}

enum ContentType: String {
    case json = "application/json"
}
