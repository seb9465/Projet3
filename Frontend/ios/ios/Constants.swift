//
//  Constants.swift
//  ios
//
//  Created by Sebastien Cadorette on 2019-02-09.
//  Copyright © 2019 LOG3000 equipe 12. All rights reserved.
//

import Foundation

struct Constants {
    static let SERVER_BASE_URL: String = "http://192.168.1.8:5000";
    static let CHAT_URL: String = Constants.SERVER_BASE_URL + "/signalr";
    static let LOGIN_URL: String = Constants.SERVER_BASE_URL + "/api/login";
    static let REGISTER_URL: String = Constants.SERVER_BASE_URL + "/api/register";
    static let LOGOUT_URL: String = Constants.SERVER_BASE_URL + "/api/user/logout";
    
    static let formatter: DateFormatter = {
        let formatter = DateFormatter();
        formatter.dateFormat = "HH:mm:ss";
        return formatter;
    }()
}
