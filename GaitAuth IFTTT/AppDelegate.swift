//
//  AppDelegate.swift
//  GaitAuth IFTTT
//
//  Created by Ryan Peden on 2020-12-17.
//

import UIKit
import UnifyID

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    let unifyid : UnifyID = { try! UnifyID(
        sdkKey: "https://f8db57da2cd02f5d9c29748dec2829b0@config.unify.id",
        user: "1111@cc.vvvb"
    )}()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

