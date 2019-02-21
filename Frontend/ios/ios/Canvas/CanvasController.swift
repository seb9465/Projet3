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
    case DELETE
}

class CanvasController: UIViewController {
    private var toolState: STATE = STATE.NOTHING_SELECTED;
//    private var undoArray: [CanvasService] = [];
//    private var redoArray: [CanvasService] = [];
    private var canvas: CanvasService = CanvasService();
    
    @IBOutlet var rectButton: UIBarButtonItem!
    @IBOutlet var selectButton: UIBarButtonItem!
    @IBOutlet var deleteButton: UIBarButtonItem!
    var activeButton: UIBarButtonItem!;
    
    
    @objc func handleTap(sender: UITapGestureRecognizer? = nil) {
        let tapPoint: CGPoint = (sender?.location(in: self.view))!;
        
        if (tapPoint.y >= 70 && self.toolState == STATE.DRAW_RECT) {
            self.canvas.addNewFigure(origin: tapPoint, view: self.view);
//            let can = CanvasService(origin: tapPoint, view: self.view);
//            self.view.addSubview(can);
//            self.undoArray.append(can);
        } else if (self.toolState == STATE.SELECTION) {
            self.selectFigure(point: tapPoint);
        } else if (self.toolState == STATE.DELETE) {
            self.deleteFigure(point: tapPoint);
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
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
    
    @IBAction func undoButton(_ sender: Any) {
        self.canvas.undo(view: self.view);
//        self.undo();
    }
    
    @IBAction func redoButton(_ sender: Any) {
        self.canvas.redo(view: self.view);
//        self.redo();
    }
    
    @IBAction func clearButton(_ sender: Any) {
        self.clear();
    }
    
    @IBAction func deleteButton(_ sender: Any) {
        if (self.toolState == STATE.DELETE) {
            self.toolState = STATE.NOTHING_SELECTED;
            self.activeButton = nil;
            self.deleteButton.tintColor = UIColor(red: 0, green: 122/255, blue: 1, alpha: 1);
        } else {
            print("DELETE BUTTON SELECTED");
            self.toolState = STATE.DELETE;
            self.activeButton?.tintColor = UIColor(red: 0, green: 122/255, blue: 1, alpha: 1);
            self.activeButton = self.deleteButton;
            self.deleteButton.tintColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1);
        }
    }
    
    @IBAction func selectFigureButton(_ sender: Any) {
        if (self.toolState == STATE.SELECTION) {
            self.toolState = STATE.NOTHING_SELECTED;
            self.activeButton = nil;
            self.selectButton.tintColor = UIColor(red: 0, green: 122/255, blue: 1, alpha: 1);
        } else {
            print("SLECT BUTTON SELECTED");
            self.toolState = STATE.SELECTION;
            self.activeButton?.tintColor = UIColor(red: 0, green: 122/255, blue: 1, alpha: 1);
            self.activeButton = self.selectButton;
            self.selectButton.tintColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1);
        }
    }
    
    @IBAction func drawRectButton(_ sender: Any) {
        if (self.toolState == STATE.DRAW_RECT) {
            self.toolState = STATE.NOTHING_SELECTED;
            self.activeButton = nil;
            self.rectButton.tintColor = UIColor(red:0,green:122/255,blue:1,alpha:1);
        } else {
            print("RECT BUTTON SELECTED");
            self.toolState = STATE.DRAW_RECT;
            self.activeButton?.tintColor = UIColor(red: 0, green: 122/255, blue: 1, alpha: 1);
            self.activeButton = self.rectButton;
            self.rectButton.tintColor = UIColor(red:0,green:0,blue:0,alpha:1);
        }
    }
    
    @IBAction func quitButton(_ sender: Any) {
        let alert = UIAlertController(title: "Alert", message: "Would you like to quit ?", preferredStyle: .alert);
        
        let yesAction: UIAlertAction = UIAlertAction(title: "Yes", style: .default) { _ in
            let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil);
            let viewController: UIViewController = mainStoryboard.instantiateViewController(withIdentifier: "DashboardController");
            self.present(viewController, animated: true, completion: nil);
        }
        let noAction: UIAlertAction = UIAlertAction(title: "No", style: .default, handler: nil);
        
        alert.addAction(yesAction);
        alert.addAction(noAction);
        
        self.present(alert, animated: true, completion: nil);
    }
    
    public func undo() {
//        print(undoArray);
//        if (undoArray.count > 0) {
//            let v: CanvasService = self.view.subviews.last as! CanvasService;
//            self.redoArray.append(v);
//            v.removeFromSuperview();
//            self.undoArray.removeLast();
//        }
    }
    
    public func redo() {
//        if (redoArray.count > 0) {
//            let v: CanvasService = self.redoArray.last!;
//            self.view.addSubview(v);
//            self.undoArray.append(v);
//            self.redoArray.removeLast();
//        }
    }
    
    public func clear() {
        if (self.canvas.figuresInView()) {
            let alert: UIAlertController = UIAlertController(title: "Alert", message: "Are you sure you want to clear the canvas ?", preferredStyle: .alert);

            let yesAction: UIAlertAction = UIAlertAction(title: "Yes", style: .default, handler: { (alert: UIAlertAction!) in
                self.canvas.clear();
            });
            let noAction: UIAlertAction = UIAlertAction(title: "No", style: .default, handler:nil);

            alert.addAction(yesAction);
            alert.addAction(noAction);

            self.present(alert, animated: true, completion: nil);
        }
    }
    
    public func selectFigure(point: CGPoint) {
        let subview = self.view.hitTest(point, with: nil);
        
        self.canvas.selectFigure(subview: subview!);
        
//        if (self.subviewIsInUndoArray(subview: subview!)) {
//            print("TAPED SUBVIEW");
//            (subview as! CanvasService).isSelected = true;
//        } else {
//            print("NO SUBVIEW THERE");
//        }
    }
    
    public func deleteFigure(point: CGPoint) {
        let subview = self.view.hitTest(point, with: nil);
        
        self.canvas.deleteFigure(subview: subview!);
        
    //        if (self.subviewIsInUndoArray(subview: subview!)) {
    //            var counter: Int = 0;
    //            for v in self.undoArray {
    //                if (v == subview) {
    //                    self.redoArray.append(v);
    //                    v.removeFromSuperview();
    //                    self.undoArray.remove(at: counter);
    //                    break;
    //                }
    //                counter += 1;
    //            }
    //        }
    }
}
