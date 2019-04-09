//
//  CustomTableViewCell.swift
//  ios
//
//  Created by Sebastien Cadorette on 2019-03-10.
//  Copyright © 2019 LOG3000 equipe 12. All rights reserved.
//

import UIKit

class CustomTableViewCell: UITableViewCell {

    @IBOutlet var cellView: UIView!
    @IBOutlet var tableViewCell: UIView!
    @IBOutlet var chatRoomName: UILabel!
    @IBOutlet var notificationLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
//        self.tableViewCell.layer.borderWidth = 1;
//        self.tableViewCell.layer.borderColor = UIColor(red: 1, green: 0, blue: 0, alpha: 1).cgColor;
        self.chatRoomName.textColor = UIColor.white;
        self.notificationLabel.textColor = Constants.Colors.RED_COLOR;
        self.notificationLabel.layer.cornerRadius = 0.5 * self.notificationLabel.bounds.size.width;
        self.hideCircleLabel();
        self.cellView.backgroundColor = Constants.Colors.RED_COLOR;
        self.cellView.layer.cornerRadius = 5;
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated);
    }
    
    public func showCircleLabel() -> Void {
        self.notificationLabel.layer.backgroundColor = UIColor.white.cgColor;
    }
    
    public func hideCircleLabel() -> Void {
        self.notificationLabel.layer.backgroundColor = UIColor.clear.cgColor;
    }
}
