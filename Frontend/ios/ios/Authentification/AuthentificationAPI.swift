//
//  authAPI.swift
//  ios
//
//  Created by William Sevigny on 2019-02-26.
//  Copyright © 2019 LOG3000 equipe 12. All rights reserved.
//

import Alamofire
import PromiseKit

class AuthentificationAPI {
    
    static func login(username: String, password: String) -> Promise<String> {
        let credentials = ["username": username, "password": password]
        let url = Constants.LOGIN_URL as URLConvertible
        
        return Promise { (seal) in
            Alamofire.request(url, method: .post, parameters: credentials, encoding: JSONEncoding.default).validate().responseString{ (response) in
                switch response.result {
                    case .success:
                        let userToken = response.value!
                        seal.fulfill(userToken);
                    
                    case .failure(let Error):
                        seal.reject(Error)
                }
            };
        }
    }
}
