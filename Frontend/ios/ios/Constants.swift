//
//  Constants.swift
//  ios
//
//  Created by Sebastien Cadorette on 2019-02-09.
//  Copyright © 2019 LOG3000 equipe 12. All rights reserved.
//

import Foundation
import UIKit

struct Constants {
    // Server Address
    static let SERVER_BASE_URL: String = "https://polypaint.me";

    // Hubs
    static let CHAT_URL: String = Constants.SERVER_BASE_URL + "/signalr";
    static let COLLABORATION_URL: String = Constants.SERVER_BASE_URL + "/signalr/collaborative?channelId=general"

    // Endpoints
    static let LOGIN_URL: String = Constants.SERVER_BASE_URL + "/api/login";
    static let REGISTER_URL: String = Constants.SERVER_BASE_URL + "/api/register";
    static let LOGOUT_URL: String = Constants.SERVER_BASE_URL + "/api/user/logout";
    
    static let RED_COLOR: UIColor = UIColor(red: 1, green: 0.419608, blue: 0.419608, alpha: 1);
    static let DEFAULT_BLUE_COLOR = UIColor(red: 0, green: 122/255, blue: 1, alpha: 1);
    
    static let formatter: DateFormatter = {
        let formatter = DateFormatter();
        formatter.dateFormat = "HH:mm:ss";
        return formatter;
    }()
}
