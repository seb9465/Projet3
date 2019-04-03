//
//  SoundNotification.swift
//  ios
//
//  Created by Sébastien Labine on 19-02-12.
//  Copyright © 2019 LOG3000 equipe 12. All rights reserved.
//

import Foundation
import AVFoundation

class SoundNotification{
    static func play(sound: Sound) -> Void {
        AudioServicesPlaySystemSound (sound.rawValue)
    }
}
enum Sound: SystemSoundID {
    case ReceiveMessage = 1003;
    case SendMessage = 1004;
}
