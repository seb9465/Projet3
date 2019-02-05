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

let CHAT_URL_2 = "https://polypaint.me/signalr";
let USER_TOKEN_2 = UserDefaults.standard.string(forKey: "token");

class MsgChatController: MessagesViewController, MessagesDataSource {
    var hubConnection: HubConnection!
    var connectedToGroup: Bool = false
    var messages: [Message] = [];
    var member: Member!;
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        let jwt = try! decode(jwt: USER_TOKEN_2!)
        let name = jwt.claim(name: "unique_name").string
        print(name);
        
        // A regler avec Will
        member = Member(name: name!, color: .random)
        
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messageInputBar.delegate = self
        messagesCollectionView.messagesDisplayDelegate = self
    }

    
    func messageInputBar(_ inputBar: MessageInputBar, textViewTextDidChangeTo text: String) {
        if(messageInputBar.inputTextView.text.contains("\n")) {
            messageInputBar.inputTextView.text.popLast();
            if(messageInputBar.sendButton.isEnabled) {
                messageInputBar.didSelectSendButton();
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // Initialisation du hub.
        self.hubConnection = HubConnectionBuilder(url: URL(string: CHAT_URL_2)!)
            .withHttpConnectionOptions() { httpConnectionOptions in
                httpConnectionOptions.accessTokenProvider = { return USER_TOKEN_2; }}
            .build();
        
        // Connexion au serveur.
        self.hubConnection.start();
        
        self.hubConnection.on(method: "ReceiveMessage", callback: { args, typeConverter in
            let user = try! typeConverter.convertFromWireType(obj: args[0], targetType: String.self);
            let message = try! typeConverter.convertFromWireType(obj: args[1], targetType: String.self);
            let timestamp = try! typeConverter.convertFromWireType(obj: args[2], targetType: String.self);
            
            let newMember = Member(
                name: user!,
                color: .random)
            
            let newMessage = Message(
                member: newMember,
                text: message!,
                timestamp: timestamp!,
                messageId: UUID().uuidString)
            
            // A ajuster lorsque le lien avec le login sera fait.
            if (user != self.member.name) {
                self.insertMessage(newMessage)
            }
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
//        self.hubConnection.stop();
    }
    
    let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter
    }()
    
    func insertMessage(_ message: Message) {
        messages.append(message)
        // Reload last section to update header/footer labels and insert a new one
        messagesCollectionView.performBatchUpdates({
            messagesCollectionView.insertSections([messages.count - 1])
        }, completion: { [weak self] _ in
            if self?.isLastSectionVisible() == true {
                self?.messagesCollectionView.scrollToBottom(animated: true)
            }
        })
    }
    
    func isLastSectionVisible() -> Bool {
        
        guard !messages.isEmpty else { return false }
        
        let lastIndexPath = IndexPath(item: 0, section: messages.count - 1)
        
        return messagesCollectionView.indexPathsForVisibleItems.contains(lastIndexPath)
    }
    
//}

// 4 protocoles a implementer pour connecter les messages au UI & controler les interactions.
// MessagesDataSource qui donne le nombre et le contenu des messages
    
//extension MsgChatController: MessagesDataSource {

    func numberOfSections(
        in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
    
    func currentSender() -> Sender {
        return Sender(id: member.name, displayName: member.name)
    }
    
    func messageForItem(
        at indexPath: IndexPath,
        in messagesCollectionView: MessagesCollectionView) -> MessageKit.MessageType {
        
        return messages[indexPath.section]
    }
    
    func messageTopLabelHeight(
        for message: MessageKit.MessageType,
        at indexPath: IndexPath,
        in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        
        return 12
    }
    
    func messageBottomLabelHeight(
        for message: MessageKit.MessageType,
        at indexPath: IndexPath,
        in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        
        return 12
    }

    
    func messageTopLabelAttributedText(
        for message: MessageKit.MessageType,
        at indexPath: IndexPath) -> NSAttributedString? {
        
        return NSAttributedString(
            string: message.sender.displayName,
            attributes: [.font: UIFont.systemFont(ofSize: 12)])
    }
    
    func messageBottomLabelAttributedText(for message: MessageKit.MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        
        return NSAttributedString(string: messages[indexPath.section].timestamp, attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption2)])
    }
}

// MessagesLayoutDelegate qui donne la hauteur, le padding et l'alignement des differentes vues.
extension MsgChatController: MessagesLayoutDelegate {
    
    func heightForLocation(message: MessageKit.MessageType,
                           at indexPath: IndexPath,
                           with maxWidth: CGFloat,
                           in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        
        return 0
    }
}

// MessagesDisplayDelegate qui donne la couleur, le style et les vues qui definisse l'allure des messages.
extension MsgChatController: MessagesDisplayDelegate {
    func configureAvatarView(
        _ avatarView: AvatarView,
        for message: MessageKit.MessageType,
        at indexPath: IndexPath,
        in messagesCollectionView: MessagesCollectionView) {
        
        let message = messages[indexPath.section]
        let color = message.member.color
        avatarView.backgroundColor = color
    }
}

// MessageInputBarDelegate qui permet le controle de l'envoie et de l'ecriture des nouveaux messages.
extension MsgChatController: MessageInputBarDelegate {
    func messageInputBar(
        _ inputBar: MessageInputBar,
        didPressSendButtonWith text: String) {
        
        if (!self.connectedToGroup) {
            self.hubConnection.invoke(method: "ConnectToGroup", arguments: [""], invocationDidComplete: { error in
                if (error != nil) {
                    print("Error connecting to server!")
                }
            })
        }
        
        let date = Date();
        let dateFormatter = DateFormatter();
        dateFormatter.dateFormat = "HH:mm:ss";
        let result = dateFormatter.string(from: date);
        
        let newMessage = Message(
            member: member,
            text: text,
            timestamp: result,
            messageId: UUID().uuidString)
        
        self.hubConnection.invoke(method: "SendMessage", arguments: [newMessage.text], invocationDidComplete: { error in
            if let e = error {
                print("ERROR");
                print(e);
            }
            
            self.insertMessage(newMessage)
            inputBar.inputTextView.text = ""
            self.messagesCollectionView.reloadData()
            self.messagesCollectionView.scrollToBottom(animated: true)
        });
    }
}
