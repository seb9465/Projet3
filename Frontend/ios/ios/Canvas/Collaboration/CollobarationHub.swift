//
//  ColloborationService.swift
//  ios
//
//  Created by William Sevigny on 2019-02-27.
//  Copyright © 2019 LOG3000 equipe 12. All rights reserved.
//

import Foundation
import SwiftSignalRClient

protocol CollaborationHubDelegate {
    func updateCanvas(itemType: ItemTypeEnum, firstPoint: CGPoint, lastPoint: CGPoint)
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
    
    public func postNewFigure(origin: CGPoint, itemType: ItemTypeEnum) -> Void {
        let model = FigureFactory.shared.getFigure(type: itemType, touchedPoint: origin)?.exportToViewModel(itemType: itemType)
            let jsonEncoder = JSONEncoder()
            let jsonData = try! jsonEncoder.encode(model)
            let jsonString = String(data: jsonData, encoding: .utf8)
    
            self.hubConnection.invoke(method: "Draw", arguments: [jsonString], invocationDidComplete: { (Error) in
                if (Error != nil) {
                    print("Error calling draw", Error!)
                    return
                }
            });
        }
    
    public func onDraw() -> Void {
        self.hubConnection.on(method: "Draw", callback: { (args, typeConverter) in
            print("[ Collab ] Received new figure")

            let jsonString: String = try! typeConverter.convertFromWireType(obj: args[0], targetType: String.self)!;
            let jsonData = jsonString.data(using: .utf8)
            
            let viewModel: DrawViewModel = try! JSONDecoder().decode(DrawViewModel.self, from: jsonData!);
            let fpoint: CGPoint = CGPoint(x: viewModel.StylusPoints[0].X, y: viewModel.StylusPoints[0].Y)
            let lpoint: CGPoint = CGPoint(x: viewModel.StylusPoints[1].X, y: viewModel.StylusPoints[1].Y)

            self.delegate!.updateCanvas(itemType: viewModel.ItemType, firstPoint: fpoint, lastPoint: lpoint)
        })
    }
    
    public func onReset() -> Void {
        self.hubConnection.on(method: "Reset", callback:{ args, typeConverter in
            print("[ Collab ] Received clear instruction")
            self.delegate!.updateClear();
        })
    }
    
    public func reset() -> Void {
        self.hubConnection.invoke(method: "Reset", arguments: ["general"], invocationDidComplete: { (Error) in
            if (Error != nil) {
                print("Error calling Reset", Error!)
                return
            }
    })
    }
    
//    public func fetchChannels() -> Void {
//        print("[ Collab ] Invoked FetchChannels");
//        self.hubConnection.invoke(method: "FetchChannels", arguments: [], invocationDidComplete: { error in
//            if (error != nil) {
//                print("ERROR while invoking FetchChannels");
//                print(error!);
//                return
//            }
//        });
//    }
    
//    public func onFetchChannels() -> Void {
//        self.hubConnection.on(method: "FetchChannels", callback: { (args, typeConverter) in
//            let channels: Any = try! typeConverter.convertFromWireType(obj: args[0], targetType: Any.self)!
//            print("[ Collab ] Channels:", channels);
//        });
//    }

//    public func updateDrawing(drawViewModel: DrawViewModel) -> Void {
//        let point: PolyPaintStylusPoint = PolyPaintStylusPoint(X: 10, Y: 10, PressureFactor: 10)
//        let color: PolyPaintColor = PolyPaintColor(A: 1, R: 1, G: 1, B: 1)
//        let model: DrawViewModel = DrawViewModel(
//            ItemType: ItemTypeEnum.RoundedRectangleStroke,
//            StylusPoints: [point],
//            OutilSelectionne: "Rectangle",
//            Color: color,
//            ChannelId: "id"
//        )
//        let jsonEncoder = JSONEncoder()
//        let jsonData = try! jsonEncoder.encode(model)
//        let jsonString = String(data: jsonData, encoding: .utf8)
//        print(jsonString)
//
//        self.hubConnection.invoke(method: "Draw", arguments: [jsonString], invocationDidComplete: { (Error) in
//            if (Error != nil) {
//                print("Error calling draw", Error!)
//                return
//            }
//            print("received update from hub!")
//        });
//    }
}