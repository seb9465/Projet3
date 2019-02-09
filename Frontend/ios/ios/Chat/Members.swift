//
//  File.swift
//  ios
//
//  Created by Sebastien Cadorette on 2019-02-09.
//  Copyright © 2019 LOG3000 equipe 12. All rights reserved.
//

import Foundation
import UIKit

class Members {
    private var _members: [Member];
    
    var members: [Member] {
        get { return _members }
    }
    
    init() {
        self._members = [];
    }
    
    public func addMember(member: Member) -> Bool {
        if (!self.isAlreadyInArray(member: member)) {
            self._members.append(member);
            
            return true;
        }
        
        return false;
    }
    
    public func removeFromArray(member: Member) -> Bool {
        if (self.isAlreadyInArray(member: member)) {
            self._members.remove(at: self.getIndexOfMember(member: member));
            
            return true;
        }
        
        return false;
    }
    
    private func isAlreadyInArray(member: Member) -> Bool {
        return self._members.contains(where: { $0.name == member.name });
    }
    
    private func getIndexOfMember(member: Member) -> Int {
        return self._members.index(where: { (memb) -> Bool in
            memb.name == member.name
        }) ?? -1;
    }
}

class Member {
    private let _name: String;
    private let _color: UIColor;
    
    var name: String {
        get { return _name }
    }
    var color: UIColor {
        get { return _color }
    }
    
    init(name: String, color: UIColor) {
        self._name = name;
        self._color = color;
    }
}
