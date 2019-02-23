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

class CanvasController: UIViewController, UIPopoverPresentationControllerDelegate {
    private var toolState: STATE  = STATE.NOTHING_SELECTED;
    public var canvas: CanvasService = CanvasService();
    private var activeButton: UIBarButtonItem!;
    
    @IBOutlet var rectButton: UIBarButtonItem!
    @IBOutlet var selectButton: UIBarButtonItem!
    @IBOutlet var deleteButton: UIBarButtonItem!
    @IBOutlet var borderButton: UIBarButtonItem!
    @IBOutlet var fillButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        self.addTapGestureRecognizer();
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated);
        
        navigationController?.setNavigationBarHidden(true, animated: animated);
        self.borderButton.isEnabled = false;
        self.fillButton.isEnabled = false;
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated);
        
        navigationController?.setNavigationBarHidden(false, animated: animated);
    }
    
    @objc func handleTap(sender: UITapGestureRecognizer? = nil) {
        let tapPoint: CGPoint = (sender?.location(in: self.view))!;
        
        if (tapPoint.y >= 70 && self.toolState == STATE.DRAW_RECT) {
            self.canvas.addNewFigure(origin: tapPoint, view: self.view);
        } else if (self.toolState == STATE.SELECTION) {
            let res: Bool = self.canvas.selectFigure(tapPoint: tapPoint, view: self.view);
            self.borderButton.isEnabled = res;
            self.fillButton.isEnabled = res;
        } else if (self.toolState == STATE.DELETE) {
            self.canvas.deleteFigure(tapPoint: tapPoint, view: self.view);
        }
    }
    
    @IBAction func undoButton(_ sender: Any) {
        self.canvas.undo(view: self.view);
    }
    
    @IBAction func redoButton(_ sender: Any) {
        self.canvas.redo(view: self.view);
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
            self.canvas.unselectSelectedFigure();
            self.borderButton.isEnabled = false;
            self.fillButton.isEnabled = false;
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
            self.canvas.unselectSelectedFigure();
            self.borderButton.isEnabled = false;
            self.fillButton.isEnabled = false;
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
    
    @IBAction func borderButton(_ sender: Any) {
        print("BORDER BUTTON TAPED");
    }
    
    @IBAction func fillButton(_ sender: Any) {
        print("FILL BUTTON TAPED");
        
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
    
    private func addTapGestureRecognizer() -> Void {
        let tap = UITapGestureRecognizer(target: self, action: #selector(CanvasController.handleTap(sender:)))
        self.view.addGestureRecognizer(tap);
    }
}
