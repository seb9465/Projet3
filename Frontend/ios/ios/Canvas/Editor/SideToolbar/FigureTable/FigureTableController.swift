//
//  FigureTableController.swift
//  ios
//
//  Created by William Sevigny on 2019-03-19.
//  Copyright © 2019 LOG3000 equipe 12. All rights reserved.
//

import UIKit

class FigureTableController: UIViewController, UIPopoverPresentationControllerDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, FigureCellProtocol {
    @IBOutlet weak var figureTable: UITableView!;
    private var editor: Editor!;
    
    override func viewDidLoad() {
        super.viewDidLoad();
        let nib = UINib.init(nibName: "FigureSelectionCell", bundle: nil);
        self.figureTable.register(nib, forCellReuseIdentifier: "FigureSelectionCell");
        let connectionsNib = UINib.init(nibName: "ConnectionSelectionCell", bundle: nil);
        self.figureTable.register(connectionsNib, forCellReuseIdentifier: "ConnectionSelectionCell");
        self.editor = (self.parent?.parent as! CanvasController).editor;
        self.figureTable.backgroundColor = #colorLiteral(red: 0.9681890607, green: 0.9681890607, blue: 0.9681890607, alpha: 1);
    }
    
    func setSelectedFigureType(itemType: ItemTypeEnum, isConnection: Bool) -> Void {
        self.editor.currentFigureType = itemType;
        self.editor.deselect();
        self.editor.touchEventState = (isConnection) ? .CONNECTION : .INSERT;
    }
    
    func presentImagePicker() {
        let imagePicker = UIImagePickerController();
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum) {
            imagePicker.delegate = self;
            imagePicker.sourceType = .photoLibrary;
            imagePicker.allowsEditing = false;
            
            imagePicker.modalPresentationStyle = .popover;
            let presentationController = imagePicker.popoverPresentationController;
            presentationController?.sourceView = self.figureTable.viewWithTag(1);
            
            imagePicker.popoverPresentationController?.delegate = self;
            self.present(imagePicker, animated: true, completion: nil);
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil);
        let cell = (self.figureTable.cellForRow(at: IndexPath(item: 0, section: 0)) as! FigureSelectionCell);
        cell.UMLClassSelected(cell.UMLClassButton);
    }
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

        self.dismiss(animated: true, completion: { () -> Void in });
    }
    
    func popoverPresentationControllerShouldDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) -> Bool {
        return false;
    }
}

extension FigureTableController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1;
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 900;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath.row == 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "FigureSelectionCell", for: indexPath) as! FigureSelectionCell
            cell.delegate = self;
            self.editor.sideToolbatControllers.append(cell);
            return cell;
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ConnectionSelectionCell", for: indexPath);
        
        return cell;
    }
}
