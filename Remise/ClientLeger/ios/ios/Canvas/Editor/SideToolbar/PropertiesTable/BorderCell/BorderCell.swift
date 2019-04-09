//
//  BorderCell.swift
//  ios
//
//  Created by William Sevigny on 2019-03-14.
//  Copyright © 2019 LOG3000 equipe 12. All rights reserved.
//

import UIKit

class BorderCell: UITableViewCell {
    @IBOutlet weak var buttonBlue: UIButton!
    var delegate: SideToolbarDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        self.selectionStyle = UITableViewCell.SelectionStyle.none

        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func blueSelected(_ sender: UIButton) {
        self.delegate?.setSelectedFigureBorderColor(color: UIColor.blue)
    }
    
    @IBAction func redSelected(_ sender: UIButton) {
        self.delegate?.setSelectedFigureBorderColor(color: UIColor.red)
    }
    
    @IBAction func yellowSelected(_ sender: UIButton) {
        self.delegate?.setSelectedFigureBorderColor(color: UIColor.yellow)
    }
    
    @IBAction func greenSelected(_ sender: UIButton) {
        self.delegate?.setSelectedFigureBorderColor(color: UIColor.green)
    }
    
    @IBAction func fullLineSelected(_ sender: UIButton) {
    }
    @IBAction func dashedLineSelected(_ sender: UIButton) {
    }
}
