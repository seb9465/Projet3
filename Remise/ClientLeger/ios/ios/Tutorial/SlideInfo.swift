//
//  SlideInfo.swift
//  ios
//
//  Created by Sebastien Cadorette on 2019-04-08.
//  Copyright © 2019 LOG3000 equipe 12. All rights reserved.
//

import Foundation

class SlideInfo {
    
    // MARK:  - Attributes
    
    private var _imageName: String!;
    private var _title: String!;
    private var _description: String!;
    
    // MARK: - Getter - Setter
    
    public var imageName: String {
        get { return self._imageName }
        set { self._imageName = newValue }
    }
    
    public var title: String {
        get { return self._title }
        set { self._title = newValue }
    }
    
    public var description: String {
        get { return self._description }
        set { self._description = newValue }
    }
    
    // MARK: - Constructor
    
    init(imageName: String, title: String, description: String) {
        self._imageName = imageName;
        self._title = title;
        self._description = description;
    }
}
