//
//  ConvasController.swift
//  ios
//
//  Created by Sebastien Cadorette on 2019-02-12.
//  Copyright © 2019 LOG3000 equipe 12. All rights reserved.
//

import ChromaColorPicker
import UIKit

class CanvasController: UIViewController {
    
    // MARK: - Attributes
    private var activeButton: UIBarButtonItem!;
    public var editor: Editor = Editor()
    
    // MARK: Outlets
    
    @IBOutlet weak var insertButton: UIBarButtonItem!
    @IBOutlet var selectButton: UIBarButtonItem!
    @IBOutlet var deleteButton: UIBarButtonItem!
    @IBOutlet weak var lassoButton: UIBarButtonItem!
    @IBOutlet weak var exportButton: UIBarButtonItem!
    @IBOutlet var chatViewButton: UIBarButtonItem!
    
    @IBOutlet var navigationBar: UIToolbar!
    @IBOutlet var chatViewContainer: UIView!
    
    // MARK: Timing functions
    
    override func viewDidLoad() {
        super.viewDidLoad();
//        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        CollaborationHub.shared.connectToHub()
        
        self.initChatViewContainer();
        
        self.view.addSubview(self.editor.editorView)
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
    
    @IBAction func chatViewButton(_ sender: Any) {
        if (self.chatViewContainer.isHidden) {
            self.chatViewButton.tintColor = Constants.RED_COLOR;
            self.chatViewContainer.isHidden = false;
            self.view.bringSubviewToFront(self.chatViewContainer);
        } else {
            self.chatViewButton.tintColor = UIColor.black;
            self.chatViewContainer.isHidden = true;
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
    
    private func initChatViewContainer() -> Void {
        self.chatViewContainer.sizeToFit();
        self.view.bringSubviewToFront(self.chatViewContainer);
        self.chatViewContainer.isHidden = true;
        self.chatViewContainer.layer.cornerRadius = 5.0;
        self.chatViewContainer.layer.shadowColor = UIColor.black.cgColor;
        self.chatViewContainer.layer.shadowOffset = CGSize.zero;
        self.chatViewContainer.layer.shadowOpacity = 0.3;
        self.chatViewContainer.layer.shadowRadius = 2;
        self.chatViewContainer.layer.masksToBounds = false;
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
}

