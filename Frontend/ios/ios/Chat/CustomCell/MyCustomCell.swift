//
//  MyCustomCell.swift
//  ios
//
//  Created by Sebastien Cadorette on 2019-03-07.
//  Copyright © 2019 LOG3000 equipe 12. All rights reserved.
//

import Foundation
import MessageKit

// Customize this collection view cell with data passed in from message, which is of type .custom
open class MyCustomCell: UICollectionViewCell {
    open func configure(with message: MessageType, at indexPath: IndexPath, and messagesCollectionView: MessagesCollectionView) {
        print("MY CUSTOM CELL");
        self.contentView.backgroundColor = UIColor.red
        
    }
    
}
