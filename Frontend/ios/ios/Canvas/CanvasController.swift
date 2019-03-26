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
    private var colorPicker: ChromaColorPicker!;
    
    public var editor: Editor = Editor()
    
    @IBOutlet weak var insertButton: UIBarButtonItem!
    @IBOutlet var selectButton: UIBarButtonItem!
    @IBOutlet var deleteButton: UIBarButtonItem!
    @IBOutlet var borderButton: UIBarButtonItem!
    @IBOutlet var fillButton: UIBarButtonItem!
    
    @IBOutlet weak var exportButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad();
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        CollaborationHub.shared.connectToHub()
        
        // Color picker parameters.
        let pickerSize = CGSize(width: 200, height: 200);
        let pickerOrigin = CGPoint(x: 200, y: 100);
        colorPicker = ChromaColorPicker(frame: CGRect(origin: pickerOrigin, size: pickerSize))
        //        colorPicker.delegate = self as ChromaColorPickerDelegate;
        colorPicker.padding = 10
        colorPicker.stroke = 3 //stroke of the rainbow circle
        colorPicker.currentAngle = Float.pi
        colorPicker.hexLabel.textColor = UIColor.white
        colorPicker.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.1);
        self.view.addSubview(self.editor.editorView)
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
    
    // MARK: - Button Action Functions
    @IBAction func undoButton(_ sender: Any) {
        self.editor.undo(view: self.view);
    }
    
    @IBAction func redoButton(_ sender: Any) {
        self.editor.redo(view: self.view);
    }
    
    @IBAction func clearButton(_ sender: Any) {
        CollaborationHub.shared.reset();
    }
    
    @IBAction func deleteButton(_ sender: Any) {
        self.resetButtonColor();
        self.deleteButton.tintColor = UIColor.black;
        self.editor.changeTouchHandleState(to: .DELETE)
    }
    
    @IBAction func selectFigureButton(_ sender: Any) {
        self.resetButtonColor();
        self.selectButton.tintColor = UIColor.black;
        self.editor.changeTouchHandleState(to: .SELECT)
    }
    
    @IBAction func insertButtonPressed(_ sender: Any) {
        self.resetButtonColor();
        self.insertButton.tintColor = Constants.RED_COLOR;
        self.editor.changeTouchHandleState(to: .INSERT)
    }
    
    @IBAction func exportButtonPressed(_ sender: Any) {
        UIGraphicsBeginImageContextWithOptions(self.editor.editorView.bounds.size, false, 0.0)
        self.editor.editorView.drawHierarchy(in: self.editor.editorView.bounds, afterScreenUpdates: true)
        let image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        UIImageWriteToSavedPhotosAlbum(image!, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
        
    }
    
    private func resetButtonColor() -> Void {
        self.selectButton.tintColor = Constants.DEFAULT_BLUE_COLOR;
        self.deleteButton.tintColor = Constants.DEFAULT_BLUE_COLOR;
        self.insertButton.tintColor = Constants.DEFAULT_BLUE_COLOR;
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
}

