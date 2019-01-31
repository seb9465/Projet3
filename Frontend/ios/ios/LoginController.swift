//
//  LoginController.swift
//  ios
//
//  Created by Sebastien Cadorette on 2019-01-21.
//  Copyright © 2019 LOG3000 equipe 12. All rights reserved.
//

import UIKit
import Alamofire
import PromiseKit
import AwaitKit

let loginURL: URLConvertible = "http://10.200.19.14:5000/api/login";

class LoginController: UIViewController, UITextFieldDelegate {
    @IBOutlet var emailField: UITextField!
    @IBOutlet var passwordField: UITextField!
    @IBOutlet var validationLabel: UILabel!

    @IBOutlet var loginButton: UIButton!
    
    var placeHolder = "";

    @IBAction func loginButton(_ sender: Any) {
        let validEmail: Bool = isValidEmail(testStr: emailField.text!);
        validationLabel.text = validEmail ? "Valid" : "Invalid";
        
        async{
            let response = try await(self.authenticateUser(email:"guccigang", password:"!12345Aa"));
            print(response);
            
//            if(response.){
//                
//            }
        }
    }
    
    func authenticateUser(email: String, password: String) -> Promise<Any>{
        let parameters = [
            "username": email,
            "password": password
            ]
        
        return Promise {seal in
            Alamofire.request(loginURL, method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON{ response in

                seal.fulfill(response);
            };
        }
    }

    func isValidEmail(testStr: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegEx)

        return emailTest.evaluate(with: testStr)
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        print("delegated")
        placeHolder = textField.placeholder ?? ""
        textField.placeholder = ""
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.placeholder == ""{
            textField.placeholder = placeHolder
        }
    }
}
