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
import JWTDecode
class LoginController: UIViewController, UITextFieldDelegate, WKUIDelegate {
    
    @IBOutlet weak var facebookButton: RoundedCorners!
    // MARK: Outlets
    
    @IBOutlet weak var serverlabel: UILabel!;
    @IBOutlet var emailField: UITextField!;
    @IBOutlet var passwordField: UITextField!;
    @IBOutlet var validationLabel: UILabel!;
    @IBOutlet var loginButton: UIButton!;
    @IBOutlet weak var offlineButton: RoundedCorners!;
    
    // MARK: Timing functions
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        self.serverlabel.text = "Server: " + Constants.SERVER_BASE_URL;
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil);
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil);
        
        view.addSubview(loginButton)
        // TODO: DÉCOMMENTÉ LES PROCHAINES LIGNES POUR LA VERSION RELEASE.
        //        self.loginButton.isUserInteractionEnabled = false;
        //        self.loginButton.alpha = 0.5;
        //        self.setupAddTargetIsNotEmptyTextFields();
    }
    
    // MARK: Action functions
    
    /**
     Handling when the Login button is pressed.
     */
    @IBAction func loginPressed(_ sender: Any) -> Void {
        let spinner = UIViewController.displaySpinner(onView: self.view);
        let token = UserDefaults.standard.string(forKey: "token");
        
        if(token != nil) {
            print("should logout")
            AuthentificationAPI.logout()
            UserDefaults.standard.removePersistentDomain(forName: "token");
        }
        //        AuthentificationAPI.login(username: emailField.text!, password: passwordField.text!)
        AuthentificationAPI.login(username: "sebastien.labine", password: "!12345Aa")
            //        AuthentificationAPI.login(username: "seb.cado2", password: "!12345Aa")
            .done { (token) in
                UIViewController.removeSpinner(spinner: spinner);
                self.validationLabel.text = "";
                self.storeAuthentificationToken(token: token);
                ChatService.shared.connectToHub();
                
                let mainController = self.storyboard?.instantiateViewController(withIdentifier: "MainController");
                self.present(mainController!, animated: true, completion: nil);
            }.catch { (Error) in
                UIViewController.removeSpinner(spinner: spinner);
                // TODO: Afficher le bon message d'erreur. En attente du serveur.
                self.validationLabel.text = "Invalid Credentials";
                print(Error);
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
    
    private func storeAuthentificationToken(token: String) -> Void {
        UserDefaults.standard.set(token, forKey: "token");
        UserDefaults.standard.synchronize();
    }
    
    private func setupAddTargetIsNotEmptyTextFields() -> Void {
        self.emailField.addTarget(self, action: #selector(textFieldsWithoutErrors),
                                  for: .editingChanged);
        self.passwordField.addTarget(self, action: #selector(textFieldsWithoutErrors),
                                     for: .editingChanged);
    }
    
    @IBAction func facebookButtonClicked(_ sender: Any) {
        let loginManager = LoginManager()
        loginManager.loginBehavior = .web
        loginManager.logIn(readPermissions: [.email, .publicProfile], viewController: self, completion: { loginResult in
            switch loginResult {
            case .failed(let error):
                print(error)
            case .cancelled:
                print("User cancelled login.")
            case .success(let grantedPermissions, let declinedPermissions, let accessToken):
                print(accessToken)
                print("Logged in!")
                AuthentificationAPI.fbLogin(accessToken: accessToken.authenticationToken, username: "test", email: "test@test.com").done({ (token) in
                    print("CALLBACK WORKS")
                })
            }
        })
    }
}
/*var webView: WKWebView!
 
 let webConfiguration = WKWebViewConfiguration()
 webView = WKWebView(frame: .zero, configuration: webConfiguration)
 webView.uiDelegate = self
 view = webView
 let myURL = URL(string:"https://www.polypaint.me/api/login")
 let myRequest = URLRequest(url: myURL!)
 webView.load(myRequest)
 */
