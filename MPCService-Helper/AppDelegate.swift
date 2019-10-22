//
//  AppDelegate.swift
//  MPCService-Helper
//
//  Created by Jude Michael Murphy on 10/21/19.
//  Copyright © 2019 Jude Murphy. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var mpcService = MPCService()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        mpcService = MPCService(serviceType: "Example-Key")
        mpcService.delegate = self
        
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


// MARK: Extension for the MPC Delegate Protocols
extension AppDelegate: MPCServiceDelegate {
    func payloadReceived(manager: MPCService, payload: Data) {
        
    }
    
    func connectedDevicesStateChanged(manager: MPCService, connectedDevices: [String]) {
        print("******************************************************")
        print("Connected Devices: \(connectedDevices.count)")
        print("******************************************************")
    }
}
