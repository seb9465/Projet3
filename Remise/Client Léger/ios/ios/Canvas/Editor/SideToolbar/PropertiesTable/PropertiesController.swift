//
//  StyleTableController.swift
//  ios
//
//  Created by William Sevigny on 2019-03-19.
//  Copyright © 2019 LOG3000 equipe 12. All rights reserved.
//

import UIKit

class PropertiesTableController: UIViewController {
    
    @IBOutlet weak var propertiesTable: UITableView!
    private var editor: Editor!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.editor = (self.parent?.parent as! CanvasController).editor
        self.editor.sideToolbatControllers.append(self)
        let classAttributesnib = UINib.init(nibName: "ClassCell", bundle: nil)
        self.propertiesTable.register(classAttributesnib, forCellReuseIdentifier: "ClassCell")
        
        let commentAttributesnib = UINib.init(nibName: "FigureNameCell", bundle: nil)
        self.propertiesTable.register(commentAttributesnib, forCellReuseIdentifier: "FigureNameCell")
        
        let connectionNib = UINib.init(nibName: "ConnectionCell", bundle: nil)
        self.propertiesTable.register(connectionNib, forCellReuseIdentifier: "ConnectionCell")
        self.propertiesTable.backgroundColor = #colorLiteral(red: 0.9681890607, green: 0.9681890607, blue: 0.9681890607, alpha: 1)
    }
}

extension PropertiesTableController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if(self.editor.selectedFigures.count > 1) {
            return 0;
        }
        if (self.editor.selectedFigures.isEmpty) {
            return 0
        }

        if (self.editor.selectedFigures[0] is UmlImageFigure) {
            return 0
        }
        
        if (self.editor.selectedFigures[0] is UmlClassFigure) {
            return 2
        }
        
        if (self.editor.selectedFigures[0] is ConnectionFigure) {
            return 2
        }
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath.row == 0) {
            return 125
        }
        
        if (self.editor.selectedFigures[0] is ConnectionFigure) {
            return 160
        }
    
        return 470
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (self.editor.selectedFigures.count > 1 || self.editor.selectedFigures.count == 0) {
            return UITableViewCell();
        }
        
        if (indexPath.row == 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "FigureNameCell", for: indexPath) as! FigureNameCell
            cell.setFigureTypeLabel(figureType: self.editor.selectedFigures[0].itemType.description + " Name")
            cell.nameInputField.text = self.editor.selectedFigures[0].name
            cell.delegate = self.editor
            return cell
        }
        
        if (self.editor.selectedFigures[0] is ConnectionFigure) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ConnectionCell", for: indexPath) as! ConnectionCell
            cell.sourceNameInputField.text = self.editor.selectedFigures[0].sourceName
            cell.destinationNameInputField.text = self.editor.selectedFigures[0].destinationName
            cell.delegate = self.editor
            return cell
        }
        
        // Quand on selectionne une classe
        let cell = tableView.dequeueReusableCell(withIdentifier: "ClassCell", for: indexPath) as! ClassCell
        cell.setUpTable()
        cell.delegate = self.editor
        cell.methods = (self.editor.selectedFigures[0] as! UmlClassFigure).methods
        cell.methodsTableView.reloadData()
        cell.attributes = (self.editor.selectedFigures[0] as! UmlClassFigure).attributes
        cell.attributesTableView.reloadData()
        return cell
    }
}


extension PropertiesTableController: SideToolbarController {
    func update() {
        self.propertiesTable.reloadData()
    }
}

