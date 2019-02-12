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

class LoginController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var emailField: UITextField!
    @IBOutlet var passwordField: UITextField!
    @IBOutlet var validationLabel: UILabel!
    @IBOutlet var loginButton: UIButton!
    
    var placeHolder = "";

    @IBAction func loginButton(_ sender: Any) {
        let sv = UIViewController.displaySpinner(onView: self.view);
        
        let validEmail: Bool = isValidEmail(testStr: emailField.text!);
        
        let parameters = [
            "username": emailField.text,
            "password": passwordField.text
        ]
        
        self.authenticateUser(parameters: parameters).done { response in
            UIViewController.removeSpinner(spinner: sv);
            if(response == "ERROR") {
                self.validationLabel.text = "Invalid Credentials"
            } else {
                self.validationLabel.text = ""
                UserDefaults.standard.set(response, forKey: "token")
                UserDefaults.standard.synchronize();
                
                print(UserDefaults.standard.string(forKey: "token") ?? "unkwnon");
                self.performSegue(withIdentifier: "goToDashboard", sender: nil)
            }
        }
    }
    
    @IBAction func registerPressed(_ sender: UIButton) {
        self.performSegue(withIdentifier: "goToRegister", sender: nil)
    }
    
    func authenticateUser(parameters: [String: String?]) -> Promise<String>{
        return Promise {seal in
            Alamofire.request(Constants.LOGIN_URL as URLConvertible, method: .post, parameters: parameters, encoding: JSONEncoding.default).validate().responseString{ response in
                
                switch response.result {
                    case .success:
                        print("Login Successful")
                        seal.fulfill(response.value!);
                case .failure( _):
                        print("Login Failed")
                        seal.fulfill("ERROR");
                }
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
