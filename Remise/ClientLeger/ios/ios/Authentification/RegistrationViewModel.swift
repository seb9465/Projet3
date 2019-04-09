//
//  RegistrationViewModel.swift
//  ios
//
//  Created by Sebastien Cadorette on 2019-04-01.
//  Copyright © 2019 LOG3000 equipe 12. All rights reserved.
//

import Foundation

class RegistrationViewModel {
    
    // MARK: Attributes
    
    private var _firstName: String;
    private var _lastName: String;
    private var _email: String;
    private var _username: String;
    private var _password: String;
    private var _isLoggedIn: Bool;
    private var _isTutorialShown: Bool;
    
    // MARK: Constructor
    
    init (firstName: String, lastName: String, email: String, username: String, password: String, isLoggedIn: Bool? = false, isTutorialShow: Bool? = false) {
        self._firstName = firstName;
        self._lastName = lastName;
        self._email = email;
        self._username = username;
        self._password = password;
        self._isLoggedIn = isLoggedIn!;
        self._isTutorialShown = isTutorialShow!;
    }
    
    // MARK: Getter - Setter
    
    public var firstName: String {
        get { return self._firstName }
    }
    
    public var lastName: String {
        get { return self._lastName }
    }
    
    public var email: String {
        get { return self._email }
    }
    
    public var username: String {
        get { return self._username }
    }
    
    public var password: String {
        get { return self._password }
    }
    
    public var isLoggedIn: Bool {
        get { return self._isLoggedIn }
    }
    
    public var isTutorialShown: Bool {
        get { return self._isTutorialShown }
    }
    
    // MARK: Public functions
    
    public func toJson() -> [String: String]{
        return [
            "firstName": self._firstName,
            "lastName": self._lastName,
            "username": self._username,
            "email": self._email,
            "password": self._password,
            "isLoggedIn": self._isLoggedIn.description,
            "isTutorialShown": self._isTutorialShown.description,
        ];
    }
}
