//
//  authAPI.swift
//  ios
//
//  Created by William Sevigny on 2019-02-26.
//  Copyright © 2019 LOG3000 equipe 12. All rights reserved.
//

import Alamofire
import PromiseKit
import AwaitKit

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
                        let responseDataString = String(data: response.data!, encoding:String.Encoding.utf8)
                        let error: Error = LoginError.customError(error: responseDataString!)
                        seal.reject(error)
                    }
            };
        }
    }
    
    static func getIsTutorialShown() -> Promise<Bool> {
        let headers = ["Authorization": "Bearer " + UserDefaults.standard.string(forKey: "token")!];
        let url: URLConvertible = Constants.TUTORIAL_URL as URLConvertible;
        
        return Promise { (seal) in
            Manager.request(url, method: .get, encoding: JSONEncoding.default, headers: headers).validate()
                .responseString { (response) in
                    switch response.result {
                    case .success:
                        seal.fulfill(Bool(response.value!)!);
                        break;
                    case .failure(let error):
                        seal.reject(error);
                        break;
                    }
            }
        }
    }
    
    static func setIsTutorialShown() -> Void {
        let headers = ["Authorization": "Bearer " + UserDefaults.standard.string(forKey: "token")!];
        let url: URLConvertible = Constants.TUTORIAL_SHOWN_URL as URLConvertible;
        
        Manager.request(url, method: .get, encoding: JSONEncoding.default, headers: headers);
    }
    
    static func fbLogin(accessToken: String, username: String, email: String, firstName: String, lastName: String) -> Promise<String> {
        let credentials = ["Fbtoken": accessToken, "Username": username, "Email": email, "FirstName": firstName, "LastName": lastName]
        let url = Constants.FB_LOGIN_URL as URLConvertible
        
        return Promise { (seal) in
            Manager.request(url, method: .post, parameters: credentials, encoding: JSONEncoding.default).validate()
                .responseString { (response) in
                    switch response.result {
                    case .success:
                        let userToken = response.value!
                        seal.fulfill(userToken);
                    case .failure(let Error):
                        let responseDataString = String(data: response.data!, encoding:String.Encoding.utf8)
                        let error: Error = LoginError.customError(error: responseDataString!)
                        seal.reject(error)
                    }
            };
        }
    }
    
    static func logout() -> Promise<Void> {
        return async {
            let headers = ["Authorization": "Bearer " + UserDefaults.standard.string(forKey: "token")!];
            
            Manager.request(Constants.LOGOUT_URL as URLConvertible, method: .get, encoding: JSONEncoding.default, headers: headers);
            
            ChatService.shared.disconnectFromHub();
            UserDefaults.standard.removePersistentDomain(forName: "token");
        }
    }
}
