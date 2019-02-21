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
    private var currentlySelectedFigure: FigureService!;
    
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
    
    public func selectFigure(tapPoint: CGPoint, view: UIView) -> Void {
        let subview = view.hitTest(tapPoint, with: nil);
        
        if (self.subviewIsInUndoArray(subview: subview!)) {
            if (self.currentlySelectedFigure != nil) {
                self.currentlySelectedFigure.isSelected = false;
            }
            
            self.currentlySelectedFigure = subview as? FigureService;
            self.currentlySelectedFigure.isSelected = true;
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
