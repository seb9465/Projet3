//
//  ConvasController.swift
//  ios
//
//  Created by Sebastien Cadorette on 2019-02-12.
//  Copyright © 2019 LOG3000 equipe 12. All rights reserved.
//

import UIKit
import Sketch

class CanvasController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        let sketchView = SketchView(frame:
            CGRect(x: 0,
                   y: 0,
                   width: UIScreen.main.bounds.width,
                   height: UIScreen.main.bounds.height
            )
        )
        
        view.addSubview(sketchView)
    }
    
    
}
