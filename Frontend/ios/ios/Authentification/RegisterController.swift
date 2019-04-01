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

let emailTest = NSPredicate(format: "SELF MATCHES %@", "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}")

class RegisterController: UIViewController {
    
    // MARK: Outlets
    
    @IBOutlet weak var firstNameField: UITextField!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var lastNameField: UITextField!
    
    // MARK: Actions
    
    @IBAction func registerButtonPressed(_ sender: UIButton) {
        let registrationViewModel: RegistrationViewModel = RegistrationViewModel(firstName: self.firstNameField.text!, lastName: self.lastNameField.text!, email: self.usernameField.text!, username: self.emailField.text!, password: self.passwordField.text!);
        
        registerUser(parameters: registrationViewModel.toJson())
            .done { response in
                print(response);
                self.performSegue(withIdentifier: "goBackToLogin", sender: nil)
            }
    }
    
    // MARK: Actions
    
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
    
    // MARK: Private functions
    
    private func registerUser(parameters: [String: String?]) -> Promise<Any>{
        return Promise {seal in
            Alamofire.request(Constants.REGISTER_URL as URLConvertible, method: .post, parameters: parameters as Parameters, encoding: JSONEncoding.default).responseJSON{ response in
                seal.fulfill(response);
            };
        }
    }
}
