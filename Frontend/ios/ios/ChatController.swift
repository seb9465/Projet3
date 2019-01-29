//
//  LoginController.swift
//  ios
//
//  Created by Sebastien Cadorette on 2019-01-21.
//  Copyright © 2019 LOG3000 equipe 12. All rights reserved.
//

import UIKit
import SwiftSignalRClient

class ChatController: UIViewController, UITextFieldDelegate {
    @IBOutlet var statusLabel: UILabel!
    @IBOutlet var receivedMessage: UILabel!
    @IBOutlet var connectButton: UIButton!
    
    
    var hubConnection: HubConnection!
    
    @IBAction func connectButtonTrigger(_ sender: Any) {
        self.hubConnection.invoke(method: "ConnectToGroup", arguments: [], invocationDidComplete: { error in
            if (error == nil) {
                print("connected to the group")
                self.statusLabel.text = "Connected"
                self.statusLabel.textColor = UIColor.green;
                self.connectButton.isEnabled = false;
            } else {
                print("error");
                print(error);
            }
        })
    }
    
    let chatURL = "http://10.200.19.14:5000/signalr"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //let query: [String: String] = ["parameterA": "valueA", "parameterB": "valueB"]
        self.hubConnection = HubConnectionBuilder(url: URL(string: chatURL)!)
            .build()
        self.hubConnection.start()
        
//        self.hubConnection.invoke(method: "SendMessage", arguments: ["hello"], invocationDidComplete: { args in
//            print("Message sent")
//            })
        
        self.hubConnection.on(method: "ReceiveMessage", callback: { args, typeConverter in
            print("Message Sent")
            print(args);
            let message = try! typeConverter.convertFromWireType(obj: args[0], targetType: String.self)
            self.receivedMessage.text = message
        }
        )
    }
}
