//
//  ProtectionMessage.swift
//  ios
//
//  Created by Sébastien Labine on 19-04-06.
//  Copyright © 2019 LOG3000 equipe 12. All rights reserved.
//

struct ProtectionMessage: Codable {
    var ChannelId: String
    var IsProtected: Bool
    
    init(ChannelId: String, IsProtected: Bool) {
        self.ChannelId = ChannelId;
        self.IsProtected = IsProtected;
    }
}
