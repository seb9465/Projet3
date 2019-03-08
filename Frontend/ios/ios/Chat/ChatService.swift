//
//  ChatService.swift
//  ios
//
//  Created by Sebastien Cadorette on 2019-02-09.
//  Copyright © 2019 LOG3000 equipe 12. All rights reserved.
//

import Foundation
import SwiftSignalRClient
import PromiseKit
import AVFoundation
class ChatService {
    var hubConnection: HubConnection;
    var _members: Members;
    
    init() {
        self.hubConnection = HubConnectionBuilder(url: URL(string: Constants.CHAT_URL)!)
            .withHttpConnectionOptions() { httpConnectionOptions in
                httpConnectionOptions.accessTokenProvider = { return USER_TOKEN; }}
            .build();
        self._members = Members();
    }
    
    public func connectToHub() -> Void {
        self.hubConnection.start();
    }
    
    public func initOnReceivingMessage(currentMemberName: String, insertMessage: @escaping (_ message: Message) -> Void) {
        self.hubConnection.on(method: "ReceiveMessage", callback: { args, typeConverter in
            let user = try! typeConverter.convertFromWireType(obj: args[0], targetType: String.self);
            let message = try! typeConverter.convertFromWireType(obj: args[1], targetType: String.self);
            let timestamp = try! typeConverter.convertFromWireType(obj: args[2], targetType: String.self);

            var memberFromMessage: Member = Member(
                name: user!,
                color: .random
            );
            
            if (!self._members.addMember(member: memberFromMessage)) {
                memberFromMessage = self._members.getMemberByName(memberName: user!);
            }
            
            let newMessage = Message(
                member: memberFromMessage,
                text: message!,
                timestamp: timestamp!,
                messageId: UUID().uuidString
            );
            
            if (user != currentMemberName) {
                insertMessage(newMessage);
                SoundNotification.play(sound: Sound.SendMessage);
            }
        });
    }
    
    public func initOnAnotherUserConnection(insertMessage: @escaping (_ message: Message) -> Void) -> Void {
        self.hubConnection.on(method: "SystemMessage", callback: { args, typeConverter in
            let message = try! typeConverter.convertFromWireType(obj: args[0], targetType: String.self);
            
            let sysMember = Member(
                name: "SYSTEM",
                color: .random
            );
            
            let newMessage = Message(
                member: sysMember,
                text: message!,
                timestamp: Constants.formatter.string(from: Date()),
                messageId: UUID().uuidString
            );
            
            insertMessage(newMessage);
        });
    }
    
    public func connectToGroup() -> Void {
        self.hubConnection.on(method: "ClientIsConnected", callback: { args, typeConverter in
            self.hubConnection.invoke(method: "ConnectToGroup", arguments: [""], invocationDidComplete: { error in
                if (error != nil) {
                    print("Error connecting to server!")
                    print(error as Any);
                }
                print("Connected to the group");
            });
        });
    }
    
    public func disconnectFromHub() -> Void {
        self.hubConnection.stop();
    }
    
    public func sendMessage(message: Message, insertMessage: @escaping (_ message: Message) -> Void) -> Void {
        self.hubConnection.invoke(method: "SendMessage", arguments: [message.text], invocationDidComplete: { error in
            if let e = error {
                print("ERROR");
                print(e);
            }
            SoundNotification.play(sound: Sound.ReceiveMessage);
            insertMessage(message);
        });
    }
}
