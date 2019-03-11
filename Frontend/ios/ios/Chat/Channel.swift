//
//  Channel.swift
//  ios
//
//  Created by Sebastien Cadorette on 2019-03-09.
//  Copyright © 2019 LOG3000 equipe 12. All rights reserved.
//

import Foundation

class Channel: Codable {
    public var name: String;
    public var connected: Bool;
    
    init(name: String, connected: Bool) {
        self.name = name;
        self.connected = connected;
    }
}

class ChannelMessage: Codable {
    public var channel: Channel;
    
    init(channel: Channel) {
        self.channel = channel;
    }
}

class ChannelsMessage: Codable {
    public var channels: [Channel];
    
    init(channels: [Channel]? = []) {
        self.channels = channels!;
    }
}
