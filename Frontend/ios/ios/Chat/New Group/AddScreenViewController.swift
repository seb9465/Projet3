//
//  AddScreenViewController.swift
//  ios
//
//  Created by Sebastien Cadorette on 2019-03-09.
//  Copyright © 2019 LOG3000 equipe 12. All rights reserved.
//

import Foundation
import UIKit

class AddScreenViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    // MARK: Class Attributes
    
    private let refreshControl = UIRefreshControl();
    
    // MARK: Outlets
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var cancelButton: UIBarButtonItem!
    @IBOutlet var saveButton: UIBarButtonItem!
    @IBOutlet var channelName: UITextField!
    
    // MARK: Timing functions
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        self.tableView.separatorStyle = .none;
        self.customCellRegistration();
        self.initRefreshControl();
        self.initChatServiceCommunication();
        
        self.cancelButton.tintColor = Constants.Colors.RED_COLOR;
        self.saveButton.tintColor = Constants.Colors.RED_COLOR;
        self.saveButton.isEnabled = false;
        self.channelName.addTarget(self, action: #selector(editingChanged), for: .editingChanged);
    }
    
    // MARK: Actions
    
    @IBAction func cancelButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true);
    }
    
    
    @IBAction func saveButton(_ sender: Any) {
        if (!(self.channelName.text?.isEmpty)!) {
            ChatService.shared.createNewChannel(channelName: channelName.text!);
            ChatService.shared.currentChannel = Channel(name: channelName.text!, connected: true);
            ChatService.shared.connectToGroup();
            ChatService.shared.currentChannel = nil;
        }
        
        self.navigationController?.popViewController(animated: true);
    }
    
    // MARK: Object functions
    
    @objc private func refreshRooms(_ sender: Any) {
        ChatService.shared.invokeFetchChannels();
        self.refreshControl.endRefreshing();
    }
    
    @objc func editingChanged(_ textField: UITextField) {
        guard
            let channelName = textField.text, !channelName.isEmpty
            else {
                self.saveButton.isEnabled = false
                return
        }
        self.saveButton.isEnabled = true
    }
    
    // MARK: Public functions
    
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
    
    private func initRefreshControl() -> Void {
        refreshControl.addTarget(self, action: #selector(refreshRooms(_:)), for: .valueChanged)
        self.tableView.addSubview(self.refreshControl);
    }
    
    // MARK: - Table View Functions
    
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
        
        cell?.chatRoomName.text = ChatService.shared.serverChannels.channels[indexPath.row].name.uppercased();
        cell?.notificationLabel.text = "";
        
        cell?.selectionStyle = .none;
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        ChatService.shared.currentChannel = ChatService.shared.serverChannels.channels[indexPath.row];
        ChatService.shared.connectToGroup();
        ChatService.shared.currentChannel = nil;
        
        self.navigationController?.popViewController(animated: true);
    }
}
