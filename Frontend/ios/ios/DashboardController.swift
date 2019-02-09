//
//  DashboardController.swift
//  ios
//
//  Created by William Sevigny on 2019-02-05.
//  Copyright © 2019 LOG3000 equipe 12. All rights reserved.
//

import UIKit
import JWTDecode
import Alamofire

class DashboardController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var UsernameLabel: UILabel!
    
    override func viewDidLoad() {
        self.navigationItem.setHidesBackButton(true, animated:true);
        super.viewDidLoad();
        let token = UserDefaults.standard.string(forKey: "token");
        let jwt = try! decode(jwt: token!)
        UsernameLabel.text = jwt.claim(name: "unique_name").string
    }
}
