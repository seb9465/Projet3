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
