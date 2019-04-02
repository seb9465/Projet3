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


let EMAIL_REGEX = NSPredicate(format: "SELF MATCHES %@", "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}")
let PWD_REGEX = NSPredicate(format: "SELF MATCHES %@", "(?=.*[a-z])(?=.*[A-Z])(?=[!@#$&*]).{8,15}");

class RegisterController: UIViewController {
    
    // MARK: Outlets
    
    @IBOutlet weak var firstNameField: UITextField!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var lastNameField: UITextField!
    
    @IBOutlet var firstNameErrorIcon: UIButton!
    @IBOutlet var firstNameErrorText: UILabel!
    @IBOutlet var lastNameErrorIcon: UIButton!
    @IBOutlet var lastNameErrorText: UILabel!
    @IBOutlet var usernameErrorIcon: UIButton!
    @IBOutlet var usernameErrorText: UILabel!
    @IBOutlet var emailErrorIcon: UIButton!
    @IBOutlet var emailErrorText: UILabel!
    @IBOutlet var pwdErrorIcon: UIButton!
    @IBOutlet var pwdErrorText: UILabel!
    
    @IBOutlet var contentView: UIView!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var constraintContentHeight: NSLayoutConstraint!
    
    // MARK: Attributes
    
    private var activeField: UITextField?
    private var lastOffset: CGPoint!
    private var keyboardHeight: CGFloat!
    private var spinner: UIView!;
    
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
    
    @IBAction func registerButtonPressed(_ sender: UIButton) {
//        let registrationViewModel: RegistrationViewModel = RegistrationViewModel(firstName: self.firstNameField.text!, lastName: self.lastNameField.text!, email: self.usernameField.text!, username: self.emailField.text!, password: self.passwordField.text!);
        let registrationViewModel: RegistrationViewModel = RegistrationViewModel(firstName: "user", lastName: "hyped", email: "user.777713123@me.com", username: "user.777711221", password: "!12345");
        spinner = UIViewController.displaySpinner(onView: self.view);
        registerUser(parameters: registrationViewModel.toJson())
            .done { response in
                
            } .catch { (error) in
                print(error);
                self.present(self.buildOkAlert(), animated: true);
            }
    }
    
    // MARK: Actions
    
    @IBAction func goBackPressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func validateFirstNameField(_ sender: UITextField) {
        if((sender.text!.isEmpty)){
            sender.layer.borderWidth = 1.0;
            sender.layer.cornerRadius = 5;
            sender.layer.borderColor = UIColor.red.cgColor;
        } else {
            sender.layer.borderWidth = 1.0;
            sender.layer.cornerRadius = 5;
            sender.layer.borderColor = Constants.RED_COLOR.cgColor;
        }
    }
    
    @IBAction func validateLastNameField(_ sender: UITextField) {
        if((sender.text!.isEmpty)){
            sender.layer.borderWidth = 1.0;
            sender.layer.cornerRadius = 5;
            sender.layer.borderColor = UIColor.red.cgColor;
        } else {
            sender.layer.borderWidth = 1.0;
            sender.layer.cornerRadius = 5;
            sender.layer.borderColor = Constants.RED_COLOR.cgColor;
        }
    }
    
    @IBAction func validateUserNameField(_ sender: UITextField) {
        if((sender.text!.isEmpty)){
            sender.layer.borderWidth = 1.0;
            sender.layer.cornerRadius = 5;
            sender.layer.borderColor = UIColor.red.cgColor;
        } else {
            sender.layer.borderWidth = 1.0;
            sender.layer.cornerRadius = 5;
            sender.layer.borderColor = Constants.RED_COLOR.cgColor;
        }
    }
    
    @IBAction func validateEmailField(_ sender: UITextField) {
        sender.layer.borderWidth = 1.0;
        
        if(EMAIL_REGEX.evaluate(with: sender.text)){
            sender.layer.borderColor = UIColor.green.cgColor;
            self.emailErrorText.isHidden = true;
            self.emailErrorIcon.isHidden = true;
        } else {
            sender.layer.borderColor = Constants.RED_COLOR.cgColor;
            self.emailErrorText.text = "Invalid email format";
            self.emailErrorText.isHidden = false;
            self.emailErrorIcon.isHidden = false;
        }
    }
    
    @IBAction func validatePasswordField(_ sender: UITextField) {
        sender.layer.borderWidth = 1.0;
        
        if(PWD_REGEX.evaluate(with: sender.text)){
            sender.layer.borderColor = UIColor.green.cgColor;
        } else {
            sender.layer.borderColor = Constants.RED_COLOR.cgColor;
        }
    }
    
    // MARK: Private functions
    
    private func registerUser(parameters: [String: String?]) -> Promise<[HttpResponseMessage]>{
        return Promise {seal in
            Alamofire.request(Constants.REGISTER_URL as URLConvertible, method: .post, parameters: parameters as Parameters, encoding: JSONEncoding.default).responseSwiftyJSON{ response in
                UIViewController.removeSpinner(spinner: self.spinner);
                self.hideErrorViews();
                var errors: [HttpResponseMessage] = [];
                switch response.result {
                case .failure(let error):
                    seal.reject(error);
                    break;
                case .success:
                    if (response.response?.statusCode == 400) {
                        print(response.value!);
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
