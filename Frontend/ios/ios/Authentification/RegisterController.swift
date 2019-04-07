//
//  RegisterController.swift
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
let PWD_REGEX = NSPredicate(format: "SELF MATCHES %@", "(?=.*[a-z])(?=.*[A-Z])(?=.*[!@#$&*]).{8,15}");

class RegisterController: UIViewController {
    
    // MARK: Outlets
    
    @IBOutlet weak var firstNameField: UITextField!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var lastNameField: UITextField!
    @IBOutlet var registerButton: RoundedCorners!
    
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
        
        self.registerButton.isUserInteractionEnabled = false;
        self.registerButton.alpha = 0.5;
        
        self.setupAddTargetWithoutErrorsTextFields();
        
        super.viewDidLoad();
    }
    
    // MARK: Actions
    
    @IBAction func registerButtonPressed(_ sender: UIButton) {
        self.view.endEditing(true);
        
        let registrationViewModel: RegistrationViewModel = RegistrationViewModel(firstName: self.firstNameField.text!, lastName: self.lastNameField.text!, email: self.emailField.text!, username: self.usernameField.text!, password: self.passwordField.text!);
        
        spinner = UIViewController.displaySpinner(onView: self.view);
        
        registerUser(parameters: registrationViewModel.toJson());
    }
    
    // MARK: Actions
    
    @IBAction func goBackPressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func validateFirstNameField(_ sender: UITextField) {
        sender.layer.borderWidth = 1.0;
        sender.layer.cornerRadius = 5;
        
        if(sender.text!.isEmpty){
            sender.layer.borderColor = Constants.RED_COLOR.cgColor;
            self.firstNameErrorText.text = "First Name field must not be empty";
            self.firstNameErrorText.isHidden = false;
            self.firstNameErrorIcon.isHidden = false;
        } else {
            sender.layer.borderColor = UIColor.green.cgColor;
            self.firstNameErrorText.isHidden = true;
            self.firstNameErrorIcon.isHidden = true;
        }
    }
    
    @IBAction func validateLastNameField(_ sender: UITextField) {
        sender.layer.borderWidth = 1.0;
        sender.layer.cornerRadius = 5;
        
        if (sender.text!.isEmpty){
            sender.layer.borderColor = Constants.RED_COLOR.cgColor;
            self.lastNameErrorText.text = "Last Name field must not be empty";
            self.lastNameErrorText.isHidden = false;
            self.lastNameErrorIcon.isHidden = false;
        } else {
            sender.layer.borderColor = UIColor.green.cgColor;
            self.lastNameErrorText.isHidden = true;
            self.lastNameErrorIcon.isHidden = true;
        }
    }
    
    @IBAction func validateUserNameField(_ sender: UITextField) {
        sender.layer.borderWidth = 1.0;
        sender.layer.cornerRadius = 5;
        
        sender.layer.borderColor = Constants.RED_COLOR.cgColor;
        self.usernameErrorText.isHidden = false;
        self.usernameErrorIcon.isHidden = false;
        
        let charSet: CharacterSet = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890._-");
        
        if (sender.text!.isEmpty){
            self.usernameErrorText.text = "Username field must not be empty";
        } else if (sender.text!.rangeOfCharacter(from: charSet.inverted) != nil) {
            self.usernameErrorText.text = "Invalid username format";
        } else {
            sender.layer.borderColor = UIColor.green.cgColor;
            self.usernameErrorText.isHidden = true;
            self.usernameErrorIcon.isHidden = true;
        }
    }
    
    @IBAction func validateEmailField(_ sender: UITextField) {
        sender.layer.borderWidth = 1.0;
        sender.layer.cornerRadius = 5;
        
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
        sender.layer.cornerRadius = 5;
        
        if(PWD_REGEX.evaluate(with: sender.text)){
            sender.layer.borderColor = UIColor.green.cgColor;
            self.pwdErrorText.isHidden = true;
            self.pwdErrorIcon.isHidden = true;
        } else {
            sender.layer.borderColor = Constants.RED_COLOR.cgColor;
            
            self.pwdErrorText.text = self.getPasswordErrors(password: sender.text!);
            self.pwdErrorText.isHidden = false;
            self.pwdErrorIcon.isHidden = false;
        }
    }
    
    // MARK: Private functions
    
    private func hideErrorViews() -> Void {
        self.firstNameErrorIcon.isHidden = true;
        self.firstNameErrorText.isHidden = true;
        self.lastNameErrorIcon.isHidden = true;
        self.lastNameErrorText.isHidden = true;
        self.usernameErrorIcon.isHidden = true;
        self.usernameErrorText.isHidden = true;
        self.emailErrorIcon.isHidden = true;
        self.emailErrorText.isHidden = true;
        self.pwdErrorIcon.isHidden = true;
        self.pwdErrorText.isHidden = true;
    }
    
    private func getPasswordErrors(password: String) -> String {
        var errorMsg = "Password requires"
        
        if (password.rangeOfCharacter(from: CharacterSet.uppercaseLetters) == nil) {
            errorMsg += " at least one upper case letter,"
        }
        if (password.rangeOfCharacter(from: CharacterSet.lowercaseLetters) == nil) {
            errorMsg += " at least one lower case letter,"
        }
        if (password.rangeOfCharacter(from: CharacterSet.decimalDigits) == nil) {
            errorMsg += " at least one number,"
        }
        if password.count < 8 {
            errorMsg += " at least eight characters,"
        } else if password.count > 15 {
            errorMsg += " a maximum of 15 characters,"
        }
        if (!password.containsSpecialCharacter) {
            errorMsg += " at least one special character,"
        }
        errorMsg.removeLast();
        
        return errorMsg;
    }
    
    private func registerUser(parameters: [String: String]) -> Void {
        Alamofire.request(Constants.REGISTER_URL as URLConvertible, method: .post, parameters: parameters as Parameters, encoding: JSONEncoding.default).responseSwiftyJSON{ response in
            UIViewController.removeSpinner(spinner: self.spinner);
            self.hideErrorViews();
            var errors: [HttpResponseMessage] = [];
            
            switch response.response?.statusCode {
            case 400:
                for err in response.value! {
                    let messageJSON: String = err.1.rawString()!;
                    let message: HttpResponseMessage = self.showError(messageJSON: messageJSON);
                    errors.append(message);
                }
                break;
            case 200:
                self.present(self.buildOkAlert(), animated: true);
                break;
            default:
                self.present(self.buildFailureAlert(), animated: true);
                break;
            }
        };
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
    
    private func buildFailureAlert() -> UIAlertController {
        let alert: UIAlertController = UIAlertController(title: "Something went wrong", message: nil, preferredStyle: .alert);
        
        let okAction: UIAlertAction = UIAlertAction(title: "Damn, alright I'll try again.", style: .default, handler: nil);
        
        alert.addAction(okAction);
        
        return alert;
    }
    
    private func setupAddTargetWithoutErrorsTextFields() {
        self.firstNameField.addTarget(self, action: #selector(textFieldsWithoutErrors),
                                    for: .editingChanged)
        self.lastNameField.addTarget(self, action: #selector(textFieldsWithoutErrors),
                                     for: .editingChanged)
        self.usernameField.addTarget(self, action: #selector(textFieldsWithoutErrors),
                                        for: .editingChanged)
        self.emailField.addTarget(self, action: #selector(textFieldsWithoutErrors),
                                              for: .editingChanged)
        self.passwordField.addTarget(self, action: #selector(textFieldsWithoutErrors),
                                  for: .editingChanged)
    }
    
    // MARK: Object functions
    
    @objc private func returnTextView(gesture: UIGestureRecognizer) {
        guard activeField != nil else {
            return
        }
        
        activeField?.resignFirstResponder()
        activeField = nil
    }
    
    /**
     When keyboard opens, it will enable the scrolling.
    */
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
    
    /**
     When keyboard closes, it will disable the scrolling.
    */
    @objc func keyboardWillHide(notification: NSNotification) {
        UIView.animate(withDuration: 0.3) {
            guard let heightConstraint = self.constraintContentHeight else { return }
            guard let keybHeight = self.keyboardHeight else { return }
            heightConstraint.constant -= keybHeight
        }
        
        self.keyboardHeight = nil
    }
    
    /**
     Makes the Register button enabled while the fields are not filled or errors are still present.
    */
    @objc func textFieldsWithoutErrors(sender: UITextField) -> Void {
        sender.text = sender.text?.trimmingCharacters(in: .whitespaces)
        
        guard
            let firstName = self.firstNameErrorIcon, firstName.isHidden && !self.firstNameField.text!.isEmpty,
            let lastName = self.lastNameErrorIcon, lastName.isHidden && !self.lastNameField.text!.isEmpty,
            let username = self.usernameErrorIcon, username.isHidden && !self.usernameField.text!.isEmpty,
            let email = self.emailErrorIcon, email.isHidden && !self.emailField.text!.isEmpty,
            let password = self.pwdErrorIcon, password.isHidden && !self.passwordField.text!.isEmpty
        else
        {
            self.registerButton.alpha = 0.5;
            self.registerButton.isUserInteractionEnabled = false;
            return
        }
        
        self.registerButton.alpha = 1;
        self.registerButton.isUserInteractionEnabled = true;
    }
}

// MARK: UITextFieldDelegate extension

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

// MARK: String extension

extension String {
    var containsSpecialCharacter: Bool {
        let regex = ".*[^A-Za-z0-9].*"
        let testString = NSPredicate(format:"SELF MATCHES %@", regex)
        return testString.evaluate(with: self)
    }
}
