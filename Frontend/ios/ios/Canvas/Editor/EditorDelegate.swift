//
//  EditorDelegate.swift
//  ios
//
//  Created by Sébastien Labine on 19-04-06.
//  Copyright © 2019 LOG3000 equipe 12. All rights reserved.
//

import UIKit

protocol EditorDelegate {
    func getKicked()
    func setCutButtonState(isEnabled: Bool)
    func setDuplicateButtonState(isEnabled: Bool)
}
