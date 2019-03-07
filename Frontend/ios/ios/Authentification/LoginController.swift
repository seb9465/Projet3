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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @IBAction func loginPressed(_ sender: Any) {
        let sv = UIViewController.displaySpinner(onView: self.view);
//        let validEmail: Bool = isValidEmail(email: emailField.text!);
        
        AuthentificationAPI.login(username: emailField.text!, password: passwordField.text!)
//        AuthentificationAPI.login(username: "user.2", password: "!12345Aa")
            .done { (token) in
                UIViewController.removeSpinner(spinner: sv);
                self.validationLabel.text = ""
                self.storeAuthentificationToken(token: token)
                
                // Navigate to dashboard
                let mainController = self.storyboard?.instantiateViewController(withIdentifier: "MainController") as! UINavigationController
                self.present(mainController, animated: true, completion: nil)
            }.catch { (Error) in
                UIViewController.removeSpinner(spinner: sv);
                self.validationLabel.text = "Invalid Credentials"
                print(Error)
        }
    }
    
    @IBAction func registerPressed(_ sender: UIButton) {
        // Navigate to register page
        let registerConroller = storyboard?.instantiateViewController(withIdentifier: "RegisterController") as! RegisterController
        self.present(registerConroller, animated: true, completion: nil)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height / 3
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
    
    
    func storeAuthentificationToken(token: String) {
        UserDefaults.standard.set(token, forKey: "token")
        UserDefaults.standard.synchronize();
    }
    
    func isValidEmail(email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegEx)

        return emailTest.evaluate(with: email)
    }
}
