//
//  MessageInpuBarExtension.swift
//  ios
//
//  Created by Sebastien Cadorette on 2019-03-07.
//  Copyright © 2019 LOG3000 equipe 12. All rights reserved.
//

import Foundation
import UIKit
import MessageKit
import MessageInputBar

// MessageInputBarDelegate qui permet le controle de l'envoie et de l'ecriture des nouveaux messages.
extension MsgChatController: MessageInputBarDelegate {
    func messageInputBar(
        _ inputBar: MessageInputBar,
        didPressSendButtonWith text: String) {
        
        let date = Date();
        let dateFormatter = DateFormatter();
        dateFormatter.dateFormat = "HH:mm:ss";
        let result = dateFormatter.string(from: date);
        
        let newMessage = Message(
            member: member,
            text: text,
            timestamp: result,
            messageId: UUID().uuidString
        );

        ChatService.shared.sendMessage(currentUser: self.member.name, message: newMessage, insertMessage: self.insertMessage);
        inputBar.inputTextView.text = "";
        self.messagesCollectionView.reloadData();
        self.messagesCollectionView.scrollToBottom(animated: true);
    }
}
