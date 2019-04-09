//
//  ClassAttributesCell.swift
//  ios
//
//  Created by William Sevigny on 2019-03-15.
//  Copyright © 2019 LOG3000 equipe 12. All rights reserved.
//

import UIKit

class ClassCell: UITableViewCell {
    var delegate: SideToolbarDelegate?
    var methods: [String] = []
    var attributes: [String] = []
    
    @IBOutlet weak var methodsTableView: UITableView!
    @IBOutlet weak var attributesTableView: UITableView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setUpTable(){
        self.methodsTableView?.delegate = self
        self.methodsTableView?.dataSource = self
        let nib = UINib.init(nibName: "ClassMethodCell", bundle: nil)
        self.methodsTableView.register(nib, forCellReuseIdentifier: "ClassMethodCell")
        let nibAdd = UINib.init(nibName: "AddMethodCell", bundle: nil)
        self.methodsTableView.register(nibAdd, forCellReuseIdentifier: "AddMethodCell")
        
        self.attributesTableView?.delegate = self
        self.attributesTableView?.dataSource = self
        let attrnib = UINib.init(nibName: "ClassAttributeCell", bundle: nil)
        self.attributesTableView.register(attrnib, forCellReuseIdentifier: "ClassAttributeCell")
        let addAttrnib = UINib.init(nibName: "AddAttributeCell", bundle: nil)
        self.attributesTableView.register(addAttrnib, forCellReuseIdentifier: "AddAttributeCell")
        self.methodsTableView.backgroundColor = #colorLiteral(red: 0.9681890607, green: 0.9681890607, blue: 0.9681890607, alpha: 1)
        self.attributesTableView.backgroundColor = #colorLiteral(red: 0.9681890607, green: 0.9681890607, blue: 0.9681890607, alpha: 1)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        self.selectionStyle = UITableViewCell.SelectionStyle.none
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}

extension ClassCell: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (tableView == self.methodsTableView) {
            return self.methods.count + 1
        }
        
        return self.attributes.count + 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (tableView == self.methodsTableView) {
            if(indexPath.row == 0) {
                let cell = tableView.dequeueReusableCell(withIdentifier: "AddMethodCell", for: indexPath) as! AddMethodCell
                cell.delegate = self.delegate
                return cell
            }
            let cell = tableView.dequeueReusableCell(withIdentifier: "ClassMethodCell", for: indexPath) as! ClassMethodCell
            cell.delegate = self.delegate
            cell.methodName.text = self.methods[indexPath.row - 1]
            cell.methodIndex = indexPath.row - 1
            return cell
        }
        
        if (indexPath.row == 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddAttributeCell", for: indexPath) as! AddAttributeCell
            cell.delegate = self.delegate
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "ClassAttributeCell", for: indexPath) as! ClassAttributeCell
        cell.delegate = self.delegate
        cell.attributeName.text = self.attributes[indexPath.row - 1]
        cell.attributeIndex = indexPath.row - 1
        return cell
    }
}
