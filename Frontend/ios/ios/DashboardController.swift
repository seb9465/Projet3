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
    
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet var logoutButton: RoundedCorners!
    
    override func viewDidLoad() { self.navigationItem.setHidesBackButton(true, animated:true);
        super.viewDidLoad();
        let token = UserDefaults.standard.string(forKey: "token");
        let jwt = try! decode(jwt: token!)
        usernameLabel.text = jwt.claim(name: "unique_name").string
        ChatService.shared.initOnReceivingMessage(insertMessage:{_ in });
        ChatService.shared.connectToUserChatRooms();
    }
    
    @IBAction func logoutButton(_ sender: Any) {
        AuthentificationAPI.logout()
        UserDefaults.standard.removePersistentDomain(forName: "token");
        
        let mainView: UIStoryboard = UIStoryboard(name: "Main", bundle: nil);
        let viewcontroller : UIViewController = mainView.instantiateViewController(withIdentifier: "LoginStoryboard") as UIViewController;
        self.present(viewcontroller, animated: false);
    }
}
