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
    
    // MARK: - Public Functions
    
    override func viewDidLoad() {
        super.viewDidLoad();
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
        self.editor.changeTouchHandleState(to: .DELETE)
    }
    
    @IBAction func selectFigureButton(_ sender: Any) {
        self.editor.changeTouchHandleState(to: .SELECT)
    }
    
    @IBAction func insertButtonPressed(_ sender: Any) {
        self.editor.changeTouchHandleState(to: .INSERT)
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
//        self.displayColorPickerFor(state: STATE.BORDER_COLOR);
    }
    
    @IBAction func fillButton(_ sender: Any) {
        print("FILL BUTTON TAPED");
//        self.displayColorPickerFor(state: STATE.FILL);
    }
}
    
    // MARK: - Private Functions
    
    /**
     Displays the color picker.
     
     - parameters:
        - state: The state for which the color picker picker will be showed.
     - returns: Nothing
     - author:
     Sebastien Cadorette
    */
//    private func displayColorPickerFor(state: STATE) -> Void {
//        self.previousToolState = self.toolState;
//        self.toolState = state;
//        self.view.addSubview(colorPicker)
//    }
    
//    private func addTapGestureRecognizer() -> Void {
//        let tap = UITapGestureRecognizer(target: self, action: #selector(CanvasController.handleTap(sender:)))
//        self.view.addGestureRecognizer(tap);
//    }


//extension CanvasController: ChromaColorPickerDelegate {
//    func colorPickerDidChooseColor(_ colorPicker: ChromaColorPicker, color: UIColor) {
//        switch (self.toolState) {
//        case STATE.FILL:
//           self.editor.setSelectedFigureColor(color: color);
//            break;
//        case STATE.BORDER_COLOR:
//            self.editor.setSelectFigureBorderColor(color: color);
//            break;
//        default:
//            break;
//        }
//        self.toolState = self.previousToolState;
//        self.colorPicker.removeFromSuperview();
//    }
//}
