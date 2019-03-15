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
    
    @IBOutlet weak var attributesTableView: UITableView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setUpTable(){
        self.attributesTableView?.delegate = self
        self.attributesTableView?.dataSource = self
        let nib = UINib.init(nibName: "ClassMethodCell", bundle: nil)
        self.attributesTableView.register(nib, forCellReuseIdentifier: "ClassMethodCell")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        self.selectionStyle = UITableViewCell.SelectionStyle.none
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBAction func nameAttributeChanged(_ sender: UITextField) {
        delegate?.setSelectedFigureName(name: sender.text!)
    }
}

extension ClassCell: UITableViewDataSource,UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ClassMethodCell", for: indexPath)
        return cell
    }
}
