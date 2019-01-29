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
    @IBOutlet var sendMessageButton: UIButton!
    
    let chatURL = "http://10.200.19.14:5000/signalr"
    var hubConnection: HubConnection!
    
    @IBAction func connectButtonTrigger(_ sender: Any) {
        self.hubConnection.invoke(method: "ConnectToGroup", arguments: [""], invocationDidComplete: { error in
            if (error == nil) {
                print("connected to the group");
                self.statusLabel.text = "Connected";
                self.statusLabel.textColor = UIColor.green;
                self.connectButton.isEnabled = false;
                self.sendMessageButton.isEnabled = true;
            } else {
                print("error");
                print(error as Any);
                self.statusLabel.text = "Error connecting to server!"
                self.statusLabel.textColor = UIColor.red;
            }
        })
    }
    
    @IBAction func sendMessageTrigger(_ sender: Any) {
            self.hubConnection.invoke(method: "SendMessage", arguments: ["hello"], invocationDidComplete: { args in
                    print("Message sent")
                })
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.sendMessageButton.isEnabled = false;
        
        // Token avec /api/token dans postman avec un user et un password en param
        self.hubConnection = HubConnectionBuilder(url: URL(string: chatURL)!)
            .withHttpConnectionOptions() { httpConnectionOptions in
                httpConnectionOptions.accessTokenProvider = { return "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1bmlxdWVfbmFtZSI6InNlYmFzIiwibmFtZWlkIjoiMTc4ZDAyMTYtZjMzYS00OWE1LWIxZWYtNWY1NDVhMGE2NTkzIiwibmJmIjoxNTQ4Nzk3NzEyLCJleHAiOjYxNTQ4Nzk3NjUyLCJpYXQiOjE1NDg3OTc3MTIsImlzcyI6IjEwLjIwMC4yNy4xNjo1MDAxIiwiYXVkIjoiMTAuMjAwLjI3LjE2OjUwMDEifQ.Am6W-nUbklrC4cV-w2NxhI56Df9awzFdXhtwGoihqDU" }}
            .build()
        
        self.hubConnection.start()
        

        
        self.hubConnection.on(method: "ReceiveMessage", callback: { args, typeConverter in
            print("Message Sent")
            print(args);
            let message = try! typeConverter.convertFromWireType(obj: args[0], targetType: String.self)
            self.receivedMessage.text = message
        }
        )
    }
}
