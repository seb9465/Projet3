//
//  CanvasResizePoints.swift
//  ios
//
//  Created by William Sevigny on 2019-03-12.
//  Copyright © 2019 LOG3000 equipe 12. All rights reserved.
//

import UIKit

protocol CanvasResizePointsProtocol {
    var CornerCircle1: CAShapeLayer! { get set }
    var CornerCircle2: CAShapeLayer! { get set }
    var CornerCircle3: CAShapeLayer! { get set }
    var CornerCircle4: CAShapeLayer! { get set }
}

class CanvasResizePoints: UIView {
    var delegate: TouchInputDelegate?
    
    private let radius: CGFloat = 5.0;
    
    var cornerAnchors: [CAShapeLayer] = []
    
    init(frame: CGRect, delegate: TouchInputDelegate?) {
        self.delegate = delegate
        super.init(frame: frame)
        self.setInitialCornerCirles()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func setInitialCornerCirles() -> Void {
        let CornerCircle2 = CAShapeLayer();
        CornerCircle2.path = UIBezierPath(roundedRect: CGRect(x: -5, y: -5, width: 2.0 * self.radius, height: 2.0 * self.radius), cornerRadius: self.radius).cgPath;
        CornerCircle2.position = CGPoint(x: frame.width, y: 0);
        CornerCircle2.fillColor = UIColor.blue.cgColor;
        
        let CornerCircle3 = CAShapeLayer();
        CornerCircle3.path = UIBezierPath(roundedRect: CGRect(x: -5, y: -5, width: 2.0 * self.radius, height: 2.0 * self.radius), cornerRadius: self.radius).cgPath;
        CornerCircle3.position = CGPoint(x: 0, y: frame.height);
        CornerCircle3.fillColor = UIColor.blue.cgColor;
        
        let CornerCircle4 = CAShapeLayer();
        CornerCircle4.path = UIBezierPath(roundedRect: CGRect(x: -5, y: -5, width: 2.0 * self.radius, height: 2.0 * self.radius), cornerRadius: self.radius).cgPath;
        CornerCircle4.position = CGPoint(x: frame.width, y: frame.height)
        CornerCircle4.fillColor = UIColor.blue.cgColor;
        
        self.cornerAnchors.append(CornerCircle4)
        for view in self.cornerAnchors {
            self.layer.addSublayer(view)
        }
    }

    public func translate(by: CGPoint) {
        let translatedFrame = self.frame.offsetBy(dx: by.x, dy: by.y)
        self.frame = translatedFrame
    }
}

/*
extension CanvasResizePoints {
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        guard let point = touch?.location(in: self.superview) else { return }
        print("touching in canvasResizeClass")
        self.delegate?.notifyTouchBegan(action: "resizeCanvas", point: point, figure: nil)
    }
    
    public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        guard let point = touch?.location(in: self.superview) else { return }
        
        self.delegate?.notifyTouchMoved(point: point, figure: nil)
    }
    
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        guard let point = touch?.location(in: self.superview) else { return }
        self.delegate?.notifyTouchEnded(point: point, figure: nil)
    }
    
    public override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        guard let point = touch?.location(in: self.superview) else { return }
        self.delegate?.notifyTouchEnded(point: point, figure: nil)
    }
}
*/
