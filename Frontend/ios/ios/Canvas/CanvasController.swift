//
//  ConvasController.swift
//  ios
//
//  Created by Sebastien Cadorette on 2019-02-12.
//  Copyright © 2019 LOG3000 equipe 12. All rights reserved.
//

import ChromaColorPicker
import UIKit
import Reachability
import Foundation
class CanvasController: UIViewController {
    
    // MARK: - Attributes
    private var activeButton: UIBarButtonItem!;
    
    @IBOutlet weak var connectionLabel: UILabel!
    public var editor: Editor = Editor()
    var reach: Reachability?

    @IBOutlet weak var insertButton: UIBarButtonItem!
    @IBOutlet var selectButton: UIBarButtonItem!
    @IBOutlet var deleteButton: UIBarButtonItem!
    @IBOutlet weak var lassoButton: UIBarButtonItem!
    
    @IBOutlet weak var exportButton: UIBarButtonItem!
    @IBOutlet var navigationBar: UIToolbar!
    
    override func viewDidLoad() {
        super.viewDidLoad();
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)

        CollaborationHub.shared.connectToHub()
        
        self.view.addSubview(self.editor.editorView)
        setupNetwork()
        
    }
    func setupNetwork() {
        self.reach = Reachability.forInternetConnection()
        
        // Tell the reachability that we DON'T want to be reachable on 3G/EDGE/CDMA
        self.reach!.reachableOnWWAN = false
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(reachabilityChanged),
            name: NSNotification.Name.reachabilityChanged,
            object: nil
        )
        
        self.reach!.startNotifier()

    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated);
        navigationController?.setNavigationBarHidden(true, animated: animated);
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated);
        navigationController?.setNavigationBarHidden(false, animated: animated);
    }
    
    // MARK: - Button Action Functions
    
    @IBAction func undoButton(_ sender: Any) {
        self.editor.deselect();
        self.editor.undo(view: self.view);
    }
    
    @IBAction func redoButton(_ sender: Any) {
        self.editor.deselect();
        self.editor.redo(view: self.view);
    }
    
    @IBAction func clearButton(_ sender: Any) {
        CollaborationHub.shared.reset();
    }
    
    @IBAction func deleteButton(_ sender: Any) {
//        self.resetButtonColor();
//        if (self.editor.touchEventState == .DELETE) {
//            self.editor.changeTouchHandleState(to: .NONE);
//        } else {
//            self.deleteButton.tintColor = Constants.RED_COLOR;
//            self.editor.changeTouchHandleState(to: .DELETE)
//        }
//
//        self.editor.deselect();
        self.editor.deleteSelectedFigures()
    }
    
    @IBAction func lassoButton(_ sender: Any) {
        self.resetButtonColor();
        
        if (self.editor.touchEventState == .AREA_SELECT) {
            self.editor.changeTouchHandleState(to: .NONE);
        } else {
            self.lassoButton.tintColor = Constants.RED_COLOR;
            self.editor.changeTouchHandleState(to: .AREA_SELECT)
        }
        
        self.editor.deselect();
    }
    
    @IBAction func selectFigureButton(_ sender: Any) {
        self.resetButtonColor();
        
        if (self.editor.touchEventState == .SELECT) {
            self.editor.changeTouchHandleState(to: .NONE);
        } else {
            self.selectButton.tintColor = Constants.RED_COLOR;
            self.editor.changeTouchHandleState(to: .SELECT)
        }
        
        self.editor.deselect();
    }
    
    @IBAction func insertButtonPressed(_ sender: Any) {
        self.resetButtonColor();
        
        if (self.editor.touchEventState == .INSERT) {
            self.editor.changeTouchHandleState(to: .NONE);
        } else {
            self.insertButton.tintColor = Constants.RED_COLOR;
            self.editor.changeTouchHandleState(to: .INSERT)
        }
        
        self.editor.deselect();
    }
    
    @IBAction func exportButtonPressed(_ sender: Any) {
        UIGraphicsBeginImageContextWithOptions(self.editor.editorView.bounds.size, false, 0.0);
        self.editor.editorView.drawHierarchy(in: self.editor.editorView.bounds, afterScreenUpdates: true);
        let image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        UIImageWriteToSavedPhotosAlbum(image!, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil);
    }
    
    private func resetButtonColor() -> Void {
        self.selectButton.tintColor = UIColor.black;
        self.deleteButton.tintColor = UIColor.black;
        self.insertButton.tintColor = UIColor.black;
        self.lassoButton.tintColor = UIColor.black;
    }
    
    @objc private func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            let ac = UIAlertController(title: "Exportation error", message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            
            present(ac, animated: true)
        } else {
            let ac = UIAlertController(title: "Saved!", message: "Your canvas has been saved to your photos.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
    }
    @IBAction func saveButton(_ sender: Any) {
        self.editor.save();
    }
    @IBAction func quitButton(_ sender: Any) {
        let alert = UIAlertController(title: "Alert", message: "Would you like to quit ?", preferredStyle: .alert);
        
        let yesAction: UIAlertAction = UIAlertAction(title: "Yes", style: .default) { _ in
            let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil);
            let viewController: UIViewController = mainStoryboard.instantiateViewController(withIdentifier: "MainController");
            self.present(viewController, animated: true, completion: nil);
        }
        let noAction: UIAlertAction = UIAlertAction(title: "No", style: .default, handler: nil);
        
        alert.addAction(yesAction);
        alert.addAction(noAction);
        
        self.present(alert, animated: true, completion: nil);
    }
    @objc func keyboardWillShow(notification: NSNotification) {
//        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
//            if self.view.frame.origin.y == 0 {
//                self.view.frame.origin.y -= keyboardSize.height
//            }
//        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
//        if self.view.frame.origin.y != 0 {
//            self.view.frame.origin.y = 0
//        }
    }
    
    @objc func reachabilityChanged(notification: NSNotification) {
        if self.reach!.isReachableViaWiFi() || self.reach!.isReachableViaWWAN() {
            self.connectionLabel.text = "Online"
            self.connectionLabel.textColor = UIColor.green
        } else {
            self.connectionLabel.text = "Offline"
            self.connectionLabel.textColor = UIColor.red
        }
    }
}

