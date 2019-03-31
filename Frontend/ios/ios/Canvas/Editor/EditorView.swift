//
//  EditorView.swift
//  ios
//
//  Created by William Sevigny on 2019-03-11.
//  Copyright © 2019 LOG3000 equipe 12. All rights reserved.
//

import UIKit

class EditorView: UIView {
    var delegate: TouchInputDelegate?
    
    init() {
        var viewFrame : CGRect = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width - 250, height: UIScreen.main.bounds.height - 70)
        viewFrame = viewFrame.offsetBy(dx:0, dy: 70)
        super.init(frame: viewFrame)
        self.backgroundColor = UIColor(red: 255, green: 255, blue: 255, alpha: 1.0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
    }
}

// Touch Interaction Logic
extension EditorView {
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        guard let point = touch?.location(in: self) else { return }
        self.delegate?.notifyTouchBegan(action: "empty", point: point, figure: nil)
    }
    
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        guard let point = touch?.location(in: self) else { return }
        self.delegate?.notifyTouchEnded(point: point, figure: nil)
    }
}
