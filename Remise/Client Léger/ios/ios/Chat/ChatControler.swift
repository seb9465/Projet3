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

class MsgChatController: MessagesViewController {
    
    // MARK: Attributes
    
    private var _messages: [Message] = [];
    private var _member: Member!;
    
    // MARK: Getter - Setter
    
    public var messages: [Message] {
        get { return self._messages }
    }
    
    public var member: Member {
        get { return self._member }
    }
    
    // MARK: - Timing functions
    
    override func viewDidLoad() {
        self.setCurrentMemberAttributes();
//        self.messageInputBar.frame = CGRect(x: 0, y: 0, width: 100, height:50)
        messagesCollectionView = MessagesCollectionView(frame: .zero, collectionViewLayout: MyCustomMessagesFlowLayout())
        messagesCollectionView.register(MyCustomCell.self)
        self.initDelegate();
        
        ChatService.shared.initOnReceivingMessage(currentMemberName: self._member.name, insertMessage: self.insertMessage, updateChatRooms: { })
        ChatService.shared.initOnAnotherUserConnection(insertMessage: self.insertMessage);
        
        self.navigationItem.title = ChatService.shared.currentChannel.name.uppercased();
        
        super.viewDidLoad();
        
        let afkMsgs: [String: [Message]] = ChatService.shared.messagesWhileAFK;
        let channelName: String = ChatService.shared.currentChannel.name;
        if (afkMsgs.keys.contains(channelName)) {
            for message in afkMsgs[channelName]! {
                self._messages.append(message);
            }
        }
        
        ChatService.shared.messagesWhileAFK.removeValue(forKey: channelName);
        self.messagesCollectionView.reloadData();
    }
    
    override func viewWillDisappear(_ animated: Bool) -> Void {
        self.navigationController?.popViewController(animated: true);
        
        super.viewWillDisappear(animated);
    }
    
    // MARK: - Public functions
    
    public func messageInputBar(_ inputBar: MessageInputBar, textViewTextDidChangeTo text: String) -> Void {
        if (messageInputBar.inputTextView.text.contains("\n")) {
            messageInputBar.inputTextView.text.popLast();
            if (messageInputBar.sendButton.isEnabled) {
                messageInputBar.didSelectSendButton();
            }
        }
    }
    
    public func insertMessage(_ message: Message) -> Void {
        self._messages.append(message);
        
        messagesCollectionView.performBatchUpdates({
            messagesCollectionView.insertSections([_messages.count - 1]);
        }, completion: { [weak self] _ in
            if self?.isLastSectionVisible() == true {
                self?.messagesCollectionView.scrollToBottom(animated: true);
            }
        });
    }
    
    // MARK: - Private functions
    
    private func initDelegate() -> Void {
        messagesCollectionView.messagesDataSource = self;
        messagesCollectionView.messagesLayoutDelegate = self;
        messageInputBar.delegate = self;
        messagesCollectionView.messagesDisplayDelegate = self;
    }
    
    private func setCurrentMemberAttributes() -> Void {
        let jwt = try! decode(jwt: USER_TOKEN!);
        let name = jwt.claim(name: "unique_name").string;
        
        self._member = Member(name: name!, color: .random);
    }
    
    private func isLastSectionVisible() -> Bool {
        guard !_messages.isEmpty else {
            return false;
        }
        
        let lastIndexPath = IndexPath(item: 0, section: _messages.count - 1);
        
        return messagesCollectionView.indexPathsForVisibleItems.contains(lastIndexPath);
    }
    
    // MARK: - Collection view functions
    
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
