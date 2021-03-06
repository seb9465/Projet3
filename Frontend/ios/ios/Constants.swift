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
    // MARK: - Server Address
    static let SERVER_BASE_URL: String = "https://polypaint.me";

    // MARK: - Hubs
    static let CHAT_URL: String = Constants.SERVER_BASE_URL + "/signalr";
    static let COLLABORATION_URL: String = Constants.SERVER_BASE_URL + "/signalr/collaborative"

    // MARK: - Endpoints
    static let LOGIN_URL: String = Constants.SERVER_BASE_URL + "/api/login";
    static let FB_LOGIN_URL: String = Constants.SERVER_BASE_URL + "/api/login/ios-callback";

    static let REGISTER_URL: String = Constants.SERVER_BASE_URL + "/api/register";
    static let LOGOUT_URL: String = Constants.SERVER_BASE_URL + "/api/user/logout";
    static let SAVE_URL: String = Constants.SERVER_BASE_URL + "/api/user/canvas";
    static let TUTORIAL_URL: String = Constants.SERVER_BASE_URL + "/api/user/tutorial";
    static let TUTORIAL_SHOWN_URL: String = Constants.SERVER_BASE_URL + "/api/user/tutorial/true";

    // MARK: - Colors
    struct Colors {
        static let RED_COLOR: UIColor = UIColor(red: 1, green: 0.419608, blue: 0.419608, alpha: 1);
        static let LIGHT_RED_COLOR: UIColor = UIColor(red: 1, green: 0.419608, blue: 0.419608, alpha: 0.5);
        static let GREY_COLOR: UIColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3);
        static let DEFAULT_BLUE_COLOR = UIColor(red: 0, green: 122/255, blue: 1, alpha: 1);
        static let GREEN_COLOR: UIColor = UIColor (red: 0, green: 204/255, blue: 34/255, alpha: 1);
    }
    
    // MARK: - Date formatter
    static let formatter: DateFormatter = {
        let formatter = DateFormatter();
        formatter.dateFormat = "HH:mm:ss";
        return formatter;
    }();
    
    // MARK: - Chat View Container constants
    struct ChatView {
        static let cornerRadius: CGFloat = 5.0;
        static let shadowColor: CGColor = UIColor.black.cgColor;
        static let shadowOffset: CGSize = CGSize.zero;
        static let shadowOpacity: Float = 0.5;
        static let shadowRadius: CGFloat = 3.0;
    }
}
