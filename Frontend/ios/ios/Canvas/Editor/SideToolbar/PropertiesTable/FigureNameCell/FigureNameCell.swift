//
//  FigureNameCell.swift
//  ios
//
//  Created by William Sevigny on 2019-04-02.
//  Copyright © 2019 LOG3000 equipe 12. All rights reserved.
//

import UIKit

class FigureNameCell: UITableViewCell {
    var delegate: SideToolbarDelegate?
    @IBOutlet weak var figureNameLabel: UILabel!
    @IBOutlet weak var nameInputField: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        self.selectionStyle = UITableViewCell.SelectionStyle.none
        super.setSelected(selected, animated: animated)
    }
    
    func setFigureTypeLabel(figureType: String) {
        self.figureNameLabel.text = figureType
    }
    
    @IBAction func nameInputChanged(_ sender: UITextField) {
        self.delegate?.setSelectedFigureName(name: sender.text!)
    }
    @IBAction func nameInputDidEnd(_ sender: Any) {
        self.delegate?.setSelectedFigureNameDidEnd();
    }
}
