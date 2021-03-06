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
import JWTDecode

var canvasId: String = ""
var currentCanvas: Canvas = Canvas()

class CanvasController: UIViewController {
    
    // MARK: - Attributes
    var tabBar: UITabBarController?
    private var activeButton: UIBarButtonItem!;
    @IBOutlet weak var connectionLabel: UILabel!
    public var editor: Editor = Editor()
    @IBOutlet var navigationBar: UIToolbar!
    @IBOutlet var chatViewButton: UIBarButtonItem!
    @IBOutlet weak var lassoButton: UIBarButtonItem!
    @IBOutlet weak var quitButton: UIBarButtonItem!
    @IBOutlet weak var cutButton: UIBarButtonItem!
    @IBOutlet weak var duplicateButton: UIBarButtonItem!
    @IBOutlet weak var exportButton: UIBarButtonItem!
    @IBOutlet weak var switchButton: UISwitch!
    @IBOutlet weak var protectionLabel: UILabel!
    @IBOutlet var chatViewContainer: UIView!
    @IBOutlet var chatNotifLabel: UILabel!
    
    // MARK: - Timing functions
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        self.loadCanvas()
        CollaborationHub.shared = CollaborationHub(channelId: canvasId)
        CollaborationHub.shared!.connectToHub()
        CollaborationHub.shared!.delegate = self.editor
        self.editor.delegate = self
        self.initChatViewContainer();
        self.cutButton.isEnabled = false
        self.duplicateButton.isEnabled = false
        self.tabBar = children.flatMap({ $0 as? UITabBarController }).first
        
        self.view.addSubview(self.editor.editorView)
        setupNetwork()
        self.setChatNotifLabel();

        
        ChatService.shared.afkMessagesDidChangeClosure = {
            let channels: [String: [Message]] = ChatService.shared.messagesWhileAFK;
            print(channels);
            var counter: Int = 0;
            for channel in channels {
                counter += (channels[channel.key]?.count)!;
            }
            
            if (counter > 0) {
                self.chatNotifLabel.isHidden = false;
                self.chatNotifLabel.text = String(counter);
            } else {
                self.chatNotifLabel.isHidden = true;
                self.chatNotifLabel.text = "";
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated);
        
        navigationController?.setNavigationBarHidden(true, animated: animated);
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated);
        
        navigationController?.setNavigationBarHidden(false, animated: animated);
    }
    
    // MARK: Private functions
    
    private func setChatNotifLabel() -> Void {
        self.chatNotifLabel.layer.cornerRadius = self.chatNotifLabel.frame.width / 2;
        self.chatNotifLabel.layer.backgroundColor = Constants.Colors.DEFAULT_BLUE_COLOR.cgColor;
        self.chatNotifLabel.textColor = UIColor.white;
        self.chatNotifLabel.text = "";
        self.chatNotifLabel.textAlignment = .center;
        self.chatNotifLabel.isHidden = true;
    }
    
    private func loadCanvas() -> Void {
        var data: Data = currentCanvas.drawViewModels.data(using: String.Encoding.utf8)!
        let drawViewModels: [DrawViewModel] = try! JSONDecoder().decode(Array<DrawViewModel>.self, from: data)
        self.editor.loadCanvas(drawViewModels: drawViewModels)
        self.editor.resize(width: CGFloat(currentCanvas.canvasWidth), heigth: CGFloat(currentCanvas.canvasHeight))
        print(String(currentCanvas.canvasWidth) + String(currentCanvas.canvasHeight))
        let token = UserDefaults.standard.string(forKey: "token");
        let jwt = try! decode(jwt: token!)
        let username = jwt.claim(name: "unique_name").string
        if(currentCanvas.canvasAutor == username){
            self.protectionLabel.isHidden = false;
            self.switchButton.isHidden = false
            self.switchButton.isOn = currentCanvas.canvasProtection != ""
            if(self.switchButton.isOn) {
                self.protectionLabel.text = "Password Protection is ON"
            } else {
                self.protectionLabel.text = "Password Protection is OFF"
            }
        } else {
            self.protectionLabel.isHidden = true;
            self.switchButton.isHidden = true
            self.switchButton.isOn = false
            self.protectionLabel.text = "Password Protection is OFF"
        }
    }
    
    private func setupNetwork() -> Void {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(reachabilityChanged),
            name: NSNotification.Name.reachabilityChanged,
            object: nil
        )
        self.setupInternetConnectionState()
    }
    
    private func exportPNG() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.editor.editorView.bounds.size, false, 0.0);
        self.editor.editorView.drawHierarchy(in: self.editor.editorView.bounds, afterScreenUpdates: true);
        let image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return image!
    }
    
    private func initializeConnection() -> Void {
        CollaborationHub.shared = CollaborationHub(channelId: canvasId)
        CollaborationHub.shared!.connectToHub()
        CollaborationHub.shared!.delegate = self.editor
    }
    
    private func setupInternetConnectionState() -> Void {
        if reach!.isReachableViaWiFi() || reach!.isReachableViaWWAN() {
            self.connectionLabel.textColor = UIColor.green
            self.connectionLabel.text = "Online"
            self.quitButton.isEnabled = true
        } else {
            self.connectionLabel.text = "Offline"
            self.connectionLabel.textColor = UIColor.red
            self.quitButton.isEnabled = false
        }
    }
    
    private func initChatViewContainer() -> Void {
        self.chatViewContainer.sizeToFit();
        self.view.bringSubviewToFront(self.chatViewContainer);
        self.chatViewContainer.isHidden = true;
        self.chatViewContainer.layer.cornerRadius = Constants.ChatView.cornerRadius;
        self.chatViewContainer.layer.shadowColor = Constants.ChatView.shadowColor;
        self.chatViewContainer.layer.shadowOffset = Constants.ChatView.shadowOffset;
        self.chatViewContainer.layer.shadowOpacity = Constants.ChatView.shadowOpacity;
        self.chatViewContainer.layer.shadowRadius = Constants.ChatView.shadowRadius;
        self.chatViewContainer.layer.masksToBounds = false;
    }
    
    private func resetButtonColor() -> Void {
        self.lassoButton.tintColor = UIColor.black;
    }
    
    // MARK: - Action Functions
    
    @IBAction func undoButton(_ sender: Any) -> Void {
        self.editor.deselect();
        self.editor.undo(view: self.view);
    }
    
    @IBAction func redoButton(_ sender: Any) -> Void {
        self.editor.deselect();
        self.editor.redo(view: self.view);
    }
    
    @IBAction func cutButtonPressed(_ sender: Any) -> Void {
        self.editor.cut()
    }
    
    @IBAction func duplicateButtonPressed(_ sender: Any) -> Void {
        if (self.editor.selectedFigures.count == 0 && self.editor.clipboard.count == 0) {
            let alert: UIAlertController = UIAlertController(title: "Nothing to duplicate!", message: "Clipboard is empty and no figures are selected.", preferredStyle: .alert);
            let okAction: UIAlertAction = UIAlertAction(title: "Alright!", style: .default, handler: nil);
            alert.addAction(okAction);
            self.present(alert, animated: true);
        } else {
            self.editor.duplicate();
        }
    }
    
    @IBAction func clearButton(_ sender: Any) -> Void {
        self.editor.clear()
        CollaborationHub.shared!.reset();
        
    }
    
    
    @IBAction func lassoButton(_ sender: Any) -> Void {
        self.resetButtonColor();
        
        if (self.editor.touchEventState == .AREA_SELECT) {
            self.editor.changeTouchHandleState(to: .NONE);
        } else {
            self.lassoButton.tintColor = Constants.Colors.RED_COLOR;
            self.editor.changeTouchHandleState(to: .AREA_SELECT)
        }
        self.editor.deselect();
    }
    
    @IBAction func selectFigureButton(_ sender: Any) -> Void {
        self.resetButtonColor();
        
        if (self.editor.touchEventState == .SELECT) {
            self.editor.changeTouchHandleState(to: .NONE);
        } else {
            self.editor.changeTouchHandleState(to: .SELECT)
        }
        
        self.editor.deselect();
    }

    @IBAction func exportButtonPressed(_ sender: Any) {
        let image = self.exportPNG()
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil);
    }
    
    @IBAction func chatViewButton(_ sender: Any) {
        if (self.chatViewContainer.isHidden) {
            self.chatViewButton.tintColor = Constants.Colors.RED_COLOR;
            
            UIView.animate(withDuration: 0.35,
                           delay: 0.0,
                           usingSpringWithDamping: 0.9,
                           initialSpringVelocity: 1,
                           options: [],
                           animations: {
                            self.chatViewContainer.isHidden = false;
                            self.view.bringSubviewToFront(self.chatViewContainer);
                            self.view.layoutIfNeeded()
                            },
                           completion: nil
            );
            self.chatViewContainer.isHidden = false;
            self.view.addSubview(self.chatViewContainer);
            let view: UIView = self.view.subviews.last!;
            view.layoutIfNeeded();
        } else {
            self.chatViewButton.tintColor = UIColor.black;
            UIView.animate(withDuration: 0.35,
                           delay: 0.0,
                           usingSpringWithDamping: 0.9,
                           initialSpringVelocity: 1,
                           options: [],
                           animations: {
                            self.chatViewContainer.isHidden = true;
                            self.view.layoutIfNeeded()
                            },
                           completion: nil
            );
            self.chatViewContainer.isHidden = true;
            self.chatViewContainer.removeFromSuperview()
        }
    }
    
    @IBAction func switchButtonChanged (sender: UISwitch) {
        if(sender.isOn) {
            let passwordAlert = UIAlertController(title: "Password protection", message: "Please enter a password for this canvas", preferredStyle: .alert);
            passwordAlert.addTextField(configurationHandler: { (textField) in
                textField.placeholder = "password"
                textField.isSecureTextEntry = true
            })
            passwordAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { alert in
                sender.isOn = false
            }))
            passwordAlert.addAction(UIAlertAction(title: "Confirm", style: .default, handler: { alert in
                let enteredPassword = passwordAlert.textFields![0].text!
                self.protectionLabel.text = "Password Protection is ON"
                currentCanvas.canvasProtection = enteredPassword
                CanvasService.SaveOnline(canvas: currentCanvas).done({(result) in
                    CollaborationHub.shared!.changeProtection(isProtected: true)
                })
            }))
            self.present(passwordAlert, animated: true, completion: nil)
        } else {
            self.protectionLabel.text = "Password Protection is OFF"
            currentCanvas.canvasProtection = ""
            CanvasService.SaveOnline(canvas: currentCanvas)
            CollaborationHub.shared!.changeProtection(isProtected: false)
        }
    }
    
    @IBAction func quitButtonPressed(_ sender: Any) {
        let alert = UIAlertController(title: "Alert", message: "Would you like to quit ?", preferredStyle: .alert);
        let yesAction: UIAlertAction = UIAlertAction(title: "Yes", style: .default) { _ in
            self.editor.deselect()
            CollaborationHub.shared!.disconnectFromHub()
            currentCanvas = Canvas()
            NotificationCenter.default.removeObserver(self)
            self.dismiss(animated: true, completion: nil)
        }
        let noAction: UIAlertAction = UIAlertAction(title: "No", style: .default, handler: nil);
        
        alert.addAction(yesAction);
        alert.addAction(noAction);
        
        self.present(alert, animated: true, completion: nil);
    }
    
    // Mark: - Object functions
    
    @objc func reachabilityChanged(notification: NSNotification) -> Void {
        if reach!.isReachableViaWiFi() || reach!.isReachableViaWWAN() {
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
                    CollaborationHub.shared?.reset()
                    CollaborationHub.shared?.postNewFigure(figures: self.editor.figures)
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

extension CanvasController: EditorDelegate {
    func lassoIsDone() {
        self.resetButtonColor()
    }
    func setCurrentTab(index: Int) {
        self.tabBar?.selectedIndex = index
        self.tabBar?.selectedViewController =  self.tabBar?.viewControllers![index]
        self.view.setNeedsDisplay()
    }
    
    func setCutButtonState(isEnabled: Bool) {
        self.cutButton.isEnabled = isEnabled
    }
    func setDuplicateButtonState(isEnabled: Bool) {
        self.duplicateButton.isEnabled = isEnabled
    }
    
    func getKicked() {
        let updatedAlert = UIAlertController(title: "Kicked out", message: "You got kicked out because a password protection was added", preferredStyle: .alert)
        let okAction: UIAlertAction = UIAlertAction(title: "Ok", style: .default, handler: { _ in
            self.dismiss(animated: true, completion: nil)
        });
        updatedAlert.addAction(okAction)
        self.present(updatedAlert, animated: true, completion: {
        });
    }
}
