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
        
        let commentAttributesnib = UINib.init(nibName: "CommentCell", bundle: nil)
        self.propertiesTable.register(commentAttributesnib, forCellReuseIdentifier: "CommentCell")

        let textAttributesnib = UINib.init(nibName: "TextCell", bundle: nil)
        self.propertiesTable.register(textAttributesnib, forCellReuseIdentifier: "TextCell")
        
        let phaseAttributesnib = UINib.init(nibName: "PhaseCell", bundle: nil)
        self.propertiesTable.register(phaseAttributesnib, forCellReuseIdentifier: "PhaseCell")
    }
}

extension PropertiesTableController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (self.editor.selectedFigures.isEmpty){
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 525
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (self.editor.selectedFigures.count > 1 || self.editor.selectedFigures.count == 0) {
            return UITableViewCell();
        }
        
        switch(self.editor.selectedFigures[0]) {
        case is UmlClassFigure:
            switch(indexPath.row) {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: "ClassCell", for: indexPath) as! ClassCell
                cell.setUpTable()
                cell.delegate = self.editor
                cell.classNameField.text = (self.editor.selectedFigures[0] as! UmlClassFigure).className
                cell.methods = (self.editor.selectedFigures[0] as! UmlClassFigure).methods
                cell.methodsTableView.reloadData()
                cell.attributes = (self.editor.selectedFigures[0] as! UmlClassFigure).attributes
                cell.attributesTableView.reloadData()
                return cell
            default:
                return UITableViewCell();
            }
        case is UmlCommentFigure:
                switch(indexPath.row) {
                case 0:
                    let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath) as! CommentCell
                    cell.delegate = self.editor
                    cell.commentTextbox.text = (self.editor.selectedFigures[0] as! UmlCommentFigure).comment
                    return cell
                default:
                    return UITableViewCell();
                }
        case is UMLTextFigure:
            switch(indexPath.row) {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: "TextCell", for: indexPath) as! TextCell
                cell.delegate = self.editor
                cell.TextBoxField.text = (self.editor.selectedFigures[0] as! UMLTextFigure).text
                return cell
            default:
                return UITableViewCell();
            }
            
        case is UmlPhaseFigure:
            switch(indexPath.row) {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: "PhaseCell", for: indexPath) as! PhaseCell
                cell.delegate = self.editor
                cell.phaseNameTextField.text = (self.editor.selectedFigures[0] as! UmlPhaseFigure).phaseName
                return cell
            default:
                return UITableViewCell();
            }
        default:
            return UITableViewCell();
        }
    }
}


extension PropertiesTableController: SideToolbarController {
    func update() {
        self.propertiesTable.reloadData()
    }
}

