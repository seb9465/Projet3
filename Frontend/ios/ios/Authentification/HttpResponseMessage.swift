//
//  HttpResponseMessage.swift
//  ios
//
//  Created by Sebastien Cadorette on 2019-04-01.
//  Copyright © 2019 LOG3000 equipe 12. All rights reserved.
//

import Foundation

class HttpResponseMessage {
    
    // MARK: Attributes
    
    private var _description: String;
    private var _code: String;
    
    // MARK: Constructor
    
    init (description: String, code: String) {
        self._description = description;
        self._code = code;
    }
    
    // MARK: Getter - Setter
    
    public var description: String {
        get { return self._description }
    }
    
    public var code: String {
        get { return self._code }
    }
}
