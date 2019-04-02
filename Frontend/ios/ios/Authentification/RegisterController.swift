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
    
    
    @IBOutlet var pwdErrorIcon: UIButton!
    @IBOutlet var pwdErrorText: UILabel!
    @IBOutlet var emailErrorIcon: UIButton!
    @IBOutlet var emailErrorText: UILabel!
    @IBOutlet var usernameErrorIcon: UIButton!
    @IBOutlet var usernameErrorText: UILabel!
    
    
    @IBOutlet var contentView: UIView!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var constraintContentHeight: NSLayoutConstraint!
    
    // MARK: Attributes
    
    private var activeField: UITextField?
    private var lastOffset: CGPoint!
    private var keyboardHeight: CGFloat!
    
    // MARK: Timing functions
    
    public override func viewDidLoad() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    self.contentView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(returnTextView(gesture:))))
        
        self.hideErrorViews();
        
        super.viewDidLoad();
    }
    
    public func hideErrorViews() -> Void {
        self.emailErrorIcon.isHidden = true;
        self.emailErrorText.isHidden = true;
        self.pwdErrorIcon.isHidden = true;
        self.pwdErrorText.isHidden = true;
        self.usernameErrorIcon.isHidden = true;
        self.usernameErrorText.isHidden = true;
    }
    
    // MARK: Actions
    var sv: UIView!;
    @IBAction func registerButtonPressed(_ sender: UIButton) {
//        let registrationViewModel: RegistrationViewModel = RegistrationViewModel(firstName: self.firstNameField.text!, lastName: self.lastNameField.text!, email: self.usernameField.text!, username: self.emailField.text!, password: self.passwordField.text!);
        let registrationViewModel: RegistrationViewModel = RegistrationViewModel(firstName: "user", lastName: "hyped", email: "user.777713123@me.com", username: "user.777711221", password: "!12345Aa");
        sv = UIViewController.displaySpinner(onView: self.view);
        registerUser(parameters: registrationViewModel.toJson())
            .done { response in
                
            } .catch { (error) in
//                self.present(self.buildFailureAlert(errorMessage: error.localizedDescription), animated: true);
                print(error);
                self.present(self.buildOkAlert(), animated: true);
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
    
    private func registerUser(parameters: [String: String?]) -> Promise<[HttpResponseMessage]>{
        return Promise {seal in
            Alamofire.request(Constants.REGISTER_URL as URLConvertible, method: .post, parameters: parameters as Parameters, encoding: JSONEncoding.default).responseSwiftyJSON{ response in
                UIViewController.removeSpinner(spinner: self.sv);
                self.hideErrorViews();
                var errors: [HttpResponseMessage] = [];
                print(response);
                print(response.result);
                switch response.result {
                case .failure(let error):
                    seal.reject(error);
                    break;
                case .success:
                    if (response.response?.statusCode == 400) {
                        for err in response.value! {
                            let messageJSON: String = err.1.rawString()!;
                            let message: HttpResponseMessage = self.showError(messageJSON: messageJSON);
                            errors.append(message);
                        }
                    }
                    break;
                }
                seal.fulfill(errors);
            };
        }
    }
    
    private func showError(messageJSON: String) -> HttpResponseMessage {
        let jsonData = messageJSON.data(using: .utf8);
        let message: HttpResponseMessage = try! JSONDecoder().decode(HttpResponseMessage.self, from: jsonData!);
        
        switch message.code {
        case "DuplicateEmail":
            self.emailErrorText.text = "Email already exists";
            self.emailErrorIcon.isHidden = false;
            self.emailErrorText.isHidden = false;
            break;
        case "DuplicateUserName":
            self.usernameErrorText.text = "Username already exists";
            self.usernameErrorIcon.isHidden = false;
            self.usernameErrorText.isHidden = false;
            break;
        default:
            break;
        }
        
        return message;
    }
    
    private func buildOkAlert() -> UIAlertController {
        let alert: UIAlertController = UIAlertController(title: "Registration complete!", message: "Welcome abord " + self.firstNameField.text!, preferredStyle: .alert);
        
        let okAction: UIAlertAction = UIAlertAction(title: "Sick, let me in!", style: .default, handler: { action in
//            let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil);
//            let viewController: UIViewController = mainStoryboard.instantiateViewController(withIdentifier: "LoginStoryboard");
//
//            let transition = CATransition()
//            transition.duration = 0.5
//            transition.type = CATransitionType.fade
//            transition.subtype = CATransitionSubtype.fromBottom
//            self.view.window?.layer.add(transition, forKey: kCATransition);
//
//            self.present(viewController, animated: false, completion: nil);
            self.dismiss(animated: true, completion: nil)
        });
        
        alert.addAction(okAction);
        
        return alert;
    }
    
    private func buildFailureAlert(errorMessage: String) -> UIAlertController {
        let alert: UIAlertController = UIAlertController(title: "Something went wrong", message: errorMessage, preferredStyle: .alert);
        
        let okAction: UIAlertAction = UIAlertAction(title: "Damn, alright I'll try again.", style: .default, handler: nil);
        
        alert.addAction(okAction);
        
        return alert;
    }
    
    @objc private func returnTextView(gesture: UIGestureRecognizer) {
        guard activeField != nil else {
            return
        }
        
        activeField?.resignFirstResponder()
        activeField = nil
    }
    
    // MARK: Object functions
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if keyboardHeight != nil {
            return
        }
        
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            keyboardHeight = keyboardSize.height;
            
            UIView.animate(withDuration: 0.3, animations: {
                self.constraintContentHeight.constant += self.keyboardHeight
            });
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        UIView.animate(withDuration: 0.3) {
            self.constraintContentHeight.constant -= self.keyboardHeight
        }
        
        keyboardHeight = nil
    }
}

// MARK: UITextFieldDelegate
extension RegisterController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        activeField = textField
        lastOffset = self.scrollView.contentOffset
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        activeField?.resignFirstResponder()
        activeField = nil
        return true
    }
}
