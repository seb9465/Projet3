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

struct Message {
    let member: Member;
    let text: String;
    let timestamp: String;
    let messageId: String;
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
            print("MESSAGE CUSTOM SYSTEM");
            return .custom("SYSTEM");
        }
        print("MESSAGE NOT CUSTOM");
        return .text(text);
    }
}
