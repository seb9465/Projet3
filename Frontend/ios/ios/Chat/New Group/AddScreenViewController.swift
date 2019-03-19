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
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100;
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomTableViewCell") as? CustomTableViewCell;
        
        cell?.chatRoomName.text = "Hellllo";
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 100;
    }
    
    @IBOutlet var tableView: UITableView!
    
    @IBOutlet var cancelButton: UIBarButtonItem!
    @IBOutlet var saveButton: UIBarButtonItem!
    @IBOutlet var channelName: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad();
        let textFieldCell = UINib(nibName: "CustomTableViewCell", bundle: nil)
        self.tableView.register(textFieldCell, forCellReuseIdentifier: "CustomTableViewCell");
        self.tableView.separatorStyle = .none;
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
}
