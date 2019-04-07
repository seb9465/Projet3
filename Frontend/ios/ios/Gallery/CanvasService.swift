//
//  ConvasService.swift
//  ios
//
//  Created by Sebastien Cadorette on 2019-02-19.
//  Copyright © 2019 LOG3000 equipe 12. All rights reserved.
//

import UIKit
import PromiseKit
import Alamofire
import JWTDecode
class CanvasService {
    // Singleton
    static let shared = CanvasService()
    
}

extension CanvasService {
    @discardableResult
    private static func get() -> Promise<Data> {
        let url: URLConvertible = "https://polypaint.me/api/user/AllCanvas"
        let headers = [
            "Authorization": "Bearer " + UserDefaults.standard.string(forKey: "token")!,
            "Accept": "application/json"
        ]
        
        return Promise { (seal) in
            Alamofire.request(url, method: .get, encoding: JSONEncoding.default, headers: headers).responseJSON{ (response) in
                switch response.result {
                case .success( _):
                    seal.fulfill(response.data!);
                case .failure(let error):
                    seal.reject(error)
                }
            }
        }
    }
    
    private static func getPrivate() -> Promise<Data> {
        let url: URLConvertible = "https://polypaint.me/api/user/Canvas"
        let headers = [
            "Authorization": "Bearer " + UserDefaults.standard.string(forKey: "token")!,
            "Accept": "application/json"
        ]
        
        return Promise { (seal) in
            Alamofire.request(url, method: .get, encoding: JSONEncoding.default, headers: headers).responseJSON{ (response) in
                switch response.result {
                case .success( _):
                    seal.fulfill(response.data!);
                case .failure(let error):
                    seal.reject(error)
                }
            }
        }}
    
    private static func getById(id: String) -> Promise<Data> {
        let url: URLConvertible = "https://polypaint.me/api/user/Canvas/" + id
        let headers = [
            "Authorization": "Bearer " + UserDefaults.standard.string(forKey: "token")!,
            "Accept": "application/json"
        ]
        
        return Promise { (seal) in
            Alamofire.request(url, method: .get, encoding: JSONEncoding.default, headers: headers).responseJSON{ (response) in
                switch response.result {
                case .success( _):
                    seal.fulfill(response.data!);
                case .failure(let error):
                    seal.reject(error)
                }
            }
        }}
    
    static func getAllCanvas(includePrivate: Bool) -> Promise<[Canvas]> {
        return Promise { seal in
            CanvasService.get().done{ (data) in
                var canvas = try JSONDecoder().decode([Canvas].self, from: data)
                let token = UserDefaults.standard.string(forKey: "token");
                let jwt = try! decode(jwt: token!)
                let username = jwt.claim(name: "unique_name").string
                canvas.removeAll(where: {$0.canvasVisibility == "Private" && $0.canvasAutor != username})
                seal.fulfill(canvas)
            }
        }
    }
    
    static func getCanvasById(id: String) -> Promise<Canvas> {
        return Promise { seal in
            CanvasService.getById(id: id).done{ (data) in
                var canvas = try JSONDecoder().decode(Canvas.self, from: data)
                seal.fulfill(canvas)
            }
        }
    }
    
    static func getPrivateCanvas() -> Promise<[Canvas]> {
        return Promise { seal in
            CanvasService.getPrivate().done{(data) in
                let canvas = try JSONDecoder().decode([Canvas].self, from: data)
                seal.fulfill(canvas)
            }
        }
    }
    
    public static func SaveOnline(canvas: Canvas) -> Promise<Bool> {
        let canvas = ["CanvasId": canvas.canvasId, "canvasAutor":canvas.canvasAutor, "CanvasProtection":canvas.canvasProtection, "canvasVisibility":canvas.canvasVisibility, "DrawViewModels":canvas.drawViewModels,"Image":canvas.image, "Name":canvas.name, "canvasWidth": String(canvas.canvasWidth), "canvasHeight": String(canvas.canvasHeight)]
        let url = Constants.SAVE_URL as URLConvertible
        let headers = ["Authorization": "Bearer " + UserDefaults.standard.string(forKey: "token")!];
        
        return Promise { (seal) in
            Manager.request(url, method: .post, parameters: canvas, encoding: JSONEncoding.default, headers: headers).validate()
                .responseString { (response) in
                    switch response.result {
                    case .success:
                        seal.fulfill(true);
                        
                    case .failure(let Error):
                        if let data = response.data {
                            let json = String(data: data, encoding: String.Encoding.utf8)
                            print("Failure Response: \(json)")
                        }
                        seal.fulfill(false)
                        seal.reject(Error);
                    }
                    
            };
        }
    }
    
    private static var Manager : Alamofire.SessionManager = {
        // Create the server trust policies
        let serverTrustPolicies: [String: ServerTrustPolicy] = [
            "localhost": .disableEvaluation
        ]
        // Create custom manager
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = Alamofire.SessionManager.defaultHTTPHeaders
        let manager = Alamofire.SessionManager(
            configuration: URLSessionConfiguration.background(withIdentifier: "com.polypaint.background"),
            serverTrustPolicyManager: ServerTrustPolicyManager(policies: serverTrustPolicies)
        )
        manager.startRequestsImmediately = true
        return manager
    }()
    
    public static func saveOnNewFigure(figures: [Figure], editor: Editor) -> Void {
        var drawViewModels: [DrawViewModel] = []
        for figure in figures {
            drawViewModels.append(figure.exportViewModel()!)
        }
        currentCanvas.drawViewModels = String(data: try! JSONEncoder().encode(drawViewModels), encoding: .utf8)!
        currentCanvas.image = (editor.export().pngData()?.base64EncodedString())!
        self.SaveOnline(canvas: currentCanvas)
    }
}
