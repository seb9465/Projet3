//
//  AppDelegate.swift
//  ios
//
//  Created by Sebastien Cadorette on 2019-01-21.
//  Copyright © 2019 LOG3000 equipe 12. All rights reserved.
//

import UIKit
import Alamofire
import FacebookCore

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        return SDKApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return SDKApplicationDelegate.shared.application(app, open: url, options: options)
    }
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        let token: String? = UserDefaults.standard.string(forKey: "token");
        
        if token != nil {
        let headers = [
            "Authorization": "Bearer " + UserDefaults.standard.string(forKey: "token")!
        ];
        
        Alamofire.request(Constants.LOGOUT_URL as URLConvertible, method: .get, encoding: JSONEncoding.default, headers: headers).responseString{ response in
            print(response);
        };
        UserDefaults.standard.removePersistentDomain(forName: "token");
        
        let mainView: UIStoryboard = UIStoryboard(name: "Main", bundle: nil);
        let viewcontroller : UIViewController = mainView.instantiateViewController(withIdentifier: "LoginStoryboard") as UIViewController;
        self.window!.rootViewController = viewcontroller;
    }
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        let headers = [
            "Authorization": "Bearer " + UserDefaults.standard.string(forKey: "token")!
        ];
        
        Alamofire.request(Constants.LOGOUT_URL as URLConvertible, method: .get, encoding: JSONEncoding.default, headers: headers).responseString{ response in
            print(response);
        };
        UserDefaults.standard.removePersistentDomain(forName: "token");
        sleep(10);
        print("terminated");
    }
}

