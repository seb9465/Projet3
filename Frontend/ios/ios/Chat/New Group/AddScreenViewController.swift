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
    
    var userChannels: ChannelsMessage = ChannelsMessage();
    
    override func viewDidLoad() {
        super.viewDidLoad();
        let textFieldCell = UINib(nibName: "CustomTableViewCell", bundle: nil)
        self.tableView.register(textFieldCell, forCellReuseIdentifier: "CustomTableViewCell");
        self.tableView.separatorStyle = .none;
        
        ChatService.shared.onFetchChannels(updateChannelsFct: self.updateChannels);
        ChatService.shared.invokeChannelsWhenConnected();
        ChatService.shared.onCreateChannel(updateChannelsFct: self.updateChannels);
        ChatService.shared.connectToHub();  // TODO: Add notification when client is connected.
        ChatService.shared.invokeFetchChannels();
    }
    
    @IBAction func cancelButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil);
    }
    
    
    @IBAction func saveButton(_ sender: Any) {
        // Create group.
        //        ChatService.shared.
        ChatService.shared.createNewChannel(channelName: channelName.text!);
        self.dismiss(animated: true, completion: nil);
    }
    
    public func updateChannels(channels: [Channel]) -> Void {
        for channel in channels {
            if (!self.userChannels.channels.contains(where: { $0.name.elementsEqual(channel.name) })) {
                self.userChannels.channels.append(channel);
            }
        }
        
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
        return self.userChannels.channels.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomTableViewCell") as? CustomTableViewCell;
        
        cell?.chatRoomName.text = self.userChannels.channels[indexPath.row].name;
        
        return cell!
    }
}
