//
//  LoginController.swift
//  ios
//
//  Created by Sebastien Cadorette on 2019-01-21.
//  Copyright © 2019 LOG3000 equipe 12. All rights reserved.
//

import UIKit
import Alamofire

class LoginController: UIViewController {
    @IBOutlet var emailField: UITextField!
    @IBOutlet var passwordField: UITextField!
    @IBOutlet var validationLabel: UILabel!

    @IBOutlet var loginButton: UIButton!

    @IBAction func loginButton(_ sender: Any) {
        let validEmail: Bool = isValidEmail(testStr: emailField.text!);
        validationLabel.text = validEmail ? "Valid" : "Invalid";
        
        if(validEmail){
            // send request
//            let answer = wait Alamofire.request("url", method: .get);
        }
    }

    func isValidEmail(testStr: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegEx)

        return emailTest.evaluate(with: testStr)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
}
