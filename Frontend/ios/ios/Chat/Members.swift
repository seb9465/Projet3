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
        if (!self.isAlreadyInArray(memberName: member.name)) {
            self._members.append(member);
            
            return true;
        }
        
        return false;
    }
    
    public func removeFromArray(member: Member) -> Bool {
        if (self.isAlreadyInArray(memberName: member.name)) {
            self._members.remove(at: self.getIndexOfMember(memberName: member.name));
            
            return true;
        }
        
        return false;
    }
    
    public func getMemberByName(memberName: String) -> Member {
        return self._members[self.getIndexOfMember(memberName: memberName)];
    }
    
    public func isAlreadyInArray(memberName: String) -> Bool {
        return self._members.contains(where: { $0.name == memberName });
    }
    
    private func getIndexOfMember(memberName: String) -> Int {
        return self._members.index(where: { (memb) -> Bool in
            memb.name == memberName
        }) ?? -1;
    }
}

class Member {
    let _name: String;
    let _color: UIColor;
    
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
