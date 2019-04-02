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
    
    @IBOutlet weak var autologinlabel: UILabel!
    @IBOutlet weak var serverlabel: UILabel!
    @IBOutlet var emailField: UITextField!
    @IBOutlet var passwordField: UITextField!
    @IBOutlet var validationLabel: UILabel!
    @IBOutlet var loginButton: UIButton!
    
    @IBOutlet weak var offlineButton: RoundedCorners!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.serverlabel.text = "Server: " + Constants.SERVER_BASE_URL
        self.autologinlabel.text = "Auto-login: true"
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        // TODO: DÉCOMMENTÉ LES PROCHAINES LIGNES POUR LA VERSION RELEASE.
//        self.loginButton.isUserInteractionEnabled = false;
//        self.loginButton.alpha = 0.5;
//        self.setupAddTargetIsNotEmptyTextFields();
    }
    
    @IBAction func loginPressed(_ sender: Any) {
        let sv = UIViewController.displaySpinner(onView: self.view);
        
        AuthentificationAPI.login(username: emailField.text!, password: passwordField.text!)
//        AuthentificationAPI.login(username: "seb.cado2", password: "!12345Aa")
            .done { (token) in
                UIViewController.removeSpinner(spinner: sv);
                self.validationLabel.text = ""
                self.storeAuthentificationToken(token: token)
                ChatService.shared.connectToHub();
                
                let mainController = self.storyboard?.instantiateViewController(withIdentifier: "MainController")
                self.present(mainController!, animated: true, completion: nil)
            }.catch { (Error) in
                UIViewController.removeSpinner(spinner: sv);
                self.validationLabel.text = "Invalid Credentials"
                print(Error)
        }
    }
    
    @IBAction func registerPressed(_ sender: UIButton) {
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
    
    @objc func textFieldsWithoutErrors(sender: UITextField) -> Void {
        sender.text = sender.text?.trimmingCharacters(in: .whitespaces)
        
        guard
            let username = self.emailField.text, !username.isEmpty,
            let password = self.passwordField.text, password.isEmpty
            else
        {
            self.loginButton.alpha = 0.5;
            self.loginButton.isUserInteractionEnabled = false;
            return
        }
        
        self.loginButton.alpha = 1;
        self.loginButton.isUserInteractionEnabled = true;
    }
    
    func storeAuthentificationToken(token: String) {
        UserDefaults.standard.set(token, forKey: "token")
        UserDefaults.standard.synchronize();
    }
    
    private func setupAddTargetIsNotEmptyTextFields() {
        self.emailField.addTarget(self, action: #selector(textFieldsWithoutErrors),
                                      for: .editingChanged)
        self.passwordField.addTarget(self, action: #selector(textFieldsWithoutErrors),
                                     for: .editingChanged)
    }
    
//    func isValidEmail(email: String) -> Bool {
//        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
//        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
//
//        return emailTest.evaluate(with: email)
//    }
}
