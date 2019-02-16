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

let registerURL: URLConvertible = "http://10.200.21.214:4000/api/register"
let emailTest = NSPredicate(format: "SELF MATCHES %@", "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}")

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

//        async {
//            let response = try await(self.registerUser(parameters: userInfo));
//            print(response);
//            self.performSegue(withIdentifier: "goBackToLogin", sender: nil)
//        }
        registerUser(parameters: userInfo)
            .done { response in
                print(response);
                self.performSegue(withIdentifier: "goBackToLogin", sender: nil)
            }
    }
    
    func registerUser(parameters: [String: String?]) -> Promise<Any>{
        return Promise {seal in
            Alamofire.request(registerURL, method: .post, parameters: parameters as Parameters, encoding: JSONEncoding.default).responseJSON{ response in
                seal.fulfill(response);
            };
        }
    }
    
    @IBAction func goBackPressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func validateNameField(_ sender: UITextField) {
        if((sender.text!.isEmpty)){
            sender.layer.borderWidth = 1.0;
            sender.layer.cornerRadius = 5;
            sender.layer.borderColor = UIColor.red.cgColor;
        } else {
            sender.layer.borderWidth = 1.0;
            sender.layer.cornerRadius = 5;
            sender.layer.borderColor = UIColor.green.cgColor;
        }
    }
    
    @IBAction func validateUsernameField(_ sender: UITextField) {
        // Check if username is registered in the database
    }
    
    @IBAction func validateEmailField(_ sender: UITextField) {
        if(emailTest.evaluate(with: sender.text)){
            sender.layer.borderWidth = 1.0;
            sender.layer.borderColor = UIColor.green.cgColor;
        } else {
            sender.layer.borderWidth = 1.0;
            sender.layer.borderColor = UIColor.red.cgColor;
        }
    }
    
    @IBAction func validatePasswordField(_ sender: UITextField) {
        // Check if password respects the format needed
    }
    
}
