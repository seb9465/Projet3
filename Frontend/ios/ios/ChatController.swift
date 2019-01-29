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
    @IBOutlet var label: UILabel!
    
    let chatURL = "http://10.200.19.14:5000/signalr"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //let query: [String: String] = ["parameterA": "valueA", "parameterB": "valueB"]
        let hubConnection = HubConnectionBuilder(url: URL(string: chatURL)!)
            .build()
        hubConnection.start()
        
        hubConnection.invoke(method: "ConnectToGroup", arguments: ["abcde"], invocationDidComplete: { error in
            if let e = error {
                self.label.text = "connected"
            }
        })
        
        
    }
}
