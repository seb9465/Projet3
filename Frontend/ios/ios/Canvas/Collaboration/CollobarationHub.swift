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
    func delete(username: String)
    func getKicked()
    func resizeCanvas(size: PolyPaintStylusPoint)
    func sendExistingSelection()
}

class CollaborationHub {
    
    // MARK: - Singleton
    
    static var shared: CollaborationHub?
    
    // MARK: - Class Attributes
    
    private var _delegate: CollaborationHubDelegate?
    private var _channelId: String
    private var _hubConnection: HubConnection?;
    private var _members: Members;
    
    // MARK: - Getter - Setter
    
    public var delegate: CollaborationHubDelegate {
        get { return self._delegate! }
        set { self._delegate = newValue }
    }
    
    // MARK: - Constructor
    
    init(channelId: String) {
        self._channelId = channelId;
        
        self._hubConnection = HubConnectionBuilder(url: URL(string: Constants.COLLABORATION_URL + "?ChannelId=" + channelId)!)
            .withHttpConnectionOptions() { (httpConnectionOptions) in
                httpConnectionOptions.accessTokenProvider = {
                    return UserDefaults.standard.string(forKey: "token")!;
                }
            }
            .build();
        
        self._members = Members();
        self.initializeOnMethods();
        
        print("[ Collab ] Hub instanciated successfully")
    }
    
    // MARK: - Public Functions
    
    public func connectToHub() -> Void {
        print("[ Collab ] Connecting to hub")
        self._hubConnection!.start()
    }
    
    public func disconnectFromHub() -> Void {
        if (self._hubConnection != nil) {
            self._hubConnection!.stop();
            self._hubConnection = nil;
            print("[ Collab ] Disconnecting from hub");
        }
    }
    
    public func onClientIsConnected() -> Void {
        self._hubConnection!.on(method: "ClientIsConnected", callback: { (args, typeConverter) in
            print("[ Collab ] On ClientIsConnected")
        });
    }
    
    public func connectToChannel() -> Void {
        print("[ Collab ] Invoked ConnectToChannel");
        
        self._hubConnection!.invoke(method: "ConnectToChannel", arguments: [], invocationDidComplete: { (error) in
            if (error != nil) {
                print("ERROR while invoking ConnectToChannel : ", error!);
                
                return;
            }
        });
    }
    
    public func changeProtection(isProtected: Bool) -> Void {
        print("[ Collab ] ChangeProtection");
        
        let protectionMessage: ProtectionMessage = ProtectionMessage(ChannelId: self._channelId, IsProtected: isProtected)
        let jsonEncoder = JSONEncoder()
        let jsonData = try! jsonEncoder.encode(protectionMessage)
        let jsonString = String(data: jsonData, encoding: .utf8)
        
        self._hubConnection!.invoke(method: "ChangeProtection", arguments: [jsonString], invocationDidComplete: { (error) in
            if (error != nil) {
                print("ERROR while invoking ChangeProtection : ", error!);
                
                return;
            }
        });
    }
    
    public func onKicked() -> Void {
        self._hubConnection!.on(method: "Kicked", callback: { args, typeConverter in
            print("[ Collab ] On Kicked");
            self._delegate?.getKicked()
        });
    }
    
    public func ResizeCanvas(width: Double, height: Double) {
        print("[ Collab ] Invoke ResizeCanvas");
        
        let sizeMessage: SizeMessage = SizeMessage(Size: PolyPaintStylusPoint(X: width, Y: height, PressureFactor: 1.0));
        let jsonEncoder = JSONEncoder();
        let jsonData = try! jsonEncoder.encode(sizeMessage);
        let jsonString = String(data: jsonData, encoding: .utf8);
        
        self._hubConnection!.invoke(method: "ResizeCanvas", arguments: [jsonString], invocationDidComplete: { (error) in
            if (error != nil) {
                print("ERROR while invoking ResizeCanvas : ", error!);
                
                return;
            }
        });
    }
    
    public func onResizeCanvas() {
        self._hubConnection!.on(method: "ResizeCanvas", callback: { args, typeConverter in
            let json: String = try! typeConverter.convertFromWireType(obj: args[0], targetType: String.self)!;
            
            if let jsonData = json.data(using: .utf8) {
                let obj: SizeMessage = try! JSONDecoder().decode(SizeMessage.self, from: jsonData);
                self._delegate?.resizeCanvas(size: obj.Size);
                print("[ Collab ] Resizing Canvas");
            }})
    }
    
    public func onConnectToChannel() -> Void {
        self._hubConnection!.on(method: "ConnectToChannel", callback: { args, typeConverter in
            print("[ Collab ] On ConnectToChannel");
            
            let json: String = try! typeConverter.convertFromWireType(obj: args[0], targetType: String.self)!;
            
            if let jsonData = json.data(using: .utf8) {
                let obj: ConnectionMessage = try! JSONDecoder().decode(ConnectionMessage.self, from: jsonData);
                self._delegate?.sendExistingSelection();
                print("[ Collab ] Connected to channel", obj.channelId);
            }
        });
    }
    
    public func postNewFigure(figures: [Figure]) -> Void {
        let token = UserDefaults.standard.string(forKey: "token");
        let jwt = try! decode(jwt: token!);
        let username = jwt.claim(name: "unique_name").string;
        var viewModels : [DrawViewModel] = [];
        
        for figure in figures {
            viewModels.append(figure.exportViewModel()!);
        }
        
        let itemMessage: ItemMessage = ItemMessage(
            CanvasId: self._channelId,
            Username: username!,
            Items: viewModels
        );
        
        let jsonEncoder = JSONEncoder();
        let jsonData = try! jsonEncoder.encode(itemMessage);
        let jsonString = String(data: jsonData, encoding: .utf8);
        
        self._hubConnection!.invoke(method: "Draw", arguments: [jsonString], invocationDidComplete: { (error) in
            if (error != nil) {
                print("Error calling draw : ", error!)
                
                return;
            }
        });
    }
    
    public func postNewFigure(drawViewModels: [DrawViewModel]) -> Void {
        let token = UserDefaults.standard.string(forKey: "token");
        let jwt = try! decode(jwt: token!);
        let username = jwt.claim(name: "unique_name").string;
        
        let itemMessage: ItemMessage = ItemMessage(
            CanvasId: self._channelId,
            Username: username!,
            Items: drawViewModels
        );
        
        let jsonEncoder = JSONEncoder();
        let jsonData = try! jsonEncoder.encode(itemMessage);
        let jsonString = String(data: jsonData, encoding: .utf8);
        
        self._hubConnection!.invoke(method: "Draw", arguments: [jsonString], invocationDidComplete: { (error) in
            if (error != nil) {
                print("Error calling draw : ", error!);
                
                return;
            }
        });
    }
    
    public func selectObjects(drawViewModels: [DrawViewModel]) -> Void {
        let token = UserDefaults.standard.string(forKey: "token");
        let jwt = try! decode(jwt: token!);
        let username = jwt.claim(name: "unique_name").string;
        
        let itemMessage: ItemMessage = ItemMessage(
            CanvasId: self._channelId,
            Username: username!,
            Items: drawViewModels
        );
        
        let jsonEncoder = JSONEncoder();
        let jsonData = try! jsonEncoder.encode(itemMessage);
        let jsonString = String(data: jsonData, encoding: .utf8);
        
        self._hubConnection!.invoke(method: "Select", arguments: [jsonString], invocationDidComplete: { (error) in
            if (error != nil) {
                print("Error calling select : ", error!);
                
                return;
            }
        });
    }
    
    public func CutObjects(drawViewModels: [DrawViewModel]) -> Void {
        let token = UserDefaults.standard.string(forKey: "token");
        let jwt = try! decode(jwt: token!);
        let username = jwt.claim(name: "unique_name").string;
        
        let itemMessage = ItemMessage(
            CanvasId: self._channelId,
            Username: username!,
            Items: drawViewModels
        );
        
        let jsonEncoder = JSONEncoder();
        let jsonData = try! jsonEncoder.encode(itemMessage);
        let jsonString = String(data: jsonData, encoding: .utf8);
        
        self._hubConnection!.invoke(method: "Cut", arguments: [jsonString], invocationDidComplete: { (error) in
            if (error != nil) {
                print("Error calling Cut : ", error!);
                
                return;
            }
        });
    }
    
    public func onCut() -> Void {
        self._hubConnection!.on(method: "Cut", callback: { (args, typeConverter) in
            print("[ Collab ] Delete received");
            
            let jsonString: String = try! typeConverter.convertFromWireType(obj: args[0], targetType: String.self)!;
            let jsonData = jsonString.data(using: .utf8);
            let itemMessage: ItemMessage = try! JSONDecoder().decode(ItemMessage.self, from: jsonData!);
            
            self._delegate!.delete(username: itemMessage.Username);
        })
    }
    
    public func onDraw() -> Void {
        self._hubConnection!.on(method: "Draw", callback: { (args, typeConverter) in
            print("[ Collab ] Received new figure");
            
            let jsonString: String = try! typeConverter.convertFromWireType(obj: args[0], targetType: String.self)!;
            let jsonData = jsonString.data(using: .utf8);
            let itemMessage: ItemMessage = try! JSONDecoder().decode(ItemMessage.self, from: jsonData!);
            
            self._delegate!.updateCanvas(itemMessage: itemMessage);
        });
    }
    
    public func onSelect() -> Void {
        self._hubConnection!.on(method: "Select", callback: { (args, typeConverter) in
            print("[ Collab ] Received SELECT action");
            
            let jsonString: String = try! typeConverter.convertFromWireType(obj: args[0], targetType: String.self)!;
            let jsonData = jsonString.data(using: .utf8);
            let itemMessage: ItemMessage = try! JSONDecoder().decode(ItemMessage.self, from: jsonData!);
            
            self._delegate!.updateSelection(itemMessage: itemMessage);
        });
    }
    
    public func onReset() -> Void {
        self._hubConnection!.on(method: "Reset", callback:{ args, typeConverter in
            print("[ Collab ] Received clear instruction");
            self._delegate!.updateClear();
        });
    }
    
    public func reset() -> Void {
        self._hubConnection!.invoke(method: "Reset", arguments: [], invocationDidComplete: { (error) in
            if (error != nil) {
                print("Error calling Reset", error!);
                
                return;
            }
        });
    }
    
    // MARK: - Private functions
    
    private func initializeOnMethods() -> Void {
        self.onClientIsConnected()
        self.onConnectToChannel()
        self.onDraw()
        self.onReset()
        self.onSelect()
        self.onCut()
        self.onKicked()
        self.onResizeCanvas()
    }
}
