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

    private var undoArray: [FigureService];
    private var redoArray: [FigureService];
    public var currentlySelectedFigure: FigureService!;
    
    init() {
        self.undoArray = [];
        self.redoArray = [];
    }
    
    public func addNewFigure(origin: CGPoint, view: UIView) -> Void {
        let figure = FigureService(origin: origin);
        view.addSubview(figure);
        self.undoArray.append(figure);
    }
    
    public func undo(view: UIView) -> Void {
        print(undoArray);
        if (undoArray.count > 0) {
            let figure: FigureService = view.subviews.last as! FigureService;
            self.redoArray.append(figure);
            figure.removeFromSuperview();
            self.undoArray.removeLast();
        }
    }
    
    public func redo(view: UIView) -> Void {
        if (redoArray.count > 0) {
            let figure: FigureService = self.redoArray.last!;
            view.addSubview(figure);
            self.undoArray.append(figure);
            self.redoArray.removeLast();
        }
    }
    
    public func clear() -> Void {
        for v in self.undoArray {
            v.removeFromSuperview();
        }
        self.undoArray.removeAll();
        self.redoArray.removeAll();
    }
    
    public func figuresInView() -> Bool {
        return self.undoArray.count > 0;
    }
    
    public func subviewIsInUndoArray(subview: UIView) -> Bool {
        for a in self.undoArray {
            if (a == subview) {
                return true;
            }
        }
        
        return false;
    }
    
    public func deleteFigure(tapPoint: CGPoint, view: UIView) -> Void {
        let subview = view.hitTest(tapPoint, with: nil);
        
        if (self.subviewIsInUndoArray(subview: subview!)) {
            var counter: Int = 0;
            for v in self.undoArray {
                if (v == subview) {
                    self.redoArray.append(v);
                    v.removeFromSuperview();
                    self.undoArray.remove(at: counter);
                    break;
                }
                counter += 1;
            }
        }
    }
    
    public func selectFigure(tapPoint: CGPoint, view: UIView) -> Bool {
        let subview = view.hitTest(tapPoint, with: nil);
        
        // CONDITIONS TO BE REVIEWED. DRY.
        if (self.subviewIsInUndoArray(subview: subview!)) {
            if (self.currentlySelectedFigure != nil) {
                self.currentlySelectedFigure.setIsNotSelected();
            }
            
            self.currentlySelectedFigure = subview as? FigureService;
            self.currentlySelectedFigure.setIsSelected();
            
            return true;
        } else {
            if (self.currentlySelectedFigure != nil) {
                self.currentlySelectedFigure.setIsNotSelected();
            }
            
            return false;
        }
    }
    
    public func unselectSelectedFigure() -> Void {
        if (self.currentlySelectedFigure != nil) {
            self.currentlySelectedFigure.setIsNotSelected();
        }
    }
    
//    public func setFillColor(fillColor: UIColor) -> Void {
//        self.currentlySelectedFigure.setFigureColor(figureColor: fillColor);
//    }
    
    public func setSelectedFigureColor(color: UIColor) -> Void {
        self.currentlySelectedFigure.setFillColor(fillColor: color);
    }
    
    public func setSelectFigureBorderColor(color: UIColor) -> Void {
        self.currentlySelectedFigure.setBorderColor(borderColor: color);
    }
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
}
