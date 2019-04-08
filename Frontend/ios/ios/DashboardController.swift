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
    
    // MARK: - Attributes
    
    // MARK: - Outlets
    
    @IBOutlet weak var galleryView: UIView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet var logoutButton: RoundedCorners!
    @IBOutlet var viewContainerChat: UIView!
    @IBOutlet var windowChatButton: RoundedCorners!
    @IBOutlet var chatNotifLabel: UILabel!
    
    // MARK: - Timing functions
    
    override func viewDidLoad() { self.navigationItem.setHidesBackButton(true, animated:true);
        super.viewDidLoad();
        let token = UserDefaults.standard.string(forKey: "token");
        let jwt = try! decode(jwt: token!)
        usernameLabel.text = jwt.claim(name: "unique_name").string
        
        ChatService.shared.connectToUserChatRooms();
        ChatService.shared.initOnReceivingMessage(insertMessage:{_ in }, updateChatRooms: { });
        ChatService.shared.connectToHub();
        
        self.setChatViewContainer();
        
        self.setChatNotifLabel();
        
        ChatService.shared.afkMessagesDidChangeClosure = {
            let channels: [String: [Message]] = ChatService.shared.messagesWhileAFK;
            print(channels);
            var counter: Int = 0;
            for channel in channels {
                counter += (channels[channel.key]?.count)!;
            }
            
            if (counter > 0) {
                self.chatNotifLabel.isHidden = false;
                self.chatNotifLabel.text = String(counter);
            } else {
                self.chatNotifLabel.isHidden = true;
                self.chatNotifLabel.text = "";
            }
        }
    }
    
    // MARK: - Private functions
    
    private func setChatViewContainer() -> Void {
        self.viewContainerChat.sizeToFit();
        self.viewContainerChat.isHidden = true;
        self.viewContainerChat.layer.cornerRadius = Constants.ChatView.cornerRadius;
        self.viewContainerChat.layer.shadowColor = Constants.ChatView.shadowColor;
        self.viewContainerChat.layer.shadowOffset = Constants.ChatView.shadowOffset;
        self.viewContainerChat.layer.shadowOpacity = Constants.ChatView.shadowOpacity;
        self.viewContainerChat.layer.shadowRadius = Constants.ChatView.shadowRadius;
        self.viewContainerChat.layer.masksToBounds = false;
    }
    
    private func setChatNotifLabel() -> Void {
        self.chatNotifLabel.layer.cornerRadius = self.chatNotifLabel.frame.width / 2;
        self.chatNotifLabel.layer.backgroundColor = Constants.Colors.DEFAULT_BLUE_COLOR.cgColor;
        self.chatNotifLabel.textColor = UIColor.white;
        self.chatNotifLabel.text = "";
        self.chatNotifLabel.textAlignment = .center;
        self.chatNotifLabel.isHidden = true;
    }
    
    private func saveNewCanvas(canvas: Canvas) {
        currentCanvas = canvas
        CanvasService.SaveOnline(canvas: canvas).done { (success) in
            let canvasController = UIStoryboard(name: "Canvas", bundle: nil).instantiateViewController(withIdentifier: "CanvasController") as! CanvasController
            self.present(canvasController, animated: true, completion: nil);
        }
    }
    
    // MARK: - Action functions
    
    @IBAction func logoutButton(_ sender: Any) {
        AuthentificationAPI.logout()
        
        UserDefaults.standard.removePersistentDomain(forName: "token");
        UserDefaults.standard.removePersistentDomain(forName: "id");
        
        let loginController: UIViewController = (self.storyboard?.instantiateViewController(withIdentifier: "LoginStoryboard"))!;
        self.present(loginController, animated: true, completion: nil);
    }
    
    @IBAction func createNewCanvas(_ sender: Any) {
        let token = UserDefaults.standard.string(forKey: "token");
        let jwt = try! decode(jwt: token!)
        let username = jwt.claim(name: "unique_name").string
        
        var newCanvas: Canvas = Canvas()
        newCanvas.canvasId = UUID().uuidString
        newCanvas.canvasAutor = username!
        canvasId = newCanvas.canvasId
        let createAlert = UIAlertController(title: "Create Canvas", message: "Please enter the new canvas name and it's visibility.", preferredStyle: .alert)
        createAlert.addTextField(configurationHandler: { (textField) in
            textField.placeholder = "Name"
        })
        let protectionAlert = UIAlertController(title: "Password Protection", message: "You can add a password to secure your canvas!", preferredStyle: .alert)
        protectionAlert.addAction(UIAlertAction(title: "No Thanks", style: .cancel, handler: { action in
            self.saveNewCanvas(canvas: newCanvas)
        }))
        protectionAlert.addAction(UIAlertAction(title: "Secure", style: .default, handler: { action in
            newCanvas.canvasProtection = protectionAlert.textFields![0].text!
            self.saveNewCanvas(canvas: newCanvas)
        }))
        protectionAlert.addTextField(configurationHandler: { (textField) in
            protectionAlert.actions[1].isEnabled = false
            textField.placeholder = "Password"
            textField.isSecureTextEntry = true
        })
        
        
        createAlert.addAction(UIAlertAction(title: "Private", style: .default, handler: { action in
            newCanvas.name = createAlert.textFields![0].text!
            newCanvas.canvasVisibility = "Private"
            
            self.present(protectionAlert, animated: true, completion: nil)
        }))
        createAlert.addAction(UIAlertAction(title: "Public", style: .default, handler:{ action in
            newCanvas.name = createAlert.textFields![0].text!
            newCanvas.canvasVisibility = "Public"
            self.present(protectionAlert, animated: true, completion: nil)
        }))
        createAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        createAlert.actions[0].isEnabled = false
        createAlert.actions[1].isEnabled = false
        
        NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object:createAlert.textFields?[0],
                                               queue: OperationQueue.main) { (notification) -> Void in
                                                let textField = createAlert.textFields?[0] as! UITextField
                                                createAlert.actions[0].isEnabled = !textField.text!.isEmpty
                                                createAlert.actions[1].isEnabled = !textField.text!.isEmpty
        }
        NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object:protectionAlert.textFields?[0],
                                               queue: OperationQueue.main) { (notification) -> Void in
                                                let textField = protectionAlert.textFields?[0] as! UITextField
                                                protectionAlert.actions[1].isEnabled = !textField.text!.isEmpty
        }
        self.present(createAlert, animated: true, completion: nil)
    }
    
    /**
     Removes the color animation on the Window Chat button, and opens or closes the ChatRoom view.
     */
    @IBAction func windowChatTrigger(_ sender: Any) {
        if (self.viewContainerChat.isHidden) {
            self.viewContainerChat.isHidden = false;
            self.view.addSubview(self.viewContainerChat);
            let view: UIView = self.view.subviews.last!;
            view.layoutIfNeeded();
        } else {
            self.viewContainerChat.isHidden = true;
            self.viewContainerChat.removeFromSuperview()
        }
    }
}
