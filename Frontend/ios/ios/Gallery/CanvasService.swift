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
    
    static func getAllCanvas() -> Promise<[Canvas]> {
        return Promise { seal in
            CanvasService.get().done{ (data) in
                let canvas = try JSONDecoder().decode([Canvas].self, from: data)
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
        let credentials = ["CanvasId": canvas.canvasId, "canvasAutor":canvas.canvasAutor, "CanvasProtection":canvas.canvasProtection, "canvasVisibility":canvas.canvasVisibility, "DrawViewModels":canvas.drawViewModels,"Image":canvas.image, "Name":canvas.name]
            let url = Constants.SAVE_URL as URLConvertible
        let headers = ["Authorization": "Bearer " + UserDefaults.standard.string(forKey: "token")!];

            return Promise { (seal) in
                Manager.request(url, method: .post, parameters: credentials, encoding: JSONEncoding.default, headers: headers).validate()
                    .responseString { (response) in
                     switch response.result {
                        case .success:
                            seal.fulfill(true);

                        case .failure(let Error):
                            if let data = response.data {
                                let json = String(data: data, encoding: String.Encoding.utf8)
                                print("Failure Response: \(json)")
                            }
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
            configuration: URLSessionConfiguration.default,
            serverTrustPolicyManager: ServerTrustPolicyManager(policies: serverTrustPolicies)
        )
        return manager
    }()
    
    public static func saveLocalCanvas(figures: [Figure]) -> Void {
        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let canvasPath = documentsURL.appendingPathComponent("canvas")
        let fileUrl = canvasPath.appendingPathComponent("local" + ".json")
        var drawViewModels: [DrawViewModel] = []
        print("SAVING.... " + String(figures.count) + " figures")
        for figure in figures {
            drawViewModels.append(figure.exportViewModel()!)
        }
        
        // some convertion logic here to convert in base64
        do {
            try FileManager.default.createDirectory(atPath: canvasPath.path, withIntermediateDirectories: true, attributes: nil)
            
            if let encodedData = try? JSONEncoder().encode(drawViewModels){
                do {
                    try encodedData.write(to: fileUrl)
                }
                catch {
                    print("Failed to write JSON data: \(error.localizedDescription)")
                }
            }
        } catch {
            print("Folder exists already")
        }
    }
    
    
    
    public static func getLocalCanvas() -> [Canvas] {
        var canvas: [Canvas] = []
        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let canvasPath = documentsURL.appendingPathComponent("canvas")
        do {
            let fileURLs = try fileManager.contentsOfDirectory(at: canvasPath, includingPropertiesForKeys: nil)
            
            for file in fileURLs {
                let jsonData = try Data(contentsOf: file)
                let decoder = JSONDecoder()
                let canva = try decoder.decode(Canvas.self, from: jsonData)
                canvas.append(canva)
            }
        } catch {
            print("Error while enumerating files \(documentsURL.path): \(error.localizedDescription)")
        }
        return canvas;
    }
}
