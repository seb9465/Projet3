//
//  ConvasController.swift
//  ios
//
//  Created by Sebastien Cadorette on 2019-02-12.
//  Copyright © 2019 LOG3000 equipe 12. All rights reserved.
//

import UIKit
import Sketch

class CanvasController: UIViewController, ButtonViewInterface {
    @IBOutlet var sketchView: SketchView!
    var buttonView: ButtonView!;
    var scrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 100))
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        sketchView = SketchView(frame:
            CGRect(
                x: 0,
                y: 0,
                width: UIScreen.main.bounds.width,
                height: UIScreen.main.bounds.height
            )
        );
        sketchView.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1);
        view.addSubview(sketchView);
        
        buttonView = ButtonView.instanceFromNib(self);
        
        view.addSubview(scrollView);
        scrollView.addSubview(buttonView);
        
        scrollView.contentSize = buttonView.frame.size;
        scrollView.showsHorizontalScrollIndicator = false;
        scrollView.frame.origin.x = 0;
        scrollView.frame.origin.y = UIScreen.main.bounds.height - buttonView.frame.size.height;
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: animated);
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: animated);
    }
}

extension CanvasController {
    
    func tapFigureButton(figureButton: UIButton) {
        let lineAction = UIAlertAction(title: "Line", style: .default) { _ in
            self.sketchView.drawTool = .line
            figureButton.setImage(UIImage(named: "Line Icon Black"), for: .normal);
            figureButton.layer.cornerRadius = 5;
            figureButton.layer.borderWidth = 1;
            figureButton.layer.borderColor = UIColor.black.cgColor;
        }
        
        let arrowAction = UIAlertAction(title: "Arrow", style: .default) { _ in
            self.sketchView.drawTool = .arrow
        }
        
        let rectAction = UIAlertAction(title: "Rect", style: .default) { _ in
            self.sketchView.drawTool = .rectangleStroke
        }
        
        let rectFillAction = UIAlertAction(title: "Rect(Fill)", style: .default) { _ in
            self.sketchView.drawTool = .rectangleFill
        }
        
        let ellipseAction = UIAlertAction(title: "Ellipse", style: .default) { _ in
            self.sketchView.drawTool = .ellipseStroke
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default) { _ in }
        
        let alertController = UIAlertController(title: "Please select a figure", message: nil, preferredStyle: .alert)
        alertController.addAction(lineAction)
        alertController.addAction(arrowAction);
        alertController.addAction(rectAction);
        alertController.addAction(rectFillAction);
        alertController.addAction(ellipseAction);
        alertController.addAction(cancelAction);
        
        present(alertController, animated: true, completion: nil)
    }
    
    func tapPenButton() {
        sketchView.drawTool = .pen;
    }
    
    func tapClearButton() {
        sketchView.clear();
    }
    
    func tapUndoButton() {
        sketchView.undo();
    }
    
    func tapRedoButton() {
        sketchView.redo();
    }
    
    func tapQuitButton() {
        let yesAction = UIAlertAction(title: "Yes", style: .default) { _ in
            let mainView: UIStoryboard = UIStoryboard(name: "Main", bundle: nil);
            let viewcontroller : UIViewController = mainView.instantiateViewController(withIdentifier: "DashboardView") as UIViewController;
            self.present(viewcontroller, animated: true, completion: nil);
        }
        let noAction = UIAlertAction(title: "No", style: .default) { _ in }
        let cancelAction = UIAlertAction(title: "Cancel", style: .default) { _ in }
        
        let alertController = UIAlertController(title: "Would you like to save before quitting ?", message: nil, preferredStyle: .alert);
        alertController.addAction(yesAction);
        alertController.addAction(noAction);
        alertController.addAction(cancelAction);
        
        present(alertController, animated: true, completion: nil);
    }
}
