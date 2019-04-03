//
//  AddScreenViewController.swift
//  ios
//
//  Created by Sebastien Cadorette on 2019-03-09.
//  Copyright © 2019 LOG3000 equipe 12. All rights reserved.
//

import Foundation
import UIKit

class AddScreenViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: Class Attributes
    
    private let refreshControl = UIRefreshControl();
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var cancelButton: UIBarButtonItem!
    @IBOutlet var saveButton: UIBarButtonItem!
    @IBOutlet var channelName: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        self.tableView.separatorStyle = .none;
        self.customCellRegistration();
        self.initRefreshControl();
        self.initChatServiceCommunication();
        
        self.cancelButton.tintColor = Constants.RED_COLOR;
        self.saveButton.tintColor = Constants.RED_COLOR;
    }
    
    public func updateChannels() -> Void {
        self.tableView.reloadData();
    }
    
    // MARK: Private functions
    
    private func customCellRegistration() -> Void {
        let textFieldCell = UINib(nibName: "CustomTableViewCell", bundle: nil)
        self.tableView.register(textFieldCell, forCellReuseIdentifier: "CustomTableViewCell");
    }
    
    private func initChatServiceCommunication() -> Void {
        ChatService.shared.onFetchChannels(updateChannelsFct: self.updateChannels);
        ChatService.shared.invokeChannelsWhenConnected();
        ChatService.shared.onCreateChannel(updateChannelsFct: self.updateChannels);
        ChatService.shared.invokeFetchChannels();
    }
    
    @objc private func refreshRooms(_ sender: Any) {
        ChatService.shared.invokeFetchChannels();
        self.refreshControl.endRefreshing();
        
    }
    
    private func initRefreshControl() -> Void {
        refreshControl.addTarget(self, action: #selector(refreshRooms(_:)), for: .valueChanged)
        self.tableView.addSubview(self.refreshControl);
    }
    
    // MARK: Actions
    
    @IBAction func cancelButton(_ sender: Any) {
        // Going back to the ChatRoom.
        let storyboard = UIStoryboard(name: "Chat", bundle: nil);
        let view = storyboard.instantiateViewController(withIdentifier: "ChatRoomsView");
        
        let transition = CATransition();
        transition.duration = 0.3;
        transition.type = CATransitionType.reveal;
        transition.subtype = CATransitionSubtype.fromBottom;
        self.view.window!.layer.add(transition, forKey: kCATransition);
        
        navigationController?.pushViewController(view, animated: false); // TODO: Adjust the animation transition.
    }
    
    
    @IBAction func saveButton(_ sender: Any) {
        // Adding the channel on the server.
        ChatService.shared.createNewChannel(channelName: channelName.text!);
        
        // Back to the ChatRoom.
        let storyboard = UIStoryboard(name: "Chat", bundle: nil);
        let view = storyboard.instantiateViewController(withIdentifier: "ChatRoomsView");
        
        let transition = CATransition();
        transition.duration = 0.3;
        transition.type = CATransitionType.reveal;
        transition.subtype = CATransitionSubtype.fromBottom;
        self.view.window!.layer.add(transition, forKey: kCATransition);
        
        navigationController?.pushViewController(view, animated: false);
    }
    
    // MARK: Table View
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0;
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100;
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ChatService.shared.serverChannels.channels.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomTableViewCell") as? CustomTableViewCell;
        
        cell?.chatRoomName.text = ChatService.shared.serverChannels.channels[indexPath.row].name;
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        ChatService.shared.currentChannel = ChatService.shared.serverChannels.channels[indexPath.row];
        ChatService.shared.connectToGroup();
        ChatService.shared.currentChannel = nil;
        
        let storyboard = UIStoryboard(name: "Chat", bundle: nil);
        let destination = storyboard.instantiateViewController(withIdentifier: "ChatRoomsView");
        
        let transition = CATransition();
        transition.duration = 0.3;
        transition.type = CATransitionType.reveal;
        transition.subtype = CATransitionSubtype.fromBottom;
        self.view.window!.layer.add(transition, forKey: kCATransition);
        
        navigationController?.pushViewController(destination, animated: false);
    }
}
