//
//  HttpResponseMessage.swift
//  ios
//
//  Created by Sebastien Cadorette on 2019-04-01.
//  Copyright © 2019 LOG3000 equipe 12. All rights reserved.
//

import Foundation

class HttpResponseMessage: Codable {
    
    // MARK: Attributes
    
    public var description: String;
    public var code: String;
    
    // MARK: Constructor
    
    init (description: String, code: String) {
        self.description = description;
        self.code = code;
    }
    
    // MARK: Getter - Setter
    
//    public var description: String {
//        get { return self._description }
//    }
//
//    public var code: String {
//        get { return self._code }
//    }
}
