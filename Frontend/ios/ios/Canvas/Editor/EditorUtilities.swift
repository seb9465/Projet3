//
//  EditorUtilities.swift
//  ios
//
//  Created by William Sevigny on 2019-04-06.
//  Copyright © 2019 LOG3000 equipe 12. All rights reserved.
//

extension Editor {

    func getSelectedFiguresDrawviewModels() -> [DrawViewModel] {
        var drawViewModels: [DrawViewModel] = []
        for figure in selectedFigures {
            drawViewModels.append(figure.exportViewModel()!)
        }

        return drawViewModels
    }
}
