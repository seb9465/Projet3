//
//  ColloborationService.swift
//  ios
//
//  Created by William Sevigny on 2019-02-27.
//  Copyright © 2019 LOG3000 equipe 12. All rights reserved.
//

import Foundation
import SwiftSignalRClient
import JWTDecode

protocol CollaborationHubDelegate {
    func updateCanvas(itemMessage: ItemMessage)
    func updateSelection(itemMessage: ItemMessage)
    func updateClear();
}

class CollaborationHub {
    // Singleton
    static let shared = CollaborationHub()
    var delegate: CollaborationHubDelegate?
    
    var hubConnection: HubConnection;
    var _members: Members;
    
    init() {
        self.hubConnection = HubConnectionBuilder(url: URL(string: Constants.COLLABORATION_URL)!)
            .withHttpConnectionOptions() { (httpConnectionOptions) in
                httpConnectionOptions.accessTokenProvider = {
                    return UserDefaults.standard.string(forKey: "token")!;
                }
            }
            .build();
        self._members = Members();
        self.initializeOnMethods()
        print("[ Collab ] Hub instanciated successfully")
    }
    
    private func initializeOnMethods() -> Void {
        self.onClientIsConnected()
        self.onConnectToChannel()
        self.onDraw()
        self.onReset()
        self.onSelect()
        //        self.onFetchChannels()
    }
    
    public func connectToHub() -> Void {
        print("[ Collab ] Connecting to hub")
        self.hubConnection.start()
    }
    
    public func onClientIsConnected() -> Void {
        self.hubConnection.on(method: "ClientIsConnected", callback: { (args, typeConverter) in
            print("[ Collab ] On ClientIsConnected")
            //            self.fetchChannels()
            //            self.connectToChannel()
        })
    }
    
    public func connectToChannel() -> Void {
        let json = try? JSONEncoder().encode(ConnectionMessage(channelId: "general"));
        let jsondata: String = String(data: json!, encoding: .utf8)!;
        
        print("[ Collab ] Invoked ConnectToChannel");
        self.hubConnection.invoke(method: "ConnectToChannel", arguments: [jsondata], invocationDidComplete: { (error) in
            if (error != nil) {
                print("ERROR while invoking ConnectToChannel.");
                print(error!);
                return
            }
        });
    }
    
    public func onConnectToChannel() -> Void {
        self.hubConnection.on(method: "ConnectToChannel", callback: { args, typeConverter in
            print("[ Collab ] On ConnectToChannel");
            
            let json: String = try! typeConverter.convertFromWireType(obj: args[0], targetType: String.self)!;
            if let jsonData = json.data(using: .utf8) {
                let obj: ConnectionMessage = try! JSONDecoder().decode(ConnectionMessage.self, from: jsonData);
                print("[ Collab ] Connected to channel", obj.channelId)
            }
        });
    }
    
    // Send a new figure to the collaborative Hub
    public func postNewFigure(figures: [Figure]) -> Void {
        let token = UserDefaults.standard.string(forKey: "token");
        let jwt = try! decode(jwt: token!)
        let username = jwt.claim(name: "unique_name").string
        
        var viewModels : [DrawViewModel] = []
        for figure in figures {
            viewModels.append(figure.exportViewModel()!)
        }
        
        let itemMessage = ItemMessage(
            CanvasId: "general",
            Username: username!,
            Items: viewModels
        )

        let jsonEncoder = JSONEncoder()
        let jsonData = try! jsonEncoder.encode(itemMessage)
        let jsonString = String(data: jsonData, encoding: .utf8)

        self.hubConnection.invoke(method: "Draw", arguments: [jsonString], invocationDidComplete: { (Error) in
            if (Error != nil) {
                print("Error calling draw", Error!)
                return
            }
        });
    }
    
    public func selectObjects(drawViewModels: [DrawViewModel]) -> Void {
        let token = UserDefaults.standard.string(forKey: "token");
        let jwt = try! decode(jwt: token!)
        let username = jwt.claim(name: "unique_name").string
        let itemMessage = ItemMessage(
            CanvasId: "general",
            Username: username!,
            Items: drawViewModels
            )
        
        let jsonEncoder = JSONEncoder()
        let jsonData = try! jsonEncoder.encode(itemMessage)
        let jsonString = String(data: jsonData, encoding: .utf8)
        
        self.hubConnection.invoke(method: "Select", arguments: [jsonString], invocationDidComplete: { (Error) in
            if (Error != nil) {
                print("Error calling select", Error!)
                return
            }
        });
    }
    
    // Receive a figure from the collaboratibve Hub
    public func onDraw() -> Void {
        self.hubConnection.on(method: "Draw", callback: { (args, typeConverter) in
            print("[ Collab ] Received new figure")

            let jsonString: String = try! typeConverter.convertFromWireType(obj: args[0], targetType: String.self)!;
            let jsonData = jsonString.data(using: .utf8)
            let itemMessage: ItemMessage = try! JSONDecoder().decode(ItemMessage.self, from: jsonData!);
            
            self.delegate!.updateCanvas(itemMessage: itemMessage)
        })
    }
    
    public func onSelect() -> Void {
        self.hubConnection.on(method: "Select", callback: { (args, typeConverter) in
            print("[ Collab ] Received SELECT action")
            
            let jsonString: String = try! typeConverter.convertFromWireType(obj: args[0], targetType: String.self)!;
            let jsonData = jsonString.data(using: .utf8)
            let itemMessage: ItemMessage = try! JSONDecoder().decode(ItemMessage.self, from: jsonData!);
            
            self.delegate!.updateSelection(itemMessage: itemMessage)
        })
    }
    
    public func onReset() -> Void {
        self.hubConnection.on(method: "Reset", callback:{ args, typeConverter in
            print("[ Collab ] Received clear instruction")
            self.delegate!.updateClear();
        })
    }
    
    public func reset() -> Void {
        self.hubConnection.invoke(method: "Reset", arguments: [], invocationDidComplete: { (Error) in
            if (Error != nil) {
                print("Error calling Reset", Error!)
                return
            }
        })
    }
}
