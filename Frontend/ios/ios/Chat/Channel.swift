//
//  Channel.swift
//  ios
//
//  Created by Sebastien Cadorette on 2019-03-09.
//  Copyright © 2019 LOG3000 equipe 12. All rights reserved.
//

import Foundation

class Channel: Codable {
    private var _name: String;
    private var _connected: Bool;
    
    public var name: String {
        get { return self._name }
        set { self._name = newValue }
    }
    
    public var connected: Bool {
        get { return self._connected }
        set { self._connected = newValue }
    }
    
    init(name: String, connected: Bool) {
        self._name = name;
        self._connected = connected;
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
