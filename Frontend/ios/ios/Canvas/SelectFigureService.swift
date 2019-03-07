//
//  SelectFigureService.swift
//  ios
//
//  Created by Sebastien Cadorette on 2019-03-07.
//  Copyright © 2019 LOG3000 equipe 12. All rights reserved.
//

import Foundation
import UIKit

class SelectFigureService: UIView {
    private let radius: CGFloat = 5.0;
    private var selectedDashedBorder: CAShapeLayer!;
    private var selectedCornerCircle1: CAShapeLayer!;
    private var selectedCornerCircle2: CAShapeLayer!;
    private var selectedCornerCircle3: CAShapeLayer!;
    private var selectedCornerCircle4: CAShapeLayer!;
    
    
    private func setInitialSelectedCornerCirles() -> Void {
        selectedCornerCircle1 = CAShapeLayer();
        selectedCornerCircle1.path = UIBezierPath(roundedRect: CGRect(x: -5, y: -5, width: 2.0 * self.radius, height: 2.0 * self.radius), cornerRadius: self.radius).cgPath;
        selectedCornerCircle1.position = CGPoint(x: 0, y: 0);
        selectedCornerCircle1.fillColor = UIColor.blue.cgColor;
        
        selectedCornerCircle2 = CAShapeLayer();
        selectedCornerCircle2.path = UIBezierPath(roundedRect: CGRect(x: -5, y: -5, width: 2.0 * self.radius, height: 2.0 * self.radius), cornerRadius: self.radius).cgPath;
        selectedCornerCircle2.position = CGPoint(x: self.currentTool.lastPoint.x - self.currentTool.firstPoint.x + 2, y: 0);
        selectedCornerCircle2.fillColor = UIColor.blue.cgColor;
        
        selectedCornerCircle3 = CAShapeLayer();
        selectedCornerCircle3.path = UIBezierPath(roundedRect: CGRect(x: -5, y: -5, width: 2.0 * self.radius, height: 2.0 * self.radius), cornerRadius: self.radius).cgPath;
        selectedCornerCircle3.position = CGPoint(x: self.currentTool.lastPoint.x - self.currentTool.firstPoint.x + 2, y: self.currentTool.lastPoint.y - self.currentTool.firstPoint.y + 2);
        selectedCornerCircle3.fillColor = UIColor.blue.cgColor;
        
        selectedCornerCircle4 = CAShapeLayer();
        selectedCornerCircle4.path = UIBezierPath(roundedRect: CGRect(x: -5, y: -5, width: 2.0 * self.radius, height: 2.0 * self.radius), cornerRadius: self.radius).cgPath;
        selectedCornerCircle4.position = CGPoint(x: 0, y: self.currentTool.lastPoint.y - self.currentTool.firstPoint.y + 2);
        selectedCornerCircle4.fillColor = UIColor.blue.cgColor;
    }
    
    private func setInitialSelectedDashedBorder() -> Void {
        selectedDashedBorder = CAShapeLayer();
        selectedDashedBorder.strokeColor = UIColor.black.cgColor;
        selectedDashedBorder.lineDashPattern = [4, 4];
        selectedDashedBorder.frame = self.bounds;
        selectedDashedBorder.fillColor = nil;
        selectedDashedBorder.path = UIBezierPath(rect: self.bounds).cgPath;
    }
    
    private func addSelectedFigureLayers() -> Void {
        self.layer.addSublayer(selectedDashedBorder);
        self.layer.addSublayer(selectedCornerCircle1);
        self.layer.addSublayer(selectedCornerCircle2);
        self.layer.addSublayer(selectedCornerCircle3);
        self.layer.addSublayer(selectedCornerCircle4);
    }
    
    private func removeSelectedFigureLayers() -> Void {
        self.selectedDashedBorder.removeFromSuperlayer();
        self.selectedCornerCircle1.removeFromSuperlayer();
        self.selectedCornerCircle2.removeFromSuperlayer();
        self.selectedCornerCircle3.removeFromSuperlayer();
        self.selectedCornerCircle4.removeFromSuperlayer();
    }
    
    private func adjustSelectedFigureLayers() -> Void {
        selectedDashedBorder.path = UIBezierPath(rect: self.bounds).cgPath;
        selectedCornerCircle2.position.x = self.currentTool.lastPoint.x - self.currentTool.firstPoint.x + 2;
        selectedCornerCircle3.position.x = self.currentTool.lastPoint.x - self.currentTool.firstPoint.x + 2;
        selectedCornerCircle3.position.y = self.currentTool.lastPoint.y - self.currentTool.firstPoint.y + 2;
        selectedCornerCircle4.position.y = self.currentTool.lastPoint.y - self.currentTool.firstPoint.y + 2;
        self.addSelectedFigureLayers();
        setNeedsDisplay();
    }
}
