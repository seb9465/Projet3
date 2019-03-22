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
        let url: URLConvertible = "https://polypaint.me/api/user/canvas"
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
    
    static func getAll() -> Promise<[Canvas]> {
        return Promise { seal in
            CanvasService.get().done{ (data) in
                let canvas = try JSONDecoder().decode([Canvas].self, from: data)
                seal.fulfill(canvas)
            }
        }
    }
    
    public static func SaveCanvas(name: String) -> Void {
        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let canvasPath = documentsURL.appendingPathComponent("canvas")
        let fileUrl = canvasPath.appendingPathComponent(name + ".json")
        
        // some convertion logic here to convert in base64
        do {
            try FileManager.default.createDirectory(atPath: canvasPath.path, withIntermediateDirectories: true, attributes: nil)
            
            let canva: Canvas = Canvas(canvasId: UUID().uuidString,name: name,base64Strokes: "",base64Image: "")
            if let encodedData = try? JSONEncoder().encode(canva){
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
