//
//  ColloborationService.swift
//  ios
//
//  Created by William Sevigny on 2019-02-27.
//  Copyright © 2019 LOG3000 equipe 12. All rights reserved.
//

import Foundation
import SwiftSignalRClient

class CollaborationService {
    // MARK: - Singleton
    static let shared = CollaborationService()
    
    // MARK: - Properties
    var hubConnection: HubConnection;
    var _members: Members;
    
    // MARK: - Constants
    private let collaborativeCanvasURL = "http://localhost:5001/signalr/collaborative"

    
    // MARK: - Methods
    init() {
        self.hubConnection = HubConnectionBuilder(url: URL(string: collaborativeCanvasURL)!)
            .withHttpConnectionOptions() { (httpConnectionOptions) in
                httpConnectionOptions.accessTokenProvider = {
                    return UserDefaults.standard.string(forKey: "token")!;
                }
            }
            .build();
        self._members = Members();
        print("hub instanciated")
    }
    
    public func connectToHub() -> Void {
        self.hubConnection.start();
    }
    
    public func connectToGroup() -> Void {
        self.hubConnection.on(method: "ClientIsConnected", callback: { args, typeConverter in
            self.hubConnection.invoke(method: "ConnectToGroup", arguments: [""], invocationDidComplete: { error in
                if (error != nil) {
                    print("Error connecting to server!")
                    print(error as Any);
                }
                print("Connected to the group");
            });
        });
    }
    
    // Argument nil just to established a connection
    public func updateDrawing(drawViewModel: DrawViewModel) -> Void {
        let point: PolyPaintStylusPoint = PolyPaintStylusPoint(X: 10, Y: 10, PressureFactor: 10)
        let color: PolyPaintColor = PolyPaintColor(A: 1, R: 1, G: 1, B: 1)
        let model: DrawViewModel = DrawViewModel(
            ItemType: ItemTypeEnum.RoundedRectangleStroke,
            StylusPoints: [point],
            OutilSelectionne: "Rectangle",
            Color: color
        )
        let jsonEncoder = JSONEncoder()
        let jsonData = try! jsonEncoder.encode(model)
        let jsonString = String(data: jsonData, encoding: .utf8)
        print(jsonString)
        
        self.hubConnection.invoke(method: "Draw", arguments: [jsonString], invocationDidComplete: { (Error) in
            if (Error != nil) {
                print("Error calling draw", Error!)
                return
            }
            print("received update from hub!")
        });
    }
}
