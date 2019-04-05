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
var canvasId: String = ""
var currentCanvasString: String = "[]"
var currentCanvas: Canvas = Canvas()

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
    @IBOutlet weak var quitButton: UIBarButtonItem!
    
    @IBOutlet weak var exportButton: UIBarButtonItem!
    @IBOutlet var navigationBar: UIToolbar!
    
    override func viewDidLoad() {
        super.viewDidLoad();
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)

        self.loadCanvas()
        CollaborationHub.shared = CollaborationHub(channelId: canvasId)
        CollaborationHub.shared!.connectToHub()
        CollaborationHub.shared!.delegate = self.editor
        self.view.addSubview(self.editor.editorView)
        setupNetwork()
        
    }
    
    public func loadCanvas() {
        print("loading canvas")
        var data: Data = currentCanvasString.data(using: String.Encoding.utf8)!
        let drawViewModels: [DrawViewModel] = try! JSONDecoder().decode(Array<DrawViewModel>.self, from: data)
        self.editor.loadCanvas(drawViewModels: drawViewModels)
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
        self.editor.clear()
        CollaborationHub.shared!.reset();
        
    }
    
    @IBAction func deleteButton(_ sender: Any) {
        self.editor.deleteSelectedFigures()
        CollaborationHub.shared!.CutObjects(drawViewModels: [])
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
        let image = self.exportPNG()
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil);
    }
    
    public func exportPNG() -> UIImage {
    UIGraphicsBeginImageContextWithOptions(self.editor.editorView.bounds.size, false, 0.0);
    self.editor.editorView.drawHierarchy(in: self.editor.editorView.bounds, afterScreenUpdates: true);
    let image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
        return image!
    }
    
    private func resetButtonColor() -> Void {
        self.selectButton.tintColor = UIColor.black;
        self.deleteButton.tintColor = UIColor.black;
        self.insertButton.tintColor = UIColor.black;
        self.lassoButton.tintColor = UIColor.black;
    }
    
    private func initializeConnection() {
        CollaborationHub.shared = CollaborationHub(channelId: canvasId)
        CollaborationHub.shared!.connectToHub()
        CollaborationHub.shared!.delegate = self.editor
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

    @IBAction func quitButtonPressed(_ sender: Any) {
        let alert = UIAlertController(title: "Alert", message: "Would you like to quit ?", preferredStyle: .alert);
        let yesAction: UIAlertAction = UIAlertAction(title: "Yes", style: .default) { _ in
            CollaborationHub.shared!.disconnectFromHub()
            currentCanvas = Canvas()
            currentCanvasString = "[]"
            self.dismiss(animated: true, completion: nil)
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
            CollaborationHub.shared!.disconnectFromHub()
            var viewModels : [DrawViewModel] = []
            for figure in self.editor.figures {
                viewModels.append(figure.exportViewModel()!)
            }
            let viewModelsSorted = viewModels.sorted(by: { $0.ItemType!.rawValue < $1.ItemType!.rawValue })
                let existingViewModel = String(data: try! JSONEncoder().encode(viewModelsSorted), encoding: .utf8)!

                currentCanvas.image = (self.exportPNG().pngData()?.base64EncodedString())!
                currentCanvas.drawViewModels = existingViewModel
                CanvasService.SaveOnline(canvas: currentCanvas).done({(succes) in
                    if(succes) {
                    let updatedAlert = UIAlertController(title: "Canvas Updated", message: "All your modification while being offline were saved to the cloud!", preferredStyle: .alert)
                    updatedAlert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(updatedAlert, animated: true, completion: nil);
                    } else {
                    let errorAlert = UIAlertController(title: "Canvas Update Error", message: "Error while updating from cache.", preferredStyle: .alert)
                    errorAlert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(errorAlert, animated: true, completion: nil);
                    }})
            SoundNotification.play(sound: .EndVideo)

            self.initializeConnection()
        } else {

        SoundNotification.play(sound: .BeginVideo)
        }
        self.setupInternetConnectionState()
    }
    
    public func setupInternetConnectionState() {
          if self.reach!.isReachableViaWiFi() || self.reach!.isReachableViaWWAN() {
            self.connectionLabel.textColor = UIColor.green
            self.connectionLabel.text = "Online"
            self.quitButton.isEnabled = true
          } else {
            self.connectionLabel.text = "Offline"
            self.connectionLabel.textColor = UIColor.red
            self.quitButton.isEnabled = false
        }
    }
    deinit {
    }
}

