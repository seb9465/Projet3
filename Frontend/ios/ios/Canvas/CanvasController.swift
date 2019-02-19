//
//  ConvasController.swift
//  ios
//
//  Created by Sebastien Cadorette on 2019-02-12.
//  Copyright © 2019 LOG3000 equipe 12. All rights reserved.
//

import UIKit

class CanvasController: UIViewController {
    var canvas: CanvasService!;
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated);
        
        navigationController?.setNavigationBarHidden(true, animated: animated);
        
        let width: CGFloat = UIScreen.main.bounds.width;
        let height: CGFloat = UIScreen.main.bounds.height;
        
        self.canvas = CanvasService(frame: CGRect(x: 0,
                                              y: 0,
                                              width: width,
                                              height: height))
        
        self.view.addSubview(self.canvas)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated);
        
        navigationController?.setNavigationBarHidden(false, animated: animated);
    }
    
    @IBAction func drawRectButton(_ sender: Any) {
        self.canvas.createRectangle();
        print("Add Rectangle");
    }
    
    
    @IBAction func quitButton(_ sender: Any) {
        let alert = UIAlertController(title: "Alert", message: "Would you like to quit ?", preferredStyle: .alert)
        
        let yesAction: UIAlertAction = UIAlertAction(title: "Yes", style: .default) { _ in
            let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil);
            let viewController: UIViewController = mainStoryboard.instantiateViewController(withIdentifier: "DashboardController");
            self.present(viewController, animated: true, completion: nil);
        }
        let noAction: UIAlertAction = UIAlertAction(title: "No", style: .default, handler: nil);
        
        alert.addAction(yesAction);
        alert.addAction(noAction);
        
        self.present(alert, animated: true, completion: nil)
    }
    
}
