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
        
        let transition = CATransition();
        transition.duration = 0.3;
        transition.type = CATransitionType.reveal;
        transition.subtype = CATransitionSubtype.fromBottom;
        self.view.window!.layer.add(transition, forKey: kCATransition);
        
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func createNewCanvas(_ sender: Any) {
        var newCanvas: Canvas = Canvas()
        newCanvas.canvasId = UUID().uuidString
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
    
    public func saveNewCanvas(canvas: Canvas) {
        currentCanvas = canvas
        CanvasService.SaveOnline(canvas: canvas).done { (success) in
            let canvasController = UIStoryboard(name: "Canvas", bundle: nil).instantiateViewController(withIdentifier: "CanvasController") as! CanvasController
            self.present(canvasController, animated: true, completion: nil);
        }
    }
}
