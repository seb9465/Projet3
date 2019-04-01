//
//  Message.swift
//  ios
//
//  Created by Sebastien Cadorette on 2019-01-31.
//  Copyright © 2019 LOG3000 equipe 12. All rights reserved.
//

import Foundation
import UIKit
import MessageKit

// MARK: ChatMessage class
// Used for the frontend-backend communication.

class ChatMessage: Codable {
    private var _username: String;
    private var _message: String;
    private var _channelId: String;
    private var _timestamp: String;
    
    init(user: String, message: String, channelId: String, timestamp: String? = "") {
        self._username = user;
        self._message = message;
        self._channelId = channelId;
        self._timestamp = timestamp!;
    }
    
    public var username: String {
        get { return self._username }
        set { self._username = newValue }
    }
    
    public var message: String {
        get { return self._message }
        set { self._message = newValue }
    }
    
    public var channelId: String {
        get { return self._channelId }
        set { self._channelId = newValue }
    }
    
    public var timestamp: String {
        get { return self._timestamp }
        set { self._timestamp = newValue }
    }
}

// MARK: ConnectionMessage class
// Used for the frontend-backend communication.

class ConnectionMessage: Codable {
    private var _username: String;
    private var _canvasId: String;
    private var _channelId: String;
    
    init (username: String? = "", canvasId: String? = "", channelId: String? = "") {
        self._username = username!;
        self._canvasId = canvasId!;
        self._channelId = channelId!;
    }
    
    public var username: String {
        get { return self._username }
        set { self._username = newValue }
    }
    
    public var canvasId: String {
        get { return self._canvasId }
        set { self._canvasId = newValue }
    }
    
    public var channelId: String {
        get { return self._channelId }
        set { self._channelId = newValue }
    }
}

// MARK: Message classs
// Data structure for the messages in the chat view.

class Message {
    private var _member: Member;
    private var _text: String;
    private var _timestamp: String;
    private var _messageId: String;
    
    init (member: Member, text: String? = "", timestamp: String? = "", messageId: String? = "") {
        self._member = member;
        self._text = text!;
        self._timestamp = timestamp!;
        self._messageId = messageId!;
    }
    
    public var member: Member {
        get { return self._member }
        set { self._member = newValue }
    }
    
    public var text: String {
        get { return self._text }
        set { self._text = newValue }
    }
    
    public var timestamp: String {
        get { return self._timestamp }
        set { self._timestamp = newValue }
    }
    
    public var messageId: String {
        get { return self._messageId }
        set { self._messageId = newValue }
    }
}

extension Message: MessageType {
    var sender: Sender {
        return Sender(id: member.name, displayName: member.name);
    }
    
    var sentDate: Date {
        return Date();
    }
    
    var kind: MessageKind {
        if(member.name == "SYSTEM") {
            return .custom(text);
        }
        
        return .text(text);
    }
}
