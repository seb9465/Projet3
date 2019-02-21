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
    private var undoArray: [FigureService];
    private var redoArray: [FigureService];
    
    init() {
        self.undoArray = [];
        self.redoArray = [];
    }
    
    func addNewFigure(origin: CGPoint, view: UIView) {
        let figure = FigureService(origin: origin);
        view.addSubview(figure);
        self.undoArray.append(figure);
    }
    
    public func undo(view: UIView) {
        print(undoArray);
        if (undoArray.count > 0) {
            let v: FigureService = view.subviews.last as! FigureService;
            self.redoArray.append(v);
            v.removeFromSuperview();
            self.undoArray.removeLast();
        }
    }
    
    public func redo(view: UIView) {
        if (redoArray.count > 0) {
            let v: FigureService = self.redoArray.last!;
            view.addSubview(v);
            self.undoArray.append(v);
            self.redoArray.removeLast();
        }
    }
    
    public func clear() {
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
    
    public func deleteFigure(subview: UIView) {
        if (self.subviewIsInUndoArray(subview: subview)) {
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
}

extension CanvasService {
    @discardableResult
    private static func request(route:CanvasEndpoint) -> Promise<Any> {
        return Promise {seal in
            Alamofire.request(route).responseJSON{ (response) in
                switch response.result {
                case .success(let value):
                    seal.fulfill(value);
                case .failure(let error):
                    seal.fulfill(error);
                }
            }
        }
    }
    
    static func getAll() -> Void{
        CanvasService.request(route: CanvasEndpoint.getAll()).done{canvas in
            print(canvas)
        }
    }
}
