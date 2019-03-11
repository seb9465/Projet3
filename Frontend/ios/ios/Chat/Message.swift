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
    var username: String;
    var message: String;
    var channelId: String;
    var timestamp: String;
    
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
    public var username: String;
    public var canvasId: String;
    public var channelId: String;
    
    init(username: String?="", canvasId: String?="", channelId: String?="") {
        self.username = username!;
        self.canvasId = canvasId!;
        self.channelId = channelId!;
    }
}

// MARK: Message classs
// Data structure for the messages in the chat view.

class Message {
    var member: Member;
    var text: String;
    var timestamp: String;
    var messageId: String;
    
    init(member: Member, text: String? = "", timestamp: String? = "", messageId: String? = "") {
        self.member = member;
        self.text = text!;
        self.timestamp = timestamp!;
        self.messageId = messageId!;
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
