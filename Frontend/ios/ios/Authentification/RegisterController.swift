//
//  File.swift
//  ios
//
//  Created by William Sevigny on 2019-01-29.
//  Copyright © 2019 LOG3000 equipe 12. All rights reserved.
//

import UIKit
import Alamofire
import PromiseKit
import AwaitKit

protocol UserProtocol {
    var firstName: String { get }
    var lastName: String { get }
    var username: String { get }
    var email: String { get }
    var password: String { get }
}

let registerURL: URLConvertible = "http://192.168.0.183:4000/api/register";

class RegisterController: UIViewController {
    
    @IBOutlet weak var firstNameField: UITextField!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var lastNameField: UITextField!
    
    @IBAction func registerButtonPressed(_ sender: UIButton) {
        let userInfo = [
            "firstName": self.firstNameField.text,
            "lastName": self.lastNameField.text,
            "username": self.usernameField.text,
            "email": self.emailField.text,
            "password": self.passwordField.text,
        ];

        async{
            let response = try await(self.registerUser(parameters: userInfo));
            print(response);
        }
    }
    
    func registerUser(parameters: [String: String?]) -> Promise<Any>{
        return Promise {seal in
            Alamofire.request(registerURL, method: .post, parameters: parameters as Parameters, encoding: JSONEncoding.default).responseString{ response in
                seal.fulfill(response);
            };
        }
    }
}
