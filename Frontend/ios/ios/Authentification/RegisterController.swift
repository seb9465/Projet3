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
import Alamofire_SwiftyJSON



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
//        let registrationViewModel: RegistrationViewModel = RegistrationViewModel(firstName: self.firstNameField.text!, lastName: self.lastNameField.text!, email: self.usernameField.text!, username: self.emailField.text!, password: self.passwordField.text!);
        let registrationViewModel: RegistrationViewModel = RegistrationViewModel(firstName: "sebaaaa", lastName: "cadoo", email: "sebbaa.cadoo@me.com", username: "sebbaa.cadoo", password: "!12345Aa");
        
        registerUser(parameters: registrationViewModel.toJson())
            .done { response in
                
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
            Alamofire.request(Constants.REGISTER_URL as URLConvertible, method: .post, parameters: parameters as Parameters, encoding: JSONEncoding.default).responseSwiftyJSON{ response in
                switch response.result {
                case .success:
                    var errors: [Any] = [];
                    for err in response.value! {
                        errors.append(err.1);
                    }
                    
                    print(errors.count);
                    break;
                case .failure (let error):
//                    print(error as! String);
//                    let error: String = response.value as! String;
//                    let indexStartOfText = error.index(error.startIndex, offsetBy: 1)
//                    let indexEndOfText = error.index(error.endIndex, offsetBy: -2)
//                    let substring = error[indexStartOfText..<indexEndOfText];
                    break;
                }
//                if let status = response.response?.statusCode {
//                    switch(status){
//                    case 200:
//                        self.present(self.buildOkAlert(), animated: true, completion: nil);
//                    default:
//                        var error: String = response.description as String;
////                        print(error);
//                        error = String(error.filter { !"\n\t\r".contains($0) })
//                        let indexStartOfText = error.index(error.startIndex, offsetBy: 10)
//                        let indexEndOfText = error.index(error.endIndex, offsetBy: -1)
//                        let substring = error[indexStartOfText..<indexEndOfText];
//                        print(substring);
//                        let sub = substring.replacingOccurrences(of: "},", with: "};");
//                        let errors: [String] = sub.components(separatedBy: ";");
//
////                        print(errors);
//
//                    }
                
                
                seal.fulfill(response);
            };
        }
    }
    
    private func buildOkAlert() -> UIAlertController {
        let alert: UIAlertController = UIAlertController(title: "Registration complete!", message: "Welcome abord " + self.firstNameField.text!, preferredStyle: .alert);
        
        let okAction: UIAlertAction = UIAlertAction(title: "Sick, let me in!", style: .default, handler: { action in
            let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil);
            let viewController: UIViewController = mainStoryboard.instantiateViewController(withIdentifier: "LoginStoryboard");
            
            let transition = CATransition()
            transition.duration = 0.5
            transition.type = CATransitionType.fade
            transition.subtype = CATransitionSubtype.fromBottom
            self.view.window?.layer.add(transition, forKey: kCATransition);
            
            self.present(viewController, animated: false, completion: nil);
        });
        
        alert.addAction(okAction);
        
        return alert;
    }
}
