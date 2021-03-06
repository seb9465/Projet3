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
    var canvasAnchor: CanvasAnchor?
    var biggerCanvasAnchor: ClearCanvasAnchor?
    
    init() {
        var viewFrame : CGRect = CGRect(x: 250, y: 0, width: UIScreen.main.bounds.width - 250, height: UIScreen.main.bounds.height - 70)
        viewFrame = viewFrame.offsetBy(dx:0, dy: 70)
        super.init(frame: viewFrame)
        self.clipsToBounds = true
        self.backgroundColor = UIColor(red: 255, green: 255, blue: 255, alpha: 1.0)
//        self.updateShadow()
    }
    
    func updateShadow() {
//        layer.masksToBounds = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.25
        layer.shadowOffset = CGSize(width: 1, height: 1)
        layer.shadowRadius = 1
        
        layer.shadowPath = UIBezierPath(rect: bounds).cgPath
        layer.shouldRasterize = true
        layer.rasterizationScale = 1
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addAnchor() {
        self.biggerCanvasAnchor = ClearCanvasAnchor(position: CGPoint(x: self.frame.width, y: self.frame.height))
        self.canvasAnchor = CanvasAnchor(position: CGPoint(x: self.frame.width, y: self.frame.height))
        self.layer.addSublayer(self.biggerCanvasAnchor!)
        self.layer.addSublayer(self.canvasAnchor!)
    }
    
    func updateCanvasAnchor() {
        if (self.canvasAnchor != nil) {
            self.canvasAnchor?.removeFromSuperlayer()
        }
        if (self.biggerCanvasAnchor != nil) {
            self.biggerCanvasAnchor?.removeFromSuperlayer()
        }
        self.biggerCanvasAnchor = ClearCanvasAnchor(position: CGPoint(x: self.frame.width, y: self.frame.height))
        self.layer.addSublayer(self.biggerCanvasAnchor!)
        self.canvasAnchor = CanvasAnchor(position: CGPoint(x: self.frame.width, y: self.frame.height))
        self.layer.addSublayer(self.canvasAnchor!)
        setNeedsDisplay()
    }
    
    func isPointOnAnchor(point: CGPoint) -> Bool{
        for layer in self.layer.sublayers!{
            if (layer is CanvasAnchor || layer is ClearCanvasAnchor) {
                if let path = (layer as! CAShapeLayer).path, path.contains(point) {
                    print("FINI_HIHIHI")
                    return true
                }
            }
        }
        return false
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
            
            if (self.isPointOnAnchor(point: point)) {
                self.delegate?.notifyTouchBegan(action: "canvas_anchor", point: point, figure: nil)
                return
            }
            
            self.delegate?.notifyTouchBegan(action: "empty", point: point, figure: nil)
        }
        
        public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
            let touch = touches.first
            guard let point = touch?.location(in: self) else { return }
            
            self.delegate?.notifyTouchMoved(point: point, figure: nil)
        }
        
        public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
            let touch = touches.first
            guard let point = touch?.location(in: self) else { return }
            self.delegate?.notifyTouchEnded(point: point, figure: nil)
        }
}
