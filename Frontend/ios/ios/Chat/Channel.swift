//
//  Channel.swift
//  ios
//
//  Created by Sebastien Cadorette on 2019-03-09.
//  Copyright © 2019 LOG3000 equipe 12. All rights reserved.
//

import Foundation

// MARK: Channel class

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
    
    init (name: String, connected: Bool) {
        self._name = name;
        self._connected = connected;
    }
}

// MARK: ChannelMessage class

class ChannelMessage: Codable {
    private var _channel: Channel;
    
    public var channel: Channel {
        get { return self._channel }
        set { self._channel = newValue }
    }
    
    init (channel: Channel) {
        self._channel = channel;
    }
}

// MARK: ChannelsMessage class

class ChannelsMessage: Codable {
    private var _channels: [Channel];
    
    public var channels: [Channel] {
        get { return self._channels }
        set { self._channels = newValue }
    }
    
    init (channels: [Channel]? = []) {
        self._channels = channels!;
    }
}
