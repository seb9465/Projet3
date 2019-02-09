//
//  msgChatCntrlr.swift
//  ios
//
//  Created by Sebastien Cadorette on 2019-01-31.
//  Copyright © 2019 LOG3000 equipe 12. All rights reserved.
//

import UIKit
import MessageKit
import MessageInputBar
import SwiftSignalRClient
import JWTDecode
import PromiseKit
import AwaitKit

let CHAT_URL = "https://polypaint.me/signalr";
let USER_TOKEN = UserDefaults.standard.string(forKey: "token");

class MsgChatController: MessagesViewController {
    var chatService: ChatService!;
//    var hubConnection: HubConnection!;
    var connectedToGroup: Bool = false;
    var messages: [Message] = [];
    var member: Member!;
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        self.chatService = ChatService();
        self.chatService.connectToHub();
        self.setCurrentMemberAttributes();
        self.initDelegate();
        self.chatService.initOnReceivingMessage(currentMemberName: self.member.name, function: self.insertMessage)
        self.chatService.initOnAnotherUserConnection(function: self.insertMessage);
        self.chatService.connectToGroup();
    }
    
    override func viewWillDisappear(_ animated: Bool) -> Void {
        // super.viewWillDisappear(animated);
        
        self.chatService.disconnectFromHub();
    }
    
    func messageInputBar(_ inputBar: MessageInputBar, textViewTextDidChangeTo text: String) {
        if(messageInputBar.inputTextView.text.contains("\n")) {
            messageInputBar.inputTextView.text.popLast();
            if(messageInputBar.sendButton.isEnabled) {
                messageInputBar.didSelectSendButton();
            }
        }
    }
    
    func initDelegate() -> Void {
        messagesCollectionView.messagesDataSource = self;
        messagesCollectionView.messagesLayoutDelegate = self;
        messageInputBar.delegate = self;
        messagesCollectionView.messagesDisplayDelegate = self;
    }
    
    func setCurrentMemberAttributes() -> Void {
        let jwt = try! decode(jwt: USER_TOKEN!);
        let name = jwt.claim(name: "unique_name").string;
        
        self.member = Member(name: name!, color: .random);
    }
    
    func insertMessage(_ message: Message) -> Void {
        messages.append(message);
        
        messagesCollectionView.performBatchUpdates({
            messagesCollectionView.insertSections([messages.count - 1]);
        }, completion: { [weak self] _ in
            if self?.isLastSectionVisible() == true {
                self?.messagesCollectionView.scrollToBottom(animated: true);
            }
        });
    }
    
    func isLastSectionVisible() -> Bool {
        
        guard !messages.isEmpty else {
            return false;
        }
        
        let lastIndexPath = IndexPath(item: 0, section: messages.count - 1);
        
        return messagesCollectionView.indexPathsForVisibleItems.contains(lastIndexPath);
    }
}

// 4 protocoles implementés pour connecter les messages au UI & controler les interactions.
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

// MessagesLayoutDelegate qui donne la hauteur, le padding et l'alignement des differentes vues.
extension MsgChatController: MessagesLayoutDelegate {
    func heightForLocation(message: MessageKit.MessageType,
                           at indexPath: IndexPath,
                           with maxWidth: CGFloat,
                           in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        
        return 0;
    }
}

// MessagesDisplayDelegate qui donne la couleur, le style et les vues qui definisse l'allure des messages.
extension MsgChatController: MessagesDisplayDelegate {
    func configureAvatarView(
        _ avatarView: AvatarView,
        for message: MessageKit.MessageType,
        at indexPath: IndexPath,
        in messagesCollectionView: MessagesCollectionView) {
        
        let message = messages[indexPath.section];
        let color = message.member.color;
        avatarView.backgroundColor = color;
    }
}

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
            messageId: UUID().uuidString)
        
        self.chatService.sendMessage(message: newMessage, function: self.insertMessage);
        inputBar.inputTextView.text = "";
        self.messagesCollectionView.reloadData();
        self.messagesCollectionView.scrollToBottom(animated: true);
        
    }
}
