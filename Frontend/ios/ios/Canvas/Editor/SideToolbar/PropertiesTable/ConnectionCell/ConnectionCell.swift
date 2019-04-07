//
//  ConnectionCell.swift
//  ios
//
//  Created by William Sevigny on 2019-04-06.
//  Copyright © 2019 LOG3000 equipe 12. All rights reserved.
//

import UIKit

class ConnectionCell: UITableViewCell {
    var delegate: SideToolbarDelegate?
    
    @IBOutlet weak var sourceNameInputField: UITextField!
    @IBOutlet weak var destinationNameInputField: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        self.selectionStyle = UITableViewCell.SelectionStyle.none
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func changeSourceName(_ sender: UIButton) {
        self.delegate?.setSelectedFigureSourceLabel(name: self.sourceNameInputField.text!)
    }
    
    @IBAction func changeDestinationName(_ sender: UIButton) {
         self.delegate?.setSelectedFigureDestinationLabel(name: self.destinationNameInputField.text!)
    }
}
