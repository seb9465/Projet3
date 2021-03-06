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
import WebKit
import FacebookLogin
import FacebookCore
import JWTDecode

class LoginController: UIViewController, UITextFieldDelegate, WKUIDelegate {
    
    // MARK: Outlets
    
    @IBOutlet var emailField: UITextField!;
    @IBOutlet var passwordField: UITextField!;
    @IBOutlet var validationLabel: UILabel!;
    @IBOutlet var loginButton: UIButton!;
    @IBOutlet weak var offlineButton: RoundedCorners!;
    @IBOutlet weak var facebookButton: RoundedCorners!
    
    // MARK: Timing functions
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil);
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil);
        
        // TODO: DÉCOMMENTÉ LES PROCHAINES LIGNES POUR LA VERSION RELEASE.
        self.loginButton.isUserInteractionEnabled = false;
        self.loginButton.alpha = 0.5;
        self.setupAddTargetIsNotEmptyTextFields();
    }
    
    // MARK: Action functions
    
    
    /**
     Handling when the Login button is pressed.
     */
    @IBAction func loginPressed(_ sender: Any) -> Void {
        let spinner = UIViewController.displaySpinner(onView: self.view);
        
        AuthentificationAPI.login(username: emailField.text!, password: passwordField.text!)
//                    AuthentificationAPI.login(username: "user", password: "!12345Aa")
            .done { (token) in
                UIViewController.removeSpinner(spinner: spinner);
                self.validationLabel.text = "";
                self.storeAuthentificationToken(token: token, id: "");
                self.present((self.storyboard?.instantiateViewController(withIdentifier: "MainController"))!, animated: true, completion: nil);
            }.catch { (responseError) in
                UIViewController.removeSpinner(spinner: spinner);
                self.validationLabel.text = responseError.localizedDescription;
        }
    }
    
    /**
     When clicking on the register button, it brings us to the Register view.
     */
    @IBAction func registerPressed(_ sender: UIButton) -> Void {
        let registerConroller = storyboard?.instantiateViewController(withIdentifier: "RegisterController") as! RegisterController;
        self.present(registerConroller, animated: true, completion: nil);
    }
    
    // MARK: Class Object functions
    
    /**
     When keyboard opens, the view will go up.
     */
    @objc func keyboardWillShow(notification: NSNotification) -> Void {
        if let keyboardSize: CGRect = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if (self.view.frame.origin.y == 0) {
                self.view.frame.origin.y -= keyboardSize.height / 3;
            }
        }
    }
    
    /**
     When keyboard closes, the view will go back to normal.
     */
    @objc func keyboardWillHide(notification: NSNotification) -> Void {
        if (self.view.frame.origin.y != 0) {
            self.view.frame.origin.y = 0;
        }
    }
    
    /**
     Makes the Register button enabled while the fields are not filled.
     */
    @objc func textFieldsWithoutErrors(sender: UITextField) -> Void {
        sender.text = sender.text?.trimmingCharacters(in: .whitespaces);
        
        guard
            let username = self.emailField.text, !username.isEmpty,
            let password = self.passwordField.text, !password.isEmpty
            else
        {
            self.loginButton.alpha = 0.5;
            self.loginButton.isUserInteractionEnabled = false;
            return;
        }
        
        self.loginButton.alpha = 1;
        self.loginButton.isUserInteractionEnabled = true;
    }
    
    // MARK: Private functions
    
    private func storeAuthentificationToken(token: String, id: String) -> Void {
        UserDefaults.standard.set(token, forKey: "token");
        UserDefaults.standard.set(id, forKey: "id");
        UserDefaults.standard.synchronize();
    }
    
    private func setupAddTargetIsNotEmptyTextFields() -> Void {
        self.emailField.addTarget(self, action: #selector(textFieldsWithoutErrors),
                                  for: .editingChanged);
        self.passwordField.addTarget(self, action: #selector(textFieldsWithoutErrors),
                                     for: .editingChanged);
    }
    
    @IBAction func facebookButtonClicked(_ sender: Any) {
        self.validationLabel.text = "";
        let loginManager = LoginManager()
        loginManager.logOut()
        loginManager.loginBehavior = .web
        loginManager.logIn(readPermissions: [.email, .publicProfile], viewController: self, completion: { loginResult in
            switch loginResult {
            case .failed:
               self.showErrorMessage()
            case .cancelled:
                print("User cancelled login.")
            case .success( _, _, let accessToken):
                
                let connection = GraphRequestConnection()
                connection.add( GraphRequest(graphPath: "me", parameters: ["fields":"email,id,first_name,last_name"], accessToken: AccessToken.current, httpMethod: .GET, apiVersion: FacebookCore.GraphAPIVersion.defaultVersion)) { httpResponse, result in
                    switch result {
                    case .success(let response):
                        let facebookResponse = response.dictionaryValue as! [String: String]
                        AuthentificationAPI.fbLogin(accessToken: accessToken.authenticationToken, username: facebookResponse["id"]!, email: facebookResponse["email"]!, firstName: facebookResponse["first_name"]!, lastName: facebookResponse["last_name"]!).done({ (token) in
                            self.storeAuthentificationToken(token: token,id: facebookResponse["id"]!);
                            
                            let mainController = self.storyboard?.instantiateViewController(withIdentifier: "MainController");
                            self.present(mainController!, animated: true, completion: nil);
                        }).catch({(Error) in
                            self.validationLabel.text = Error.localizedDescription;
                        })
                        break;
                    case .failed(let error):
                        print(error)
                        self.showErrorMessage()
                        break;
                    }
                }
                connection.start()
            }
        });
    }
    
    public func showErrorMessage() {
        let alert: UIAlertController = UIAlertController(title: "Error!", message: "An error as occured. Please try again.", preferredStyle: .alert);
        let okAction: UIAlertAction = UIAlertAction(title: "Ok", style: .default, handler: nil);
        alert.addAction(okAction);
        self.present(alert, animated: true, completion: nil);
    }
}
