//
//  FigureTableController.swift
//  ios
//
//  Created by William Sevigny on 2019-03-19.
//  Copyright © 2019 LOG3000 equipe 12. All rights reserved.
//

import UIKit

class FigureTableController: UIViewController, UIPopoverPresentationControllerDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, FigureCellProtocol {
    @IBOutlet weak var figureTable: UITableView!
    private var editor: Editor!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nib = UINib.init(nibName: "FigureSelectionCell", bundle: nil)
        self.figureTable.register(nib, forCellReuseIdentifier: "FigureSelectionCell")
        let connectionsNib = UINib.init(nibName: "ConnectionSelectionCell", bundle: nil)
        self.figureTable.register(connectionsNib, forCellReuseIdentifier: "ConnectionSelectionCell")
        self.editor = (self.parent?.parent as! CanvasController).editor
        // Do any additional setup after loading the view.
    }
    
    func setSelectedFigureType(itemType: ItemTypeEnum) -> Void {
        self.editor.currentFigureType = itemType
    }
    
    func setSelectedLineType(itemType: ItemTypeEnum) -> Void {
        self.editor.currentLineType = itemType
    }
    
    func presentImagePicker() {
        let imagePicker = UIImagePickerController()
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum){
            imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary
            imagePicker.allowsEditing = false
            
            
            imagePicker.modalPresentationStyle = .popover
            let presentationController = imagePicker.popoverPresentationController
            presentationController?.sourceView = self.figureTable.viewWithTag(1)
            
            imagePicker.popoverPresentationController?.delegate = self
            self.present(imagePicker, animated: true, completion: nil)
        }

    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
            let cell = (self.figureTable.cellForRow(at: IndexPath(item: 0, section: 0)) as! FigureSelectionCell)
        cell.UMLClassSelected(cell.UMLClassButton)
    }
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

        self.dismiss(animated: true, completion: { () -> Void in })
        if let img = info[.originalImage] {
            print(img)
        }
        
        //TODO: Do something with the image
    }
    func popoverPresentationControllerShouldDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) -> Bool {
        return false
    }
}

extension FigureTableController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath.row == 0) {
            return 731
        }
        
        return 400
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath.row == 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "FigureSelectionCell", for: indexPath) as! FigureSelectionCell
            cell.delegate = self
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "ConnectionSelectionCell", for: indexPath)
        return cell
    }
}
