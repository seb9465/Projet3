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
    
    private static var Manager : Alamofire.SessionManager = {
        // Create the server trust policies
        let serverTrustPolicies: [String: ServerTrustPolicy] = [
            "localhost": .disableEvaluation
        ]
        // Create custom manager
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = Alamofire.SessionManager.defaultHTTPHeaders
        let manager = Alamofire.SessionManager(
            configuration: URLSessionConfiguration.default,
            serverTrustPolicyManager: ServerTrustPolicyManager(policies: serverTrustPolicies)
        )
        return manager
    }()
    
    static func login(username: String, password: String) -> Promise<String> {
        let credentials = ["username": username, "password": password]
        let url = Constants.LOGIN_URL as URLConvertible
        
        return Promise { (seal) in
            Manager.request(url, method: .post, parameters: credentials, encoding: JSONEncoding.default).validate()
                .responseString { (response) in
                    switch response.result {
                        case .success:
                            print("Login successful for:", username)
                            let userToken = response.value!
                            seal.fulfill(userToken);
                        
                        case .failure(let Error):
                            seal.reject(Error);
                    }
            };
        }
    }
    
    static func fbLogin(accessToken: String, username: String, email: String) -> Promise<String> {
        let credentials = ["accessToken": accessToken, "username": username, "email": email]
        let url = Constants.FB_LOGIN_URL as URLConvertible
        
        return Promise { (seal) in
            Manager.request(url, method: .post, parameters: credentials, encoding: JSONEncoding.default).validate()
                .responseString { (response) in
                    switch response.result {
                    case .success:
                        print("FB DONE")
                        let userToken = response.value!
                        seal.fulfill(userToken);
                        
                    case .failure(let Error):
                        seal.reject(Error);
                    }
            };
        }
    }
    
    static func logout() -> Void {
        let headers = ["Authorization": "Bearer " + UserDefaults.standard.string(forKey: "token")!];
        
        Manager.request(Constants.LOGOUT_URL as URLConvertible, method: .get, encoding: JSONEncoding.default, headers: headers)
    }
}
