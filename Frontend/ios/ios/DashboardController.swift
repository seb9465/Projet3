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
    
    // MARK: Outlets
    
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet var logoutButton: RoundedCorners!
    @IBOutlet var viewContainerChat: UIView!
    
    // MARK: Timing functions
    
    override func viewDidLoad() { self.navigationItem.setHidesBackButton(true, animated:true);
        super.viewDidLoad();
        let token = UserDefaults.standard.string(forKey: "token");
        let jwt = try! decode(jwt: token!)
        usernameLabel.text = jwt.claim(name: "unique_name").string
        
        ChatService.shared.connectToUserChatRooms();
        ChatService.shared.initOnReceivingMessage(insertMessage:{_ in }, updateChatRooms: { });
        ChatService.shared.connectToHub();
        
        self.viewContainerChat.sizeToFit(); // Adjusting frame size
        self.viewContainerChat.isHidden = true;
        self.viewContainerChat.layer.cornerRadius = Constants.ChatView.cornerRadius;
        self.viewContainerChat.layer.shadowColor = Constants.ChatView.shadowColor;
        self.viewContainerChat.layer.shadowOffset = Constants.ChatView.shadowOffset;
        self.viewContainerChat.layer.shadowOpacity = Constants.ChatView.shadowOpacity;
        self.viewContainerChat.layer.shadowRadius = Constants.ChatView.shadowRadius;
        self.viewContainerChat.layer.masksToBounds = false;
    }
    
    // MARK: Actions
    
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
        if (self.viewContainerChat.isHidden) {
            self.viewContainerChat.isHidden = false;
        } else {
            self.viewContainerChat.isHidden = true;
        }
    }
}
