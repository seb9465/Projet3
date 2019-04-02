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
        
        self.initErrorViews();
        
        super.viewDidLoad();
    }
    
    public func initErrorViews() -> Void {
        self.emailErrorIcon.isHidden = true;
        self.emailErrorText.isHidden = true;
        self.pwdErrorIcon.isHidden = true;
        self.pwdErrorText.isHidden = true;
    }
    
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
                if (response.result.isFailure) {
                    return;
                }
                
                if (response.response?.statusCode == 400) {
                    for err in response.value! {
                        let messageJSON: String = err.1.rawString()!;
                        self.showErrors(messageJSON: messageJSON);
                    }
                } else if (response.response?.statusCode == 200) {
                    self.showOkAlert();
                }
                
                seal.fulfill(response);
            };
        }
    }
    
    private func showErrors(messageJSON: String) -> Void {
        let jsonData = messageJSON.data(using: .utf8);
        let message: HttpResponseMessage = try! JSONDecoder().decode(HttpResponseMessage.self, from: jsonData!);
        
        switch message.code {
        case "DuplicateEmail":
            self.emailErrorText.text = "Email already exists";
            self.emailErrorIcon.isHidden = false;
            self.emailErrorText.isHidden = false;
            break;
        case "DuplicateUserName":
            self.emailErrorText.text = "Username already exists";
            
            break;
        default:
            break;
        }
        
        
    }
    
    private func showOkAlert() -> Void {
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
