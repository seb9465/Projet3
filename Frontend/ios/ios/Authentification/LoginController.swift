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
import FacebookLogin

class LoginController: UIViewController, UITextFieldDelegate, LoginButtonDelegate {
    @IBOutlet var emailField: UITextField!
    @IBOutlet var passwordField: UITextField!
    @IBOutlet var validationLabel: UILabel!
    @IBOutlet var loginButton: UIButton!
    @IBOutlet weak var loginView : FBSDKLoginButton!

    var placeHolder = "";
    
    override func viewDidLoad() {
        let url = URL(string: "https://polypaint.me/api/login")!
        UIApplication.shared.open(url, options: [:], completionHandler: nil)

/*
        let loginButton = LoginButton(readPermissions: [ .publicProfile, .email ])
        let screenSize:CGRect = UIScreen.main.bounds
        let screenHeight = screenSize.height
        let newCenterY = screenHeight - loginButton.frame.height - 10
        loginButton.center = CGPoint(x: view.center.x, y: CGFloat(newCenterY))
        loginButton.delegate = self
        loginButton.target(forAction: <#T##Selector#>, withSender: <#T##Any?#>)
        view.addSubview(loginButton)
 */
    }
    
    func loginButtonDidCompleteLogin(_ loginButton: LoginButton, result: LoginResult) {
        print(result)
        switch result {
        case .failed(let error):
            print(error)
        case .cancelled:
            print("Cancelled")
        case .success(let grantedPermissions, let declinedPermissions, let accessToken):
            print("Logged In")
            let token: String = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1bmlxdWVfbmFtZSI6InVzZXIuMyIsIm5hbWVpZCI6Ijg4OTU2NjlhLTYyMmMtNDk2ZS1iZTkwLTI4YTQzMGE3NzhhZSIsImZhbWlseV9uYW1lIjoidXNlcjMiLCJuYmYiOjE1NTA2MDA0NTUsImV4cCI6NjE1NTA2MDAzOTUsImlhdCI6MTU1MDYwMDQ1NSwiaXNzIjoiaHR0cHM6Ly9wb2x5cGFpbnQubWUiLCJhdWQiOiJodHRwczovL3BvbHlwYWludC5tZSJ9.jkOgmk7sdA3hL4YtXWn7a5I-d7nk-EbmrRV_sRR0pb4";
            
            UserDefaults.standard.set(token, forKey: "token")
            self.performSegue(withIdentifier: "goToDashboard", sender: nil)
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: LoginButton) {
        //
    }
    
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
