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

class Channel {
    public var name: String;
    public var connected: Bool;
    
    init(name: String, connected: Bool) {
        self.name = name;
        self.connected = connected;
    }
}

class ConnectionMessage {
    public var username: String;
    public var canvasId: String;
    public var channelId: String;
    
    init(Username: String?="", CanvasId: String?="", ChannelId: String?="") {
        self.username = Username!;
        self.canvasId = CanvasId!;
        self.channelId = ChannelId!;
    }
}

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
        print("Connect to hub");
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
//        self.hubConnection.on(method: "SystemMessage", callback: { args, typeConverter in
//            let message = try! typeConverter.convertFromWireType(obj: args[0], targetType: String.self);
//
//            let sysMember = Member(
//                name: "SYSTEM",
//                color: .random
//            );
//
//            let newMessage = Message(
//                member: sysMember,
//                text: message!,
//                timestamp: Constants.formatter.string(from: Date()),
//                messageId: UUID().uuidString
//            );
//
//            insertMessage(newMessage);
//        });
//        self.hubConnection.on(method: "ConnectToChannelSender", callback: { args, typeConverter in
//            print("On ConnectToChannelSender");
//            print(args);
//            let message: ConnectionMessage = try! typeConverter.convertFromWireType(obj: args[0], targetType: ConnectionMessage.self)!;
//
//            let sysMember = Member(
//                name: "SYSTEM",
//                color: .random
//            );
//
//            let newMessage = Message(
//                member: sysMember,
//                text: message.username + " just connected",
//                timestamp: Constants.formatter.string(from: Date()),
//                messageId: UUID().uuidString
//            );
//
//            insertMessage(newMessage);
//        });
    }
    
    public func connectToGroup(insertMessage: @escaping (_ message: Message) -> Void) -> Void {
        self.hubConnection.on(method: "ClientIsConnected", callback: { args, typeConverter in
            print("On ClientIsConnected");
            print(args);
            let message: String = try! typeConverter.convertFromWireType(obj: args[0], targetType: String.self)!;
            
            let sysMember = Member(
                name: "SYSTEM",
                color: .random
            );
            
            let newMessage = Message(
                member: sysMember,
                text: message,
                timestamp: Constants.formatter.string(from: Date()),
                messageId: UUID().uuidString
            );
            
            insertMessage(newMessage);
            
            
            
            self.hubConnection.invoke(method: "FetchChannels", arguments: [], invocationDidComplete: { error in
                print("Invoked FetchChannels");
                if let e = error {
                    print("ERROR while invoking FetchChannels");
                    print(e);
                }
            });
            self.hubConnection.on(method: "FetchChannels", callback: { args, typeConverter in
                print("On FetchChannels");
                let channels: Any = try! typeConverter.convertFromWireType(obj: args[0], targetType: Any.self)!
                print(channels);
            });
            
//            self.hubConnection.invoke(method: "ConnectToChannel", arguments: [ConnectionMessage(ChannelId: "general")], invocationDidComplete: { error in
//                print("Invoked ConnectToChannel avec argument 'general'.");
//                if let e = error {
//                    print("ERROR while invoking ConnectToChannel.");
//                    print(e);
//                }
//            })
//
//            self.hubConnection.on(method: "ConnectToChannel", callback: { args, typeConverter in
//                print("On ConnectToChannel");
//                print(args);
//                print(typeConverter);
//            })
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
