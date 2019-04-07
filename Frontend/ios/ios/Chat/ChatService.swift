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

class ChatService {
    
    static let shared = ChatService();
    
    // MARK: Attributes
    
    private var _hubConnection: HubConnection;
    private var _members: Members;
    private var _connected: Bool;
    private var _currentChannel: Channel!;
    private var _userChannels: ChannelsMessage;
    private var _serverChannels: ChannelsMessage;
    private var _messagesWhileAFK: [String: [Message]];
    
    
    // MARK: Constructor
    
    init() {
        print("[ CHAT ] INIT from ChatService");
        self._members = Members();
        
        self._hubConnection = HubConnectionBuilder(url: URL(string: Constants.CHAT_URL)!)
            .withHttpConnectionOptions() { httpConnectionOptions in
                httpConnectionOptions.accessTokenProvider = { return USER_TOKEN; }}
            .build();
        
        self._messagesWhileAFK = [:];
        self._currentChannel = nil;
        self._userChannels = ChannelsMessage();
        self._serverChannels = ChannelsMessage();
        self._connected = false;
    }
    
    // MARK: Getter - Setter
    
    public var currentChannel: Channel! {
        get { return self._currentChannel }
        set { self._currentChannel = newValue }
    }
    
    public var userChannels: ChannelsMessage {
        get { return self._userChannels }
    }
    
    public var serverChannels: ChannelsMessage {
        get { return self._serverChannels }
    }
    
    public var messagesWhileAFK: [ String: [Message]] {
        get { return self._messagesWhileAFK }
        set { self._messagesWhileAFK = newValue }
    }
    
    public func connectToHub() -> Void {
        print("[ CHAT ] Connect to hub");
        self._hubConnection.start();
        self._connected = true;
    }
    
    // MARK: Public functions
    
    public func initOnReceivingMessage(currentMemberName: String? = "", insertMessage: @escaping (_ message: Message) -> Void, updateChatRooms: @escaping () -> Void) {
        self.onSendMessage(currentMemberName: currentMemberName, insertMessage: insertMessage, updateChatRooms: updateChatRooms);
    }
    
    public func initOnAnotherUserConnection(insertMessage: @escaping (_ message: Message) -> Void) -> Void {
        self.onSelfConnectionToChannel(insertMessage: insertMessage);
        self.onUserConnectionToChannel(insertMessage: insertMessage);
        self.onUserDisconnectFromChannel(insertMessage: insertMessage);
    }
    
    public func invokeChannelsWhenConnected() -> Void {
        self._hubConnection.on(method: "ClientIsConnected", callback: { args, typeConverter in
            print("[ CHAT ] On ClientIsConnected");
            self.invokeFetchChannels();
        });
    }
    
    public func createNewChannel(channelName: String) -> Void {
        self.invokeCreateChannel(channelName: channelName);
    }
    
    public func onCreateChannel(updateChannelsFct: @escaping () -> Void) -> Void {
        self._hubConnection.on(method: "CreateChannel", callback: { args, typeConverter in
            let newChannelJson: String = try! typeConverter.convertFromWireType(obj: args[0], targetType: String.self)!;
            if let newChannelJsonData = newChannelJson.data(using: .utf8) {
                let newChannel: ChannelMessage = try! JSONDecoder().decode(ChannelMessage.self, from: newChannelJsonData);
                self._userChannels.channels.append(newChannel.channel);
            }
            updateChannelsFct();
        });
    }
    
    public func connectToGroup() -> Void {
        self.invokeConnectToChannel();
    }
    
    public func invokeFetchChannels() -> Void {
        self._hubConnection.invoke(method: "FetchChannels", arguments: [], invocationDidComplete: { error in
            print("[ CHAT ] Invoked FetchChannels");
            
            if let e = error {
                print("ERROR while invoking FetchChannels : ", e);
                self.invokeChannelsWhenConnected();
            }
        });
    }
    
    public func onFetchChannels(updateChannelsFct: @escaping () -> Void) -> Void {
        self._hubConnection.on(method: "FetchChannels", callback: { args, typeConverter in
            print("[ CHAT ] On FetchChannels");
            
            let channelsJson: String = try! typeConverter.convertFromWireType(obj: args[0], targetType: String.self)!;
            
            if let channelsJsonData = channelsJson.data(using: .utf8) {
                let channels: ChannelsMessage = try! JSONDecoder().decode(ChannelsMessage.self, from: channelsJsonData);
                self._userChannels.channels = [];
                self._serverChannels.channels = [];
                
                for channel in channels.channels {
                    if (channel.connected) {
                        self._userChannels.channels.append(channel);
                    } else {
                        self._serverChannels.channels.append(channel);
                    }
                }
                updateChannelsFct();
            }
        });
    }
    
    public func sendMessage(currentUser: String, message: Message, insertMessage: @escaping (_ message: Message) -> Void) -> Void {
        self.invokeSendMessage(currentUser: currentUser, message: message, insertMessage: insertMessage);
    }
    
    public func disconnectFromHub() -> Void {
        self._hubConnection.stop();
        self._connected = false;
        print("[ CHAT ] Connection stopped");
    }
    
    public func disconnectFromCurrentChatRoom() -> Void {
        let json = try? JSONEncoder().encode(ConnectionMessage(channelId: self._currentChannel.name));
        let jsondata: String = String(data: json!, encoding: .utf8)!;
        
        self._hubConnection.invoke(method: "DisconnectFromChannel", arguments: [jsondata], invocationDidComplete: { error in
            print("[ CHAT ] Invoked DisconnectFromChannel.");
            if let e = error {
                print("[ CHAT ] Error Invoking DisconnectFromChannel.");
                print(e);
            }
        });
    }
    
    public func connectToUserChatRooms() -> Void {
        self._hubConnection.on(method: "FetchChannels", callback: { args, typeConverter in
            print("[ CHAT ] On FetchChannels");
            
            let channelsJson: String = try! typeConverter.convertFromWireType(obj: args[0], targetType: String.self)!;
            
            if let channelsJsonData = channelsJson.data(using: .utf8) {
                let channels: ChannelsMessage = try! JSONDecoder().decode(ChannelsMessage.self, from: channelsJsonData);
                self._userChannels.channels = [];
                self._serverChannels.channels = [];
                
                for channel in channels.channels {
                    if (channel.connected) {
                        self._userChannels.channels.append(channel);
                        
                        let json = try? JSONEncoder().encode(ConnectionMessage(channelId: channel.name));
                        let jsondata: String = String(data: json!, encoding: .utf8)!;
                        
                        self._hubConnection.invoke(method: "ConnectToChannel", arguments: [jsondata], invocationDidComplete: { error in
                            print("[ CHAT ] Invoked ConnectToChannel.");
                            
                            if error != nil {
                                print("ERROR while invoking ConnectToChannel");
                            }
                        });
                    }
                }
            }
        });
        self.invokeChannelsWhenConnected();
    }
    
    // MARK: Private functions
    
    private func onSelfConnectionToChannel(insertMessage: @escaping (_ message: Message) -> Void) -> Void {
        self._hubConnection.on(method: "ConnectToChannelSender", callback: { args, typeConverter in
            print("[ CHAT ] On ConnectToChannelSender");
            
            let json: String = try! typeConverter.convertFromWireType(obj: args[0], targetType: String.self)!;
            if let jsonData = json.data(using: .utf8) {
                let obj: ConnectionMessage = try! JSONDecoder().decode(ConnectionMessage.self, from: jsonData);
                
                let sysMember = Member(
                    name: "SYSTEM",
                    color: .random
                );
                
                let newMessage = Message(
                    member: sysMember,
                    text: "You joined the room : " + obj.channelId,
                    timestamp: Constants.formatter.string(from: Date()),
                    messageId: UUID().uuidString
                );
                
                insertMessage(newMessage);
            }
        });
    }
    
    private func onUserConnectionToChannel(insertMessage: @escaping (_ message: Message) -> Void) -> Void {
        self._hubConnection.on(method: "ConnectToChannel", callback: { args, typeConverter in
            print("[ CHAT ] On ConnectToChannel");
            
            let json: String = try! typeConverter.convertFromWireType(obj: args[0], targetType: String.self)!;
            
            if let jsonData = json.data(using: .utf8) {
                let obj: ConnectionMessage = try! JSONDecoder().decode(ConnectionMessage.self, from: jsonData);
                
                let memberFromMessage: Member = Member(
                    name: obj.username,
                    color: .random
                );
                
                self._members.addMember(member: memberFromMessage);
                
                let sysMember = Member(
                    name: "SYSTEM",
                    color: .random
                );
                
                let newMessage = Message(
                    member: sysMember,
                    text: obj.username + " just joined the room",
                    timestamp: Constants.formatter.string(from: Date()),
                    messageId: UUID().uuidString
                );
                
                insertMessage(newMessage);
            }
        });
    }
    
    private func onUserDisconnectFromChannel(insertMessage: @escaping (_ message: Message) -> Void) -> Void {
        self._hubConnection.on(method: "DisconnectFromChannel", callback: { args, typeConverter in
            print("[ CHAT ] On DisconnectFromChannel");
            
            let json: String = try! typeConverter.convertFromWireType(obj: args[0], targetType: String.self)!;
            if let jsonData = json.data(using: .utf8) {
                let obj: ConnectionMessage = try! JSONDecoder().decode(ConnectionMessage.self, from: jsonData);
                
                let sysMember = Member(
                    name: "SYSTEM",
                    color: .random
                );
                
                if (self._members.isAlreadyInArray(memberName: obj.username)) {
                    self._members.removeFromArray(member: self._members.getMemberByName(memberName: obj.username));
                }
                
                let newMessage = Message(
                    member: sysMember,
                    text: obj.username + " just left the room",
                    timestamp: Constants.formatter.string(from: Date()),
                    messageId: UUID().uuidString
                );
                
                insertMessage(newMessage);
            }
        });
    }
    
    private func onSendMessage(currentMemberName: String?, insertMessage: @escaping (_ message: Message) -> Void, updateChatRooms: @escaping () -> Void) -> Void {
        self._hubConnection.on(method: "SendMessage", callback: { args, typeConverter in
            print("[ CHAT ] On SendMessage");
            let messageJson: String = try! typeConverter.convertFromWireType(obj: args[0], targetType: String.self)!;
            if let messageJsonData = messageJson.data(using: .utf8) {
                let message: ChatMessage = try! JSONDecoder().decode(ChatMessage.self, from: messageJsonData);
                
                var memberFromMessage: Member;
                if (self._members.isAlreadyInArray(memberName: message.username)) {
                    memberFromMessage = self._members.getMemberByName(memberName: message.username);
                } else {
                    memberFromMessage = Member( name: message.username, color: .random );
                    self._members.addMember(member: memberFromMessage);
                }
                
                let newMessage = Message(
                    member: memberFromMessage,
                    text: message.message,
                    timestamp: message.timestamp,
                    messageId: UUID().uuidString
                );
                
                if (message.username != currentMemberName) {
                    if (self._currentChannel != nil && self._currentChannel.name == message.channelId) {
                        insertMessage(newMessage);
                    } else {
                        let tmp: [String: [Message]] = [message.channelId: [newMessage]];
                        if (self._messagesWhileAFK.keys.contains(message.channelId)) {
                            var tmpMessages: [Message] = self._messagesWhileAFK[message.channelId]!;
                            tmpMessages.append(newMessage);
                            self._messagesWhileAFK.updateValue(tmpMessages, forKey: message.channelId);
                        } else {
                            self._messagesWhileAFK.merge(tmp, uniquingKeysWith: { (first, _) in first })
                        }
                        
                        updateChatRooms();
                    }
                    
                    SoundNotification.play(sound: Sound.SendMessage);
                }
            }
        });
    }
    
    private func invokeCreateChannel(channelName: String) -> Void {
        let newChannel: ChannelMessage = ChannelMessage(channel: Channel(name: channelName, connected: true));
        let newChannelJson = try? JSONEncoder().encode(newChannel);
        let newChannelJsonData: String = String(data: newChannelJson!, encoding: .utf8)!;
        
        self._hubConnection.invoke(method: "CreateChannel", arguments: [newChannelJsonData], invocationDidComplete: { error in
            print("[ CHAT ] Invoke CreateChannel");
            
            if error != nil {
                print("ERROR while invoking CreateChannel");
            }
        });
    }
    
    public func invokeConnectToChannel() -> Void {
        let json = try? JSONEncoder().encode(ConnectionMessage(channelId: self._currentChannel.name));
        let jsondata: String = String(data: json!, encoding: .utf8)!;
        
        self._hubConnection.invoke(method: "ConnectToChannel", arguments: [jsondata], invocationDidComplete: { error in
            print("[ CHAT ] Invoked ConnectToChannel.");
            
            if error != nil {
                print("ERROR while invoking ConnectToChannel");
            }
        });
    }
    
    private func invokeSendMessage(currentUser: String, message: Message, insertMessage: @escaping (_ message: Message) -> Void) -> Void {
        let chatMsg: ChatMessage = ChatMessage(user: currentUser, message: message.text, channelId: self._currentChannel.name);
        let json = try? JSONEncoder().encode(chatMsg);
        let jsonData: String = String(data: json!, encoding: .utf8)!;
        self._hubConnection.invoke(method: "SendMessage", arguments: [jsonData], invocationDidComplete: { error in
            print("[ CHAT ] Invoke SendMessage");
            
            if error != nil {
                print("ERROR while invoking SendMessage");
            }
            
            SoundNotification.play(sound: Sound.ReceiveMessage);
            insertMessage(message);
        });
    }
}
