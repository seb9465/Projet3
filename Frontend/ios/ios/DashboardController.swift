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
    @IBOutlet var viewContainerChat: UIView!
    
    private var isChatOpen: Bool = false;
    
    override func viewDidLoad() { self.navigationItem.setHidesBackButton(true, animated:true);
        super.viewDidLoad();
        let token = UserDefaults.standard.string(forKey: "token");
        let jwt = try! decode(jwt: token!)
        usernameLabel.text = jwt.claim(name: "unique_name").string
        
        ChatService.shared.initOnReceivingMessage(insertMessage:{_ in });
        ChatService.shared.connectToUserChatRooms();
        ChatService.shared.connectToHub();
        
        self.viewContainerChat.sizeToFit(); // Adjusting frame size
        self.viewContainerChat.isHidden = true;
        self.viewContainerChat.layer.borderWidth = 1;
        self.viewContainerChat.layer.borderColor = UIColor.black.cgColor;
    }
    
    @IBAction func logoutButton(_ sender: Any) {
        AuthentificationAPI.logout()
        UserDefaults.standard.removePersistentDomain(forName: "token");
        
        let mainView: UIStoryboard = UIStoryboard(name: "Main", bundle: nil);
        let viewController : UIViewController = mainView.instantiateViewController(withIdentifier: "LoginStoryboard") as UIViewController;
        
        let transition = CATransition();
        transition.duration = 0.3;
        transition.type = CATransitionType.reveal;
        transition.subtype = CATransitionSubtype.fromBottom;
        self.view.window!.layer.add(transition, forKey: kCATransition);
        
        self.present(viewController, animated: false, completion: nil);
    }
    @IBAction func windowChatTrigger(_ sender: Any) {
        if (self.isChatOpen) {
            self.viewContainerChat.isHidden = true;
            self.isChatOpen = false;
        } else {
            self.viewContainerChat.isHidden = false;
            self.isChatOpen = true;
        }
    }
}
