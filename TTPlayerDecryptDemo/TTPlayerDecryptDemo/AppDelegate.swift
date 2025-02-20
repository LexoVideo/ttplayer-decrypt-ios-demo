//
//  AppDelegate.swift
//  TTPlayerDecryptDemo
//

import UIKit
import TTSDK

@main
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        setupTT()
        
        return true
    }
    
    private func setupTT() {
        // set your app id
        let appId = ""
        // set your tt license lic name
        let licenseName = "ttlicense" // replace this with your own tt license file
        
        let configuration = TTSDKConfiguration.defaultConfiguration(withAppID: appId, licenseName: licenseName)
        
        TTSDKManager.start(with: configuration)
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

