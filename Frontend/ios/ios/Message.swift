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

struct Member {
    let name: String;
    let color: UIColor;
}

struct Message {
    let member: Member;
    let text: String;
    let messageId: String;
}
