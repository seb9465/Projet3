//
//  LoginError.swift
//  ios
//
//  Created by Sébastien Labine on 19-04-06.
//  Copyright © 2019 LOG3000 equipe 12. All rights reserved.
//

import Foundation

public enum LoginError: Error {
    case customError(error: String)
}

extension LoginError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .customError(let error):
            return NSLocalizedString(error, comment: "My error")
        }
    }
}
