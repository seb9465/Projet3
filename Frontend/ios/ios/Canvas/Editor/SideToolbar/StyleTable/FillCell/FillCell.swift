//
//  FillCell.swift
//  ios
//
//  Created by William Sevigny on 2019-03-26.
//  Copyright © 2019 LOG3000 equipe 12. All rights reserved.
//

import UIKit

class FillCell: UITableViewCell {
    var delegate: SideToolbarDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        self.selectionStyle = UITableViewCell.SelectionStyle.none
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func blueSelected(_ sender: UIButton) {
        self.delegate?.setSelectedFigureFillColor(color: UIColor.blue)
    }
    
    @IBAction func greenSelected(_ sender: UIButton) {
        self.delegate?.setSelectedFigureFillColor(color: UIColor.green)
    }
    
    @IBAction func yellowSelected(_ sender: UIButton) {
        self.delegate?.setSelectedFigureFillColor(color: UIColor.yellow)
    }
    
    @IBAction func redSelected(_ sender: UIButton) {
        self.delegate?.setSelectedFigureFillColor(color: UIColor.red)
    }
    
    @IBAction func blackSelected(_ sender: UIButton) {
        self.delegate?.setSelectedFigureFillColor(color: UIColor.black)
    }
    
    @IBAction func whiteSelected(_ sender: UIButton) {
        self.delegate?.setSelectedFigureFillColor(color: UIColor.white)
    }
    
}
