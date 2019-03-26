//
//  CommentCellTableViewCell.swift
//  ios
//
//  Created by Sébastien Labine on 19-03-21.
//  Copyright © 2019 LOG3000 equipe 12. All rights reserved.
//

import UIKit

class CommentCell: UITableViewCell {
    var delegate: SideToolbarDelegate?

    @IBOutlet weak var commentTextbox: UITextField!
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    @IBAction func commentTextChanged(_ sender: UITextField) {
        delegate?.setSelectedComment(comment: sender.text!)
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
