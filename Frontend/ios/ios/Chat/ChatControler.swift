//
//  ChatController.swift
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

let USER_TOKEN = UserDefaults.standard.string(forKey: "token");

protocol MsgChatProtocol {
    var messages: [Message] { get set }
    var member: Member! { get set }
    var chatService: ChatService! { get set }
}

class MsgChatController: MessagesViewController, MsgChatProtocol {
    var chatService: ChatService!;
    var messages: [Message] = [];
    var member: Member!;
    
    override func viewDidLoad() {
        self.chatService = ChatService();
        self.chatService.connectToHub();
        self.setCurrentMemberAttributes();
        
        messagesCollectionView = MessagesCollectionView(frame: .zero, collectionViewLayout: MyCustomMessagesFlowLayout())
        messagesCollectionView.register(MyCustomCell.self)
        
        self.initDelegate();
        self.chatService.initOnReceivingMessage(currentMemberName: self.member.name, insertMessage: self.insertMessage)
        self.chatService.initOnAnotherUserConnection(insertMessage: self.insertMessage);
        self.chatService.connectToGroup(insertMessage: self.insertMessage);
        
        super.viewDidLoad();
    }
    
    override func viewWillDisappear(_ animated: Bool) -> Void {
         super.viewWillDisappear(animated);
        
        self.chatService.disconnectFromHub();
    }
    
    func messageInputBar(_ inputBar: MessageInputBar, textViewTextDidChangeTo text: String) -> Void {
        if(messageInputBar.inputTextView.text.contains("\n")) {
            messageInputBar.inputTextView.text.popLast();
            if(messageInputBar.sendButton.isEnabled) {
                messageInputBar.didSelectSendButton();
            }
        }
    }
    
    private func initDelegate() -> Void {
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
    
    override open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let messagesDataSource = messagesCollectionView.messagesDataSource else {
            fatalError("Ouch. nil data source for messages")
        }
        
        let message = messagesDataSource.messageForItem(at: indexPath, in: messagesCollectionView)
        if case .custom = message.kind {
            let cell = messagesCollectionView.dequeueReusableCell(MyCustomCell.self, for: indexPath)
            cell.configure(with: message, at: indexPath, and: messagesCollectionView)
            return cell
        }
        return super.collectionView(collectionView, cellForItemAt: indexPath)
    }
}
