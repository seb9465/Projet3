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
    
    init (name: String, connected: Bool) {
        self._name = name;
        self._connected = connected;
    }
    
    public var name: String {
        get { return self._name }
        set { self._name = newValue }
    }
    
    public var connected: Bool {
        get { return self._connected }
        set { self._connected = newValue }
    }
}

// MARK: ChannelMessage class

class ChannelMessage: Codable {
    private var _channel: Channel;
    
    init (channel: Channel) {
        self._channel = channel;
    }
    
    public var channel: Channel {
        get { return self._channel }
        set { self._channel = newValue }
    }
}

// MARK: ChannelsMessage class

class ChannelsMessage: Codable {
    private var _channels: [Channel];
    
    init (channels: [Channel]? = []) {
        self._channels = channels!;
    }
    
    public var channels: [Channel] {
        get { return self._channels }
        set { self._channels = newValue }
    }
}
