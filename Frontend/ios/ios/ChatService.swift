//
//  ChatService.swift
//  ios
//
//  Created by Sebastien Cadorette on 2019-02-01.
//  Copyright © 2019 LOG3000 equipe 12. All rights reserved.
//

import Foundation
import SwiftSignalRClient

let CHAR_URL = "http://192.168.1.6:5000/signalr"
//let USER_TOKEN = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1bmlxdWVfbmFtZSI6InNlYmFzIiwibmFtZWlkIjoiMTc4ZDAyMTYtZjMzYS00OWE1LWIxZWYtNWY1NDVhMGE2NTkzIiwibmJmIjoxNTQ4Nzk3NzEyLCJleHAiOjYxNTQ4Nzk3NjUyLCJpYXQiOjE1NDg3OTc3MTIsImlzcyI6IjEwLjIwMC4yNy4xNjo1MDAxIiwiYXVkIjoiMTAuMjAwLjI3LjE2OjUwMDEifQ.Am6W-nUbklrC4cV-w2NxhI56Df9awzFdXhtwGoihqDU"

class ChatService {
    private let hubConnection: HubConnection;
    private let messageCallback: (Message) -> Void
    
    init(onReceivedMessage: @escaping (Message)-> Void) {
        self.hubConnection = HubConnectionBuilder(url: URL(string: CHAR_URL)!)
            .withHttpConnectionOptions() { httpConnectionOptions in
                httpConnectionOptions.accessTokenProvider = { return USER_TOKEN; }}
            .build()
        self.messageCallback = onReceivedMessage
    }
    
    func connect() {
        self.hubConnection.start();
    }
}
