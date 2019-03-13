//
//  ConvasController.swift
//  ios
//
//  Created by Sebastien Cadorette on 2019-02-12.
//  Copyright © 2019 LOG3000 equipe 12. All rights reserved.
//

import ChromaColorPicker
import UIKit

enum STATE {
    case NOTHING_SELECTED
    case DRAW_RECT
    case CLEAR
    case SELECTION
    case DELETE
    case FILL
    case BORDER_COLOR
}

class CanvasController: UIViewController, CollaborationHubDelegate {
    
    // MARK: - Attributes
    private var toolState: STATE  = STATE.SELECTION;
    private var previousToolState: STATE = STATE.NOTHING_SELECTED;
//    public var canvas: CanvasService = CanvasService();
    private var activeButton: UIBarButtonItem!;
    private var colorPicker: ChromaColorPicker!;
    
    public var editor: Editor = Editor()
//    public var editorView: EditorView = EditorView();
    
    @IBOutlet var rectButton: UIBarButtonItem!
    @IBOutlet var selectButton: UIBarButtonItem!
    @IBOutlet var deleteButton: UIBarButtonItem!
    @IBOutlet var borderButton: UIBarButtonItem!
    @IBOutlet var fillButton: UIBarButtonItem!
    
    // MARK: - Public Functions
    
    override func viewDidLoad() {
        super.viewDidLoad();

        CollaborationHub.shared.connectToHub()

        self.addTapGestureRecognizer();
        let pan = UIPanGestureRecognizer(target: self, action: #selector(self.handlePan(sender:)))
        self.view.addGestureRecognizer(pan);
        
        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(self.handlePinch(sender:)))
        self.view.addGestureRecognizer(pinch)

        // Color picker parameters.
        let pickerSize = CGSize(width: 200, height: 200);
        let pickerOrigin = CGPoint(x: 200, y: 100);
        colorPicker = ChromaColorPicker(frame: CGRect(origin: pickerOrigin, size: pickerSize))
        colorPicker.delegate = self as ChromaColorPickerDelegate;
        colorPicker.padding = 10
        colorPicker.stroke = 3 //stroke of the rainbow circle
        colorPicker.currentAngle = Float.pi
        colorPicker.hexLabel.textColor = UIColor.white
        colorPicker.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.1);
        
        CollaborationHub.shared.delegate = self
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
    
    @objc func handleTap(sender: UITapGestureRecognizer? = nil) {
        // Click coordinates with the editor subview
        var tapPoint: CGPoint = (sender?.location(in: self.editor.editorView))!;
        
        if (tapPoint.y < 0) {
            tapPoint.y = 0
        }
        
        switch(self.toolState) {
            case .SELECTION :
                let res: Bool = self.editor.selectFigure(tapPoint: tapPoint);
                self.borderButton.isEnabled = res;
                self.fillButton.isEnabled = res;
                break
            case .DRAW_RECT:
                CollaborationHub.shared.updateDrawing(origin: tapPoint)
                break
            case .CLEAR:
                break
            case .DELETE:
                self.editor.deleteFigure(tapPoint: tapPoint);
                break
            case .FILL:
                break
            case .BORDER_COLOR:
                break
            case .NOTHING_SELECTED:
                break
        }
    }
    
    @objc func handlePan(sender: UIPanGestureRecognizer? = nil) {
//        print("pan")
//        let translation = sender!.translation(in: self.editor.editorView)
////        self.editor.moveFigure(translation: translation);
//
//        self.editor.resizeFigure(translation: translation)
//        sender!.setTranslation(CGPoint.zero, in: self.editor.editorView)
    }
    
    @objc func handlePinch(sender: UIPinchGestureRecognizer? = nil) {
  
    }
    
    
    func updateCanvas(firsPoint: CGPoint, lastPoint: CGPoint) {
        self.editor.insertFigure(firstPoint: firsPoint, lastPoint: lastPoint)
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
        if (self.toolState == STATE.DELETE) {
            self.toolState = STATE.NOTHING_SELECTED;
            self.activeButton = nil;
            self.deleteButton.tintColor = UIColor(red: 0, green: 122/255, blue: 1, alpha: 1);
        } else {
            print("DELETE BUTTON SELECTED");
            self.toolState = STATE.DELETE;
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
        self.displayColorPickerFor(state: STATE.BORDER_COLOR);
    }
    
    @IBAction func fillButton(_ sender: Any) {
        print("FILL BUTTON TAPED");
        self.displayColorPickerFor(state: STATE.FILL);
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
    private func displayColorPickerFor(state: STATE) -> Void {
        self.previousToolState = self.toolState;
        self.toolState = state;
        self.view.addSubview(colorPicker)
    }
    
    func clear() {
            self.editor.clear();
    }
    
    private func addTapGestureRecognizer() -> Void {
        let tap = UITapGestureRecognizer(target: self, action: #selector(CanvasController.handleTap(sender:)))
        self.view.addGestureRecognizer(tap);
    }
}

extension CanvasController: ChromaColorPickerDelegate {
    func colorPickerDidChooseColor(_ colorPicker: ChromaColorPicker, color: UIColor) {
        switch (self.toolState) {
        case STATE.FILL:
           self.editor.setSelectedFigureColor(color: color);
            break;
        case STATE.BORDER_COLOR:
            self.editor.setSelectFigureBorderColor(color: color);
            break;
        default:
            break;
        }
        self.toolState = self.previousToolState;
        self.colorPicker.removeFromSuperview();
    }
}
