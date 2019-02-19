//
//  ConvasController.swift
//  ios
//
//  Created by Sebastien Cadorette on 2019-02-12.
//  Copyright © 2019 LOG3000 equipe 12. All rights reserved.
//

import UIKit

enum STATE {
    case NOTHING_SELECTED
    case DRAW_RECT
    case SELECTION
}

class CanvasController: UIViewController {
    private let undoArray: NSMutableArray = NSMutableArray();
    private let redoArray: NSMutableArray = NSMutableArray();
    
    @IBOutlet var rectButton: UIBarButtonItem!
    
    var toolState: STATE = STATE.NOTHING_SELECTED;
    
    @objc func handleTap(sender: UITapGestureRecognizer? = nil) {
        let tapPoint = sender?.location(in: self.view);
        
        if (tapPoint!.y >= 70 && self.toolState == STATE.DRAW_RECT) {
            let can = CanvasService(origin: tapPoint!);
            self.view.addSubview(can);
        }
        
        print("TAP");
        print("\t\(tapPoint!.x)");
        print("\t\(tapPoint!.y)");
    }
    
    override func viewDidLoad() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(CanvasController.handleTap(sender:)))
        self.view.addGestureRecognizer(tap);
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated);
        
        navigationController?.setNavigationBarHidden(true, animated: animated);
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated);
        
        navigationController?.setNavigationBarHidden(false, animated: animated);
    }
    
    @IBAction func drawRectButton(_ sender: Any) {
        if (self.toolState == STATE.DRAW_RECT) {
            self.toolState = STATE.NOTHING_SELECTED;
            self.rectButton.tintColor = UIColor(red:0,green:122/255,blue:1,alpha:1);
        } else {
            self.toolState = STATE.DRAW_RECT;
            self.rectButton.tintColor = UIColor(red:0,green:0,blue:0,alpha:1);
        }
    }
    
    @IBAction func quitButton(_ sender: Any) {
        let alert = UIAlertController(title: "Alert", message: "Would you like to quit ?", preferredStyle: .alert)
        
        let yesAction: UIAlertAction = UIAlertAction(title: "Yes", style: .default) { _ in
            let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil);
            let viewController: UIViewController = mainStoryboard.instantiateViewController(withIdentifier: "DashboardView");
            self.present(viewController, animated: true, completion: nil);
        }
        let noAction: UIAlertAction = UIAlertAction(title: "No", style: .default, handler: nil);
        
        alert.addAction(yesAction);
        alert.addAction(noAction);
        
        self.present(alert, animated: true, completion: nil)
    }
    
    public func undo() {
//        if (undoArray.count > 0) {
//            guard let p = pathArray.lastObject else { return }
//            bufferArray.add(p);
//            pathArray.removeLastObject();
            let v = self.view.subviews.last;
            v!.removeFromSuperview();
//        }
    }
    
    public func redo() {
        if (redoArray.count > 0) {
//            guard let p = bufferArray.lastObject else { return }
//            pathArray.add(p);
//            bufferArray.removeLastObject();
        }
    }
}
