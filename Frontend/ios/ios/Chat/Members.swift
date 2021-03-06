//
//  Members.swift
//  ios
//
//  Created by Sebastien Cadorette on 2019-02-09.
//  Copyright © 2019 LOG3000 equipe 12. All rights reserved.
//

import Foundation
import UIKit

class Members {
    
    // MARK: Attributes
    
    private var _members: [Member];
    
    // MARK: Constructor
    
    init() {
        self._members = [];
    }
    
    // MARK: Getter - Setter
    
    public var members: [Member] {
        get { return _members }
    }
    
    // MARK: Public functions
    
    public func addMember(member: Member) -> Void {
        if (!self.isAlreadyInArray(memberName: member.name)) {
            self._members.append(member);
        }
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
    
    // MARK: Private functions
    
    private func getIndexOfMember(memberName: String) -> Int {
        return self._members.index(where: { (memb) -> Bool in
            memb.name == memberName
        }) ?? -1;
    }
}

class Member {
    
    // MARK: Attributes
    
    private let _name: String;
    private let _color: UIColor;
    
    // MARK: Constructor
    
    init(name: String, color: UIColor) {
        self._name = name;
        self._color = color;
    }
    
    // MARK: Getter - Setter
    
    public var name: String {
        get { return _name }
    }
    
    public var color: UIColor {
        get { return _color }
    }
}
