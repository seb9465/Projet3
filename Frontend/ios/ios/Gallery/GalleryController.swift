//
//  PublicGalleryController.swift
//  ios
//
//  Created by William Sevigny on 2019-03-21.
//  Copyright © 2019 LOG3000 equipe 12. All rights reserved.
//

import UIKit
import Reachability
class GalleryController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    private var canvas : [Canvas] = []
    private let itemsPerRow: CGFloat = 4
    private let sectionInsets = UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0)
    private var canvasController: CanvasController = CanvasController()
    var reach: Reachability?
    override func viewDidLoad() {
        super.viewDidLoad()
        let nib = UINib.init(nibName: "GalleryCell", bundle: nil)
        self.collectionView.register(nib, forCellWithReuseIdentifier: "GalleryCell")
        self.canvasController = UIStoryboard(name: "Canvas", bundle: nil).instantiateViewController(withIdentifier: "CanvasController") as! CanvasController
    }
    override func viewWillAppear(_ animated: Bool){
        self.setupNetwork()
        self.loadCanvas()
    }
    @IBAction func updateGallery(_ sender: Any) {
        self.viewWillAppear(true)
    }
    
    func loadCanvas() {
        let spinner = UIViewController.displaySpinner(onView: self.view);
        CanvasService.getAllCanvas(includePrivate: false)
            .done { (retreivedCanvas) in
                self.canvas = retreivedCanvas
                self.collectionView.reloadData()
                UIViewController.removeSpinner(spinner: spinner);
            }.catch { (Error) in
                print("Fetch for canvas failed", Error)
                UIViewController.removeSpinner(spinner: spinner);
        }
    }
    
    func setupNetwork() {
        self.reach = Reachability.forInternetConnection()
        self.reach!.reachableOnWWAN = false
        self.reach!.startNotifier()
    }

    deinit {
        self.canvas = []
    }
}

extension GalleryController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return canvas.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GalleryCell", for: indexPath) as! GalleryCell
        cell.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tap(_:))))
        cell.visibility = canvas[indexPath.row].canvasVisibility
        cell.password = canvas[indexPath.row].canvasProtection
        cell.canvasId = canvas[indexPath.row].canvasId
        cell.nameLabel.text = canvas[indexPath.row].name
        cell.drawViewModels = canvas[indexPath.row].drawViewModels
        cell.author = canvas[indexPath.row].canvasAutor
        cell.image = canvas[indexPath.row].image
        cell.setImageFromBytes(bytesString: canvas[indexPath.row].image)
        return cell
    }
    
    @objc func tap(_ sender: UITapGestureRecognizer) {
        
        let location = sender.location(in: self.collectionView)
        let indexPath = self.collectionView.indexPathForItem(at: location)
        
        if let index = indexPath {
            let cell = (self.collectionView.cellForItem(at: index) as! GalleryCell)
            canvasId = cell.canvasId
            currentCanvasString = cell.drawViewModels
            currentCanvas = Canvas(canvasId: cell.canvasId, name: cell.nameLabel.text!, drawViewModels: cell.drawViewModels, image: cell.image, canvasVisibility: cell.visibility, canvasAutor: cell.author, canvasProtection: cell.password)
            var enteredPassword = ""
            if(cell.password != "") {
              
                let passwordAlert = UIAlertController(title: "Password Required", message: "This canvas is password protected. Please enter the password to gain access.", preferredStyle: .alert)
                passwordAlert.addTextField(configurationHandler: { (textField) in
                    textField.placeholder = "password"
                    textField.isSecureTextEntry = true
                })
                passwordAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                passwordAlert.addAction(UIAlertAction(title: "Confirm", style: .default, handler: { alert in
                    enteredPassword = passwordAlert.textFields![0].text!
                    if(cell.password == enteredPassword) {
                        print("good password")
                        self.canvasController = UIStoryboard(name: "Canvas", bundle: nil).instantiateViewController(withIdentifier: "CanvasController") as! CanvasController
                        NotificationCenter.default.removeObserver(self)
                        self.present(self.canvasController, animated: true, completion: nil);
                    } else {
                         let wrongPasswordAlert = UIAlertController(title: "Wrong password", message: "You have entered a wrong password.", preferredStyle: .alert)
                        wrongPasswordAlert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
                        self.present(wrongPasswordAlert, animated: true, completion: nil)
                    }
                }))
            self.present(passwordAlert, animated: true, completion: nil)
            } else {
                self.canvasController = UIStoryboard(name: "Canvas", bundle: nil).instantiateViewController(withIdentifier: "CanvasController") as! CanvasController
                NotificationCenter.default.removeObserver(self)
                self.present(self.canvasController, animated: true, completion: nil);      }
        }
    }
}

extension GalleryController : UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        return CGSize(width: widthPerItem, height: widthPerItem)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
}
