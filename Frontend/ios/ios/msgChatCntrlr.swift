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

let CHAT_URL_2 = "http://10.200.18.232:5000/signalr";
let USER_TOKEN_2 = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1bmlxdWVfbmFtZSI6InNlYmFzIiwibmFtZWlkIjoiMTc4ZDAyMTYtZjMzYS00OWE1LWIxZWYtNWY1NDVhMGE2NTkzIiwibmJmIjoxNTQ5MDM2NzE5LCJleHAiOjYxNTQ5MDM2NjU5LCJpYXQiOjE1NDkwMzY3MTksImlzcyI6IjEwLjIwMC4yNy4xNjo1MDAxIiwiYXVkIjoiMTAuMjAwLjI3LjE2OjUwMDEifQ.F17GYsYBA0jn36AbKkJNzd43g3s7Xd01UklkDDCI4qE";

class MsgChatController: MessagesViewController {
    var hubConnection: HubConnection!
    var connectedToGroup: Bool = false
    var messages: [Message] = [];
    var member: Member!;
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        // A regler avec Will
        member = Member(name: "sebas", color: .random)
        
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messageInputBar.delegate = self
        messagesCollectionView.messagesDisplayDelegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.hubConnection = HubConnectionBuilder(url: URL(string: CHAT_URL_2)!)
            .withHttpConnectionOptions() { httpConnectionOptions in
                httpConnectionOptions.accessTokenProvider = { return USER_TOKEN_2; }}
            .build();
        
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
                messageId: UUID().uuidString)
            
            // A ajuster lorsque le lien avec le login sera fait.
            if (newMember.name != self.member.name) {
                self.messages.append(newMessage)
            }
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.hubConnection.stop();
    }
}

// 4 protocoles a implementer pour connecter les messages au UI & controler les interactions.
// MessagesDataSource qui donne le nombre et le contenu des messages
extension MsgChatController: MessagesDataSource {
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
    
    func messageTopLabelAttributedText(
        for message: MessageKit.MessageType,
        at indexPath: IndexPath) -> NSAttributedString? {
        
        return NSAttributedString(
            string: message.sender.displayName,
            attributes: [.font: UIFont.systemFont(ofSize: 12)])
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
        
        let newMessage = Message(
            member: member,
            text: text,
            messageId: UUID().uuidString)
        
        self.hubConnection.invoke(method: "SendMessage", arguments: [newMessage.text], invocationDidComplete: { error in
            if let e = error {
                print("ERROR");
                print(e);
            }
            self.messages.append(newMessage)
            inputBar.inputTextView.text = ""
            self.messagesCollectionView.reloadData()
            self.messagesCollectionView.scrollToBottom(animated: true)
        });
    }
}
