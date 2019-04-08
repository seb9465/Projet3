//
//  EditorSideToolbarDelegate.swift
//  ios
//
//  Created by William Sevigny on 2019-04-07.
//  Copyright © 2019 LOG3000 equipe 12. All rights reserved.
//

import UIKit

extension Editor: SideToolbarDelegate {
    func updateChanges() {
        self.currentChange.1 = self.getSelectedFiguresDrawviewModels()
        self.undoArray.append(self.currentChange)
        CollaborationHub.shared!.postNewFigure(figures: self.selectedFigures)
        CanvasService.saveOnNewFigure(figures: self.figures, editor: self)
    }
    
    func setSelectedFigureBorderColor(color: UIColor) {
        self.currentChange.0 = self.getSelectedFiguresDrawviewModels()
        
        for figure in self.selectedFigures {
            figure.setBorderColor(borderColor: color);
        }
        self.updateChanges()
    }
    
    func setSelectedFigureFillColor(color: UIColor) {
        self.currentChange.0 = self.getSelectedFiguresDrawviewModels()
        
        for figure in self.selectedFigures {
            figure.setFillColor(fillColor: color)
        }
        self.updateChanges()
    }
    
    func setSelectedFigureBorderStyle(isDashed: Bool) {
        self.currentChange.0 = self.getSelectedFiguresDrawviewModels()
        for figure in self.selectedFigures {
            figure.setIsBorderDashed(isDashed: isDashed)
        }
        self.updateChanges()
    }
    
    func setSelectedFigureLineWidth(width: CGFloat) {
        self.currentChange.0 = self.getSelectedFiguresDrawviewModels()
        for figure in self.selectedFigures {
            figure.setLineWidth(width: width)
        }
        self.updateChanges()
    }
    
    func setSelectedFigureName(name: String) {
        self.currentChange.0 = self.getSelectedFiguresDrawviewModels()
        for figure in self.selectedFigures {
            figure.setFigureName(name: name)
        }
        self.updateChanges()
    }
    
    func setSelectedFigureSourceLabel(name: String) {
        self.currentChange.0 = self.getSelectedFiguresDrawviewModels()
        for figure in self.selectedFigures {
            (figure as! ConnectionFigure).setSourceName(name: name)
        }
        self.updateChanges()
    }
    
    func setSelectedFigureDestinationLabel(name: String) {
        self.currentChange.0 = self.getSelectedFiguresDrawviewModels()
        for figure in self.selectedFigures {
            (figure as! ConnectionFigure).setDestinationName(name: name)
        }
        self.updateChanges()
    }
    
    func addClassMethod(name: String) {
        self.currentChange.0 = self.getSelectedFiguresDrawviewModels()
        for figure in self.selectedFigures {
            (figure as! UmlClassFigure).addMethod(name: name)
        }
        
        self.updateSideToolBar()
        self.updateChanges()
    }
    
    func removeClassMethod(name: String, index: Int) {
        self.currentChange.0 = self.getSelectedFiguresDrawviewModels()
        for figure in self.selectedFigures {
            (figure as! UmlClassFigure).removeMethod(name: name, index: index)
        }
        
        self.updateSideToolBar()
        self.updateChanges()
    }
    
    func addClassAttribute(name: String) {
        self.currentChange.0 = self.getSelectedFiguresDrawviewModels()
        for figure in self.selectedFigures {
            (figure as! UmlClassFigure).addAttribute(name: name);
        }
        
        self.updateSideToolBar()
        self.updateChanges()
    }
    
    func removeClassAttribute(name: String, index: Int) {
        self.currentChange.0 = self.getSelectedFiguresDrawviewModels()
        for figure in self.selectedFigures {
            (figure as! UmlClassFigure).removeAttribute(name: name, index: index);
        }
        
        self.updateSideToolBar()
        self.updateChanges()
    }
    
    func updateSideToolBar() {
        for controller in self.sideToolbatControllers {
            controller.update();
        }
    }
    
//    func rotate(orientation: RotateOrientation) {
//        for figure in self.selectedFigures {
//            let tempFigure: Figure = figure;
//            figure.rotate(orientation: orientation);
//            self.deselectFigure(figure: tempFigure);
//            self.select(figure: figure);
//        }
//        
//        CollaborationHub.shared!.postNewFigure(figures: self.selectedFigures)
//    }
}
