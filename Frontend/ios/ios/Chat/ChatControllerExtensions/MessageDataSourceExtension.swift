//
//  MessageDataSourceExtension.swift
//  ios
//
//  Created by Sebastien Cadorette on 2019-03-07.
//  Copyright © 2019 LOG3000 equipe 12. All rights reserved.
//

import UIKit
import MessageKit
import MessageInputBar

// MessagesDataSource qui donne le nombre et le contenu des messages
extension MsgChatController: MessagesDataSource {
    func numberOfSections( in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count;
    }
    
    func currentSender() -> Sender {
        return Sender(id: member.name, displayName: member.name);
    }
    
    func messageForItem(
        at indexPath: IndexPath,
        in messagesCollectionView: MessagesCollectionView) -> MessageKit.MessageType {
        
        
        return messages[indexPath.section];
    }
    
    func messageTopLabelHeight(
        for message: MessageKit.MessageType,
        at indexPath: IndexPath,
        in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        
        return 12;
    }
    
    func messageBottomLabelHeight(
        for message: MessageKit.MessageType,
        at indexPath: IndexPath,
        in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        
        return 12;
    }
    
    func messageTopLabelAttributedText(
        for message: MessageKit.MessageType,
        at indexPath: IndexPath) -> NSAttributedString? {
        
        return NSAttributedString(
            string: message.sender.displayName,
            attributes: [.font: UIFont.systemFont(ofSize: 12)]);
    }
    
    func messageBottomLabelAttributedText(for message: MessageKit.MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        
        return NSAttributedString(string: messages[indexPath.section].timestamp, attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption2)]);
    }
}
