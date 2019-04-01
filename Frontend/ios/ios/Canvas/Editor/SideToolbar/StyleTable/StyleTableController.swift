//
//  StyleTableController.swift
//  ios
//
//  Created by William Sevigny on 2019-03-19.
//  Copyright © 2019 LOG3000 equipe 12. All rights reserved.
//

import UIKit

class StyleTableController: UIViewController {

    @IBOutlet weak var styleTable: UITableView!
    private var editor: Editor!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.editor = (self.parent?.parent as! CanvasController).editor
        self.editor.sideToolbatControllers.append(self)

        let nib = UINib.init(nibName: "BorderCell", bundle: nil)
        let rotateNib = UINib.init(nibName: "RotateCell", bundle: nil)
        self.styleTable.register(nib, forCellReuseIdentifier: "BorderCell")
        self.styleTable.register(rotateNib, forCellReuseIdentifier: "RotateCell")    }
}

extension StyleTableController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (self.editor.selectedFigures.isEmpty) {
            return 0
        }
        return 2
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath.row == 0) {
            return 150
        } else {
            return 525
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch(indexPath.row) {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "BorderCell", for: indexPath) as! BorderCell
            cell.delegate = self.editor
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "RotateCell", for: indexPath) as! RotateCell
            cell.delegate = self.editor
            return cell;
        default:
            return UITableViewCell();
        }
    }
}

extension StyleTableController: SideToolbarController {
    func update() {
        self.styleTable.reloadData()
    }
}
