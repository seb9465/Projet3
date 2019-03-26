//
//  PhaseCell.swift
//  ios
//
//  Created by Sébastien Labine on 19-03-26.
//  Copyright © 2019 LOG3000 equipe 12. All rights reserved.
//

import UIKit

class PhaseCell: UITableViewCell {

    @IBOutlet weak var phaseNameTextField: UITextField!
    var delegate: SideToolbarDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func PhaseChanged(_ sender: UITextField) {
        delegate?.setSelectedPhase(phaseName: sender.text!)
    }
}
