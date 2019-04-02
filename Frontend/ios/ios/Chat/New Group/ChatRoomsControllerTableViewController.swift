//
//  ChatRoomsControllerTableViewController.swift
//  ios
//
//  Created by Sebastien Cadorette on 2019-03-09.
//  Copyright © 2019 LOG3000 equipe 12. All rights reserved.
//

import UIKit

class ChatRoomsControllerTableViewController: UITableViewController {
    
    private let refreshTable = UIRefreshControl();
    
    @objc private func refreshData(_ sender: Any) {
        ChatService.shared.invokeFetchChannels();
        self.refreshTable.endRefreshing();
    }
    
    @IBAction func backButton(_ sender: Any) {
        ChatService.shared.currentChannel = nil;
        let storyboard = UIStoryboard(name: "Main", bundle: nil);
        let view = storyboard.instantiateViewController(withIdentifier: "MainController");
        
        let transition = CATransition();
        transition.duration = 0.3;
        transition.type = CATransitionType.reveal;
        transition.subtype = CATransitionSubtype.fromBottom;
        self.view.window!.layer.add(transition, forKey: kCATransition);
        
        self.present(view, animated: false, completion: nil);
    }
    
    override func viewDidLoad() {
        self.tableView.separatorStyle = .none;
        self.registerTableViewCells();
        
        ChatService.shared.onFetchChannels(updateChannelsFct: self.updateChannels);
        ChatService.shared.onCreateChannel(updateChannelsFct: self.updateChannels);
        ChatService.shared.invokeFetchChannels();
        
        self.refreshTable.addTarget(self, action: #selector(refreshData(_:)), for: .valueChanged)
        self.tableView.addSubview(self.refreshTable);
        
        self.navigationItem.rightBarButtonItems?.append(self.editButtonItem);
        
        super.viewDidLoad()
    }
    
    private func registerTableViewCells() {
        let textFieldCell = UINib(nibName: "CustomTableViewCell", bundle: nil)
        let headerCell = UINib(nibName: "CustomHeaderCell", bundle: nil)
        self.tableView.register(textFieldCell, forCellReuseIdentifier: "CustomTableViewCell");
        self.tableView.register(headerCell, forCellReuseIdentifier: "CustomHeaderCell");
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated);
    }
    
    public func updateChannels() -> Void {
        self.tableView.reloadData();
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ChatService.shared.userChannels.channels.count;
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100;
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 100;
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerCell = tableView.dequeueReusableCell(withIdentifier: "CustomHeaderCell") as! CustomHeaderCell;
        
        return headerCell;
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomTableViewCell") as? CustomTableViewCell;
        
        cell?.chatRoomName.text = ChatService.shared.userChannels.channels[indexPath.row].name;
        
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        ChatService.shared.currentChannel = ChatService.shared.userChannels.channels[indexPath.row];
        
        let storyboard = UIStoryboard(name: "Chat", bundle: nil);
        let destination = storyboard.instantiateViewController(withIdentifier: "ChatView");
        navigationController?.pushViewController(destination, animated: true)
    }
 
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            ChatService.shared.currentChannel = ChatService.shared.userChannels.channels[indexPath.row];
            ChatService.shared.disconnectFromCurrentChatRoom();
            ChatService.shared.invokeFetchChannels();
            self.tableView.reloadData();
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
}
