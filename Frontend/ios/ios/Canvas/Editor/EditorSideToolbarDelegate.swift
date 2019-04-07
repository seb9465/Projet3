//
//  EditorSideToolbarDelegate.swift
//  ios
//
//  Created by William Sevigny on 2019-04-07.
//  Copyright © 2019 LOG3000 equipe 12. All rights reserved.
//

import UIKit

extension Editor: SideToolbarDelegate {
    func setSelectedFigureBorderColor(color: UIColor) {
        for figure in self.selectedFigures {
            figure.setBorderColor(borderColor: color);
        }
        CollaborationHub.shared!.postNewFigure(figures: self.selectedFigures)
        CanvasService.saveOnNewFigure(figures: self.figures, editor: self)
    }
    
    func setSelectedFigureFillColor(color: UIColor) {
        for figure in self.selectedFigures {
            figure.setFillColor(fillColor: color)
        }
        CollaborationHub.shared!.postNewFigure(figures: self.selectedFigures)
        CanvasService.saveOnNewFigure(figures: self.figures, editor: self)
    }
    
    func setSelectedFigureBorderStyle(isDashed: Bool) {
        for figure in self.selectedFigures {
            figure.setIsBorderDashed(isDashed: isDashed)
        }
        CollaborationHub.shared!.postNewFigure(figures: self.selectedFigures)
        CanvasService.saveOnNewFigure(figures: self.figures, editor: self)
    }
    
    func setSelectedFigureLineWidth(width: CGFloat) {
        for figure in self.selectedFigures {
            figure.setLineWidth(width: width)
        }
        CollaborationHub.shared!.postNewFigure(figures: self.selectedFigures)
        CanvasService.saveOnNewFigure(figures: self.figures, editor: self)
    }
    
    func setSelectedFigureName(name: String) {
        for figure in self.selectedFigures {
            figure.setFigureName(name: name)
        }
        CollaborationHub.shared!.postNewFigure(figures: self.selectedFigures)
    }
    
    func setSelectedFigureSourceLabel(name: String) {
        for figure in self.selectedFigures {
            (figure as! ConnectionFigure).setSourceName(name: name)
        }
        CollaborationHub.shared!.postNewFigure(figures: self.selectedFigures)
    }
    
    func setSelectedFigureDestinationLabel(name: String) {
        for figure in self.selectedFigures {
            (figure as! ConnectionFigure).setDestinationName(name: name)
        }
        CollaborationHub.shared!.postNewFigure(figures: self.selectedFigures)
    }
    
    func setSelectedFigureNameDidEnd() {
        CollaborationHub.shared!.postNewFigure(figures: self.selectedFigures)
        CanvasService.saveOnNewFigure(figures: self.figures, editor: self)
    }
    
    func addClassMethod(name: String) {
        for figure in self.selectedFigures {
            (figure as! UmlClassFigure).addMethod(name: name)
        }
        
        self.updateSideToolBar()
        CollaborationHub.shared!.postNewFigure(figures: self.selectedFigures)
        CanvasService.saveOnNewFigure(figures: self.figures, editor: self)
    }
    
    func removeClassMethod(name: String, index: Int) {
        for figure in self.selectedFigures {
            (figure as! UmlClassFigure).removeMethod(name: name, index: index)
        }
        
        self.updateSideToolBar()
        CollaborationHub.shared!.postNewFigure(figures: self.selectedFigures)
        CanvasService.saveOnNewFigure(figures: self.figures, editor: self)
    }
    
    func addClassAttribute(name: String) {
        for figure in self.selectedFigures {
            (figure as! UmlClassFigure).addAttribute(name: name);
        }
        
        self.updateSideToolBar()
        CollaborationHub.shared!.postNewFigure(figures: self.selectedFigures)
        CanvasService.saveOnNewFigure(figures: self.figures, editor: self)
    }
    
    func removeClassAttribute(name: String, index: Int) {
        for figure in self.selectedFigures {
            (figure as! UmlClassFigure).removeAttribute(name: name, index: index);
        }
        
        self.updateSideToolBar()
        CollaborationHub.shared!.postNewFigure(figures: self.selectedFigures)
        CanvasService.saveOnNewFigure(figures: self.figures, editor: self)
    }
    
    func updateSideToolBar() {
        for controller in self.sideToolbatControllers {
            controller.update();
        }
    }
    
    func rotate(orientation: RotateOrientation) {
        for figure in self.selectedFigures {
            let tempFigure: Figure = figure;
            figure.rotate(orientation: orientation);
            self.deselectFigure(figure: tempFigure);
            self.select(figure: figure);
        }
        
        CollaborationHub.shared!.postNewFigure(figures: self.selectedFigures)
    }
}
