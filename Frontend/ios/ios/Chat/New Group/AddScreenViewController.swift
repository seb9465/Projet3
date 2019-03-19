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
    @IBOutlet var tableView: UITableView!
    
    @IBOutlet var cancelButton: UIBarButtonItem!
    @IBOutlet var saveButton: UIBarButtonItem!
    @IBOutlet var channelName: UITextField!
    
    private let refreshControl = UIRefreshControl();
    
    @objc private func refreshWeatherData(_ sender: Any) {
        // Fetch Weather Data
        ChatService.shared.invokeFetchChannels();
        self.refreshControl.endRefreshing();
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad();
        let textFieldCell = UINib(nibName: "CustomTableViewCell", bundle: nil)
        self.tableView.register(textFieldCell, forCellReuseIdentifier: "CustomTableViewCell");
        self.tableView.separatorStyle = .none;
        refreshControl.addTarget(self, action: #selector(refreshWeatherData(_:)), for: .valueChanged)
        self.tableView.addSubview(self.refreshControl);
        
        ChatService.shared.onFetchChannels(updateChannelsFct: self.updateChannels);
        ChatService.shared.invokeChannelsWhenConnected();
        ChatService.shared.onCreateChannel(updateChannelsFct: self.updateChannels);
        ChatService.shared.connectToHub();  // TODO: Add notification when client is connected.
        ChatService.shared.invokeFetchChannels();
    }
    
    @IBAction func cancelButton(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Chat", bundle: nil);
        let view = storyboard.instantiateViewController(withIdentifier: "ChatRoomsView");
        navigationController?.pushViewController(view, animated: true);
//        self.dismiss(animated: true, completion: nil);
    }
    
    
    @IBAction func saveButton(_ sender: Any) {
        // Create group.
        //        ChatService.shared.
        ChatService.shared.createNewChannel(channelName: channelName.text!);
        let storyboard = UIStoryboard(name: "Chat", bundle: nil);
        let view = storyboard.instantiateViewController(withIdentifier: "ChatRoomsView");
        navigationController?.pushViewController(view, animated: true);
//        self.dismiss(animated: true, completion: nil);
    }
    
    public func updateChannels() -> Void {
        self.tableView.reloadData();
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

        let storyboard = UIStoryboard(name: "Chat", bundle: nil);
        let destination = storyboard.instantiateViewController(withIdentifier: "ChatView");
        navigationController?.pushViewController(destination, animated: true);
    }
}
