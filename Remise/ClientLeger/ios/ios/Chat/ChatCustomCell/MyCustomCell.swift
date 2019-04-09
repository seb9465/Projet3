//
//  MyCustomCell.swift
//  ios
//
//  Created by Sebastien Cadorette on 2019-03-07.
//  Copyright © 2019 LOG3000 equipe 12. All rights reserved.
//

import Foundation
import MessageKit

open class MyCustomCell: UICollectionViewCell {
    let label = UILabel();
    
    public override init(frame: CGRect) {
        super.init(frame: frame);
        setupSubviews();
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
        setupSubviews();
    }
    
    open func setupSubviews() {
        contentView.addSubview(label);
        label.textAlignment = .center;
        label.font = UIFont.italicSystemFont(ofSize: 13);
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews();
        label.frame = contentView.bounds;
    }
    
    open func configure(with message: MessageType, at indexPath: IndexPath, and messagesCollectionView: MessagesCollectionView) {
        self.contentView.backgroundColor = UIColor.clear
        switch(message.kind) {
        case .custom(let data):
            guard let systemMessage = data as? String else { return }
            label.text = systemMessage;
        default:
            break;
        }
    }
}
