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
    
    // MARK: Attributes
    
    public var username: String;
    public var message: String;
    public var channelId: String;
    public var timestamp: String;
    
    // MARK: Constructor
    
    init(user: String, message: String, channelId: String, timestamp: String? = "") {
        self.username = user;
        self.message = message;
        self.channelId = channelId;
        self.timestamp = timestamp!;
    }
}

// MARK: ConnectionMessage class
// Used for the frontend-backend communication.

class ConnectionMessage: Codable {
    
    // MARK: Attributes
    
    public var username: String;
    public var canvasId: String;
    public var channelId: String;
    
    // MARK: Constructor
    
    init (username: String? = "", canvasId: String? = "", channelId: String? = "") {
        self.username = username!;
        self.canvasId = canvasId!;
        self.channelId = channelId!;
    }
}

// MARK: Message classs
// Data structure for the messages in the chat view.

class Message {
    
    // MARK: Attributes
    
    private var _member: Member;
    private var _text: String;
    private var _timestamp: String;
    private var _messageId: String;
    
    // MARK: Constructor
    
    init (member: Member, text: String? = "", timestamp: String? = "", messageId: String? = "") {
        self._member = member;
        self._text = text!;
        self._timestamp = timestamp!;
        self._messageId = messageId!;
    }
    
    // MARK: Getter - Setter
    
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
