//
//  BorderCell.swift
//  ios
//
//  Created by William Sevigny on 2019-03-14.
//  Copyright © 2019 LOG3000 equipe 12. All rights reserved.
//

import UIKit

class RotateCell: UITableViewCell {
    var delegate: SideToolbarDelegate?
    
    override func awakeFromNib() {
        self.selectionStyle = UITableViewCell.SelectionStyle.none
        super.awakeFromNib()
    }
    
    @IBAction func RotateLeft(_ sender: UIButton) {
        self.delegate?.rotate(orientation: RotateOrientation.left)
    }
    @IBAction func RotateRight(_ sender: UIButton) {
        self.delegate?.rotate(orientation: RotateOrientation.right)
    }
}

public enum RotateOrientation {
    case left
    case right
}
