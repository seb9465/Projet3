//
//  LoginController.swift
//  ios
//
//  Created by Sebastien Cadorette on 2019-01-21.
//  Copyright © 2019 LOG3000 equipe 12. All rights reserved.
//

import UIKit
import SwiftSignalRClient

let CHAT_URL = "http://192.168.1.6:5000/signalr";
//let CHAT_URL = "http://10.200.19.14:5000/signalr";
let USER_TOKEN = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1bmlxdWVfbmFtZSI6InNlYmFzIiwibmFtZWlkIjoiMTc4ZDAyMTYtZjMzYS00OWE1LWIxZWYtNWY1NDVhMGE2NTkzIiwibmJmIjoxNTQ4Nzk3NzEyLCJleHAiOjYxNTQ4Nzk3NjUyLCJpYXQiOjE1NDg3OTc3MTIsImlzcyI6IjEwLjIwMC4yNy4xNjo1MDAxIiwiYXVkIjoiMTAuMjAwLjI3LjE2OjUwMDEifQ.Am6W-nUbklrC4cV-w2NxhI56Df9awzFdXhtwGoihqDU";

class ChatController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var statusLabel: UILabel!
    @IBOutlet var receivedMessage: UILabel!
    @IBOutlet var connectButton: UIButton!
    @IBOutlet var sendMessageButton: UIButton!
    @IBOutlet var chatTableView: UITableView!
    @IBOutlet var sendBtn: UIButton!
    @IBOutlet var msgTextField: UITextField!
    
    var hubConnection: HubConnection!;
    var messages: [String] = [];
    
    @IBAction func connectButtonTrigger(_ sender: Any) {
        self.hubConnection.invoke(method: "ConnectToGroup", arguments: [""], invocationDidComplete: { error in
            if (error == nil) {
                self.statusLabel.text = "Connected";
                self.statusLabel.textColor = UIColor.green;
                self.connectButton.isEnabled = false;
                self.sendMessageButton.isEnabled = true;
            } else {
                self.statusLabel.text = "Error connecting to server!"
                self.statusLabel.textColor = UIColor.red;
            }
        })
    }
    
    @IBAction func sendMessageTrigger(_ sender: Any) {
        self.hubConnection.invoke(method: "SendMessage", arguments: ["hello"], invocationDidComplete: { _ in });
    }
    
    @IBAction func sendBtn(_ sender: Any) {
        let message = msgTextField.text;
        if (message != "") {
            self.hubConnection.invoke(method: "SendMessage", arguments: [message], invocationDidComplete: { error in
                if let e = error {
                    self.addMessage(message: "Error: \(e)");
                }
                self.msgTextField.text = "";
            });
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        self.chatTableView.delegate = self;
        self.chatTableView.dataSource = self;
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.sendMessageButton.isEnabled = false;
        
        // Token avec /api/token dans postman avec un user et un password en param
        self.hubConnection = HubConnectionBuilder(url: URL(string: CHAT_URL)!)
            .withHttpConnectionOptions() { httpConnectionOptions in
                httpConnectionOptions.accessTokenProvider = { return USER_TOKEN; }}
            .build();
        
        self.hubConnection.start();
        
        self.hubConnection.on(method: "ReceiveMessage", callback: { args, typeConverter in
            let user = try! typeConverter.convertFromWireType(obj: args[0], targetType: String.self);
            let message = try! typeConverter.convertFromWireType(obj: args[1], targetType: String.self);
            let timestamp = try! typeConverter.convertFromWireType(obj: args[2], targetType: String.self);
            self.addMessage(message: "\(user!) (\(timestamp!))\t : \(message!)");
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.hubConnection.stop();
    }
    
    private func addMessage(message: String) {
        self.messages.append(message);
        self.chatTableView.beginUpdates();
        self.chatTableView.insertRows(at: [IndexPath(row: messages.count - 1, section: 0)], with: .automatic);
        self.chatTableView.endUpdates();
        self.chatTableView.scrollToRow(at: IndexPath(item: messages.count - 1, section: 0), at: .bottom, animated: true);
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count = -1;
        count = self.messages.count;
        return count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TextCell", for: indexPath);
        let row = indexPath.row;
        cell.textLabel?.text = messages[row];
        return cell;
    }
    
    fileprivate func connectionDidOpen() {
        toggleUI(isEnabled: true);
    }
    
    fileprivate func connectionDidFailToOpen(error: Error) {
        addMessage(message: "Connection failed to start. Error \(error)");
        toggleUI(isEnabled: false);
    }
    
    fileprivate func connectionDidClose(error: Error?) {
        var message = "Connection closed.";
        if let e = error {
            message.append(" Error: \(e)");
        }
        addMessage(message: message)
        toggleUI(isEnabled: false);
    }
    
    func toggleUI(isEnabled: Bool) {
        sendBtn.isEnabled = isEnabled;
        msgTextField.isEnabled = isEnabled;
    }
}
