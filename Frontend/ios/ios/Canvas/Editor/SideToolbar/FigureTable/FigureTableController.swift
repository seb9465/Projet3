//
//  FigureTableController.swift
//  ios
//
//  Created by William Sevigny on 2019-03-19.
//  Copyright © 2019 LOG3000 equipe 12. All rights reserved.
//

import UIKit

class FigureTableController: UIViewController, FigureCellProtocol {
    @IBOutlet weak var figureTable: UITableView!
    private var editor: Editor!
    override func viewDidLoad() {
        super.viewDidLoad()

        let nib = UINib.init(nibName: "FigureSelectionCell", bundle: nil)
        self.figureTable.register(nib, forCellReuseIdentifier: "FigureSelectionCell")
        self.editor = (self.parent?.parent as! CanvasController).editor
        // Do any additional setup after loading the view.
    }
    
    func setSelectedFigureType(itemType: ItemTypeEnum) -> Void {
        self.editor.currentFigureType = itemType
    }
    
    func setSelectedLineType(itemType: ItemTypeEnum) -> Void {
        self.editor.currentLineType = itemType
    }
}

extension FigureTableController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
       return 600
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FigureSelectionCell", for: indexPath) as! FigureSelectionCell
        cell.delegate = self
        return cell
    }
}
