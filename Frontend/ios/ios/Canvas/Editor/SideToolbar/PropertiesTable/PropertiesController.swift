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
        let attributesnib = UINib.init(nibName: "ClassCell", bundle: nil)
        self.propertiesTable.register(attributesnib, forCellReuseIdentifier: "ClassCell")
    }
}

extension PropertiesTableController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (self.editor.selectedFigure == nil ||  !self.editor.selectedFigure.isKind(of: UmlClassFigure.self)) {
            return 0
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 525
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if(self.editor.selectedFigure.isKind(of: UmlClassFigure.self)) {
            switch(indexPath.row) {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: "ClassCell", for: indexPath) as! ClassCell
                cell.setUpTable()
                cell.delegate = self.editor
                cell.classNameField.text = (self.editor.selectedFigure as! UmlClassFigure).className
                cell.methods = (self.editor.selectedFigure as! UmlClassFigure).methods
                cell.methodsTableView.reloadData()
                cell.attributes = (self.editor.selectedFigure as! UmlClassFigure).attributes
                cell.attributesTableView.reloadData()
                return cell
                
            default:
                return UITableViewCell();
            }
        }
        
        if(self.editor.selectedFigure.isKind(of: UmlCommentFigure.self)) {
            switch(indexPath.row) {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: "ClassCell", for: indexPath) as! ClassCell
                cell.setUpTable()
                cell.delegate = self.editor
                cell.classNameField.text = (self.editor.selectedFigure as! UmlClassFigure).className
                cell.methods = (self.editor.selectedFigure as! UmlClassFigure).methods
                cell.methodsTableView.reloadData()
                cell.attributes = (self.editor.selectedFigure as! UmlClassFigure).attributes
                cell.attributesTableView.reloadData()
                return cell
                
            default:
                return UITableViewCell();
            }
            
        }
        return UITableViewCell();
    }
}


extension PropertiesTableController: SideToolbarController {
    func update() {
        self.propertiesTable.reloadData()
    }
}

